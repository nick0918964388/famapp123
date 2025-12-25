import Foundation

/// 核簽紀錄
struct ApprovalRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let approverID: String               // 核簽人 ID
    let approverName: String             // 核簽人姓名
    let approvalDate: Date               // 核簽日期
    let comment: String                  // 簽核意見
    let status: ApprovalStatus           // 核簽狀態

    enum ApprovalStatus: String, Codable {
        case approved = "APPROVED"       // 已核准
        case rejected = "REJECTED"       // 已駁回
        case pending = "PENDING"         // 待核簽
    }
}

/// 呈核請求
struct SubmitApprovalRequest: Codable {
    let workOrderId: String
    let workDescription: String          // 作業說明
    let comment: String                  // 簽核意見
}
