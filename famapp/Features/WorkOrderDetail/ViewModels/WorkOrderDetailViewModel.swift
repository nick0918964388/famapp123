import Foundation
import SwiftUI

@MainActor
final class WorkOrderDetailViewModel: ObservableObject {
    @Published var workOrder: WorkOrder
    @Published var selectedTab: DetailTab = .overview
    @Published var selectedOverviewSubTab: OverviewSubTab = .workOrder
    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false
    @Published var showSubmitDialog: Bool = false
    @Published var submitComment: String = ""
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    enum DetailTab: String, CaseIterable, Identifiable {
        case manpower = "人力"
        case tools = "工具"
        case approvalRecords = "核簽紀錄"
        case overview = "總覽"

        var id: String { rawValue }
    }

    enum OverviewSubTab: String, CaseIterable, Identifiable {
        case workOrder = "工單"
        case maintenanceProcedure = "保養作業程序"
        case materials = "材料"

        var id: String { rawValue }
    }

    var pendingProcedureCount: Int {
        workOrder.maintenanceProcedures.filter { $0.result == nil }.count
    }

    var totalProcedureCount: Int {
        workOrder.maintenanceProcedures.count
    }

    private let dataService: DataServiceProtocol

    init(workOrder: WorkOrder, dataService: DataServiceProtocol = DependencyContainer.shared.dataService) {
        self.workOrder = workOrder
        self.dataService = dataService
    }

    // MARK: - Maintenance Procedures

    func updateProcedureResult(_ procedureId: UUID, result: MaintenanceProcedure.ResultType?) {
        if let index = workOrder.maintenanceProcedures.firstIndex(where: { $0.id == procedureId }) {
            workOrder.maintenanceProcedures[index].result = result
        }
    }

    func updateProcedureMeasurement(_ procedureId: UUID, value: String) {
        if let index = workOrder.maintenanceProcedures.firstIndex(where: { $0.id == procedureId }) {
            workOrder.maintenanceProcedures[index].measurementValue = value
        }
    }

    func updateProcedureNotes(_ procedureId: UUID, notes: String) {
        if let index = workOrder.maintenanceProcedures.firstIndex(where: { $0.id == procedureId }) {
            workOrder.maintenanceProcedures[index].notes = notes
        }
    }

    func setAllProceduresResult(_ result: MaintenanceProcedure.ResultType) {
        for index in workOrder.maintenanceProcedures.indices {
            workOrder.maintenanceProcedures[index].result = result
        }
    }

    // MARK: - Materials

    func toggleMaterialSelection(_ materialId: UUID) {
        if let index = workOrder.materials.firstIndex(where: { $0.id == materialId }) {
            workOrder.materials[index].isSelected.toggle()
        }
    }

    // MARK: - Tools

    func toggleToolSelection(_ toolId: UUID) {
        if let index = workOrder.tools.firstIndex(where: { $0.id == toolId }) {
            workOrder.tools[index].isSelected.toggle()
        }
    }

    func removeTool(_ toolId: UUID) {
        workOrder.tools.removeAll { $0.id == toolId }
    }

    // MARK: - Manpower

    func updateManpowerHours(_ manpowerId: UUID, hours: Double) {
        if let index = workOrder.manpower.firstIndex(where: { $0.id == manpowerId }) {
            workOrder.manpower[index].maintenanceHours = hours
        }
    }

    func updateManpowerNotes(_ manpowerId: UUID, notes: String) {
        if let index = workOrder.manpower.firstIndex(where: { $0.id == manpowerId }) {
            workOrder.manpower[index].notes = notes
        }
    }

    func removeManpower(_ manpowerId: UUID) {
        workOrder.manpower.removeAll { $0.id == manpowerId }
    }

    // MARK: - Save & Submit

    func save() async {
        isSaving = true
        do {
            try await dataService.saveWorkOrder(workOrder)
            // Add upload record
            let record = UploadRecord(
                id: UUID(),
                uploadedAt: Date(),
                uploadedBy: "current_user",
                description: "儲存工單",
                status: .success
            )
            workOrder.uploadHistory.append(record)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isSaving = false
    }

    func submit() async {
        isSaving = true
        do {
            // Validate all procedures have results
            let incompleteProcedures = workOrder.maintenanceProcedures.filter { $0.result == nil }
            if !incompleteProcedures.isEmpty {
                throw ValidationError.incompleteProcedures
            }

            try await dataService.saveWorkOrder(workOrder)

            // Add approval record
            let approval = ApprovalRecord(
                id: UUID(),
                approverID: "current_user",
                approverName: "當前使用者",
                approvalDate: Date(),
                comment: submitComment,
                status: .pending
            )
            workOrder.approvalRecords.append(approval)
            workOrder.status = .reported

            showSubmitDialog = false
            submitComment = ""
        } catch let error as ValidationError {
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isSaving = false
    }

    // MARK: - Navigation

    func nextStep() {
        switch selectedTab {
        case .overview:
            switch selectedOverviewSubTab {
            case .workOrder:
                selectedOverviewSubTab = .maintenanceProcedure
            case .maintenanceProcedure:
                selectedOverviewSubTab = .materials
            case .materials:
                selectedTab = .manpower
            }
        case .manpower:
            selectedTab = .tools
        case .tools:
            showSubmitDialog = true
        case .approvalRecords:
            break
        }
    }

    var nextStepTitle: String {
        switch selectedTab {
        case .overview:
            switch selectedOverviewSubTab {
            case .workOrder:
                return "下一步：保養作業程序"
            case .maintenanceProcedure:
                return "下一步：材料回報"
            case .materials:
                return "下一步：人力回報"
            }
        case .manpower:
            return "下一步：工具回報"
        case .tools:
            return "下一步：呈核"
        case .approvalRecords:
            return ""
        }
    }
}

enum ValidationError: LocalizedError {
    case incompleteProcedures
    case missingMeasurements

    var errorDescription: String? {
        switch self {
        case .incompleteProcedures:
            return "請完成所有保養作業程序的填寫"
        case .missingMeasurements:
            return "請填寫所有必填的測量值"
        }
    }
}
