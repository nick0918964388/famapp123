import Foundation

/// 母工單 (Parent Work Order)
struct ParentWorkOrder: Identifiable, Codable, Equatable {
    let id: UUID
    let orderNumber: String              // e.g., "WO20170000013420"
    let orderType: OrderType
    var childOrders: [WorkOrder]
    var status: WorkOrderStatus
    let childCount: Int                  // 母工單(3) - count of children

    var pendingCount: Int {
        childOrders.filter { $0.displayStatus == .pendingReport }.count
    }

    /// 顯示用狀態（根據子工單實際填寫情況判斷）
    var displayStatus: WorkOrderStatus {
        // 如果有任一子工單已回報，母工單顯示已回報
        if childOrders.contains(where: { $0.hasAnyResponse }) {
            return .reported
        }
        return status
    }
}

/// 工單 (Work Order / Child Order)
struct WorkOrder: Identifiable, Codable, Equatable {
    let id: UUID
    let orderNumber: String              // e.g., "WO20170000013420" or asset "F15-ASSET100"
    let assetNumber: String              // 資產編號
    let equipmentGroup: String           // 設備群組
    let workPlan: String                 // 工作計劃
    let description: String              // 說明
    let scheduledDate: Date              // 預計執行日
    let executionDeadline: Date          // 工單執行期限
    let reporterEngineer: String         // 回報保養工程師
    let reporterID: String               // 回報人員 ID (e.g., "Y_TILSMJ")
    var status: WorkOrderStatus          // 待回報/已回報

    // Detail descriptions (right column in header)
    let equipmentDescription: String     // e.g., "F15P1 CUP ZEROC01 零產生器(VO..."
    let groupDescription: String         // e.g., "F-CHV-03-03-006 F15P1 CUP Zero..."
    let planDescription: String          // e.g., "F15P1 CUP Zero Air產生器保養#C01"

    // Related data for detail view
    var maintenanceProcedures: [MaintenanceProcedure]  // 保養作業程序
    var materials: [Material]                          // 材料
    var manpower: [Manpower]                           // 人力
    var tools: [Tool]                                  // 工具
    var approvalRecords: [ApprovalRecord]              // 核簽紀錄

    // Actual dates (for child order reporting)
    var actualStartDate: Date?           // 實際開工日
    var actualCompletionDate: Date?      // 實際完工日

    // Sync metadata
    var isDownloaded: Bool
    var lastModified: Date
    var syncStatus: SyncStatus
    var uploadHistory: [UploadRecord]

    /// 是否有任何回報資料
    var hasAnyResponse: Bool {
        // 檢查是否有任一保養作業程序已填寫結果
        let hasProcedureResult = maintenanceProcedures.contains { $0.result != nil }
        // 檢查是否有實際開工日或完工日
        let hasActualDates = actualStartDate != nil || actualCompletionDate != nil
        // 檢查是否有材料使用數量
        let hasMaterialUsed = materials.contains { $0.usedQuantity > 0 }

        return hasProcedureResult || hasActualDates || hasMaterialUsed
    }

    /// 顯示用狀態（根據實際填寫情況判斷）
    var displayStatus: WorkOrderStatus {
        if hasAnyResponse {
            return .reported
        }
        return status
    }

    static func == (lhs: WorkOrder, rhs: WorkOrder) -> Bool {
        lhs.id == rhs.id &&
        lhs.status == rhs.status &&
        lhs.hasAnyResponse == rhs.hasAnyResponse &&
        lhs.actualStartDate == rhs.actualStartDate &&
        lhs.actualCompletionDate == rhs.actualCompletionDate
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension WorkOrder: Hashable {}

/// 上傳紀錄
struct UploadRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let uploadedAt: Date
    let uploadedBy: String
    let description: String
    let status: UploadStatus

    enum UploadStatus: String, Codable {
        case success = "SUCCESS"
        case failed = "FAILED"
        case pending = "PENDING"
    }
}
