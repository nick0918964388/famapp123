import Foundation
import SwiftUI
import Combine

@MainActor
final class ParentWorkOrderDetailViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var parentWorkOrder: ParentWorkOrder
    @Published var selectedChildId: UUID?
    @Published var isViewingParent: Bool = true

    // Tab selection
    @Published var selectedParentTab: ParentTab = .overview
    @Published var selectedChildTab: ChildTab = .workItems

    // Loading states
    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false

    // Material options from API
    @Published var availableMaterials: [MaterialOption] = []
    @Published var isLoadingMaterials: Bool = false

    // Dialog states
    @Published var showSubmitDialog: Bool = false
    @Published var submitComment: String = ""
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    // MARK: - Enums

    enum ParentTab: String, CaseIterable, Identifiable {
        case overview = "總覽"
        case manpowerReport = "人力回報"
        case materialStats = "材料統計"
        case approvalRecords = "核簽紀錄"

        var id: String { rawValue }
    }

    enum ChildTab: String, CaseIterable, Identifiable {
        case workItems = "工作項目回報"
        case plannedMaterial = "計畫材料回報"
        case dates = "日期回報"

        var id: String { rawValue }
    }

    // MARK: - Change Tracking

    private var originalState: ParentWorkOrder
    private var cancellables = Set<AnyCancellable>()

    var hasChanges: Bool {
        !areParentWorkOrdersEqual(parentWorkOrder, originalState)
    }

    // MARK: - Computed Properties

    var selectedChild: WorkOrder? {
        guard let id = selectedChildId else { return nil }
        return parentWorkOrder.childOrders.first { $0.id == id }
    }

    var selectedChildIndex: Int? {
        guard let id = selectedChildId else { return nil }
        return parentWorkOrder.childOrders.firstIndex { $0.id == id }
    }

    // Aggregated statistics
    var totalChildCount: Int {
        parentWorkOrder.childOrders.count
    }

    var completedChildCount: Int {
        parentWorkOrder.childOrders.filter { $0.displayStatus == .reported }.count
    }

    var pendingChildCount: Int {
        parentWorkOrder.childOrders.filter { $0.displayStatus == .pendingReport }.count
    }

    var aggregatedManpower: [Manpower] {
        parentWorkOrder.childOrders.flatMap { $0.manpower }
    }

    var totalManpowerHours: Double {
        aggregatedManpower.reduce(0) { $0 + $1.maintenanceHours }
    }

    var aggregatedMaterials: [Material] {
        parentWorkOrder.childOrders.flatMap { $0.materials }
    }

    var selectedMaterialsCount: Int {
        aggregatedMaterials.filter { $0.isSelected }.count
    }

    var allProceduresCompleted: Bool {
        parentWorkOrder.childOrders.allSatisfy { child in
            child.maintenanceProcedures.allSatisfy { $0.result != nil }
        }
    }

    // MARK: - Dependencies

    private let dataService: DataServiceProtocol

    // MARK: - Initialization

    init(parentWorkOrder: ParentWorkOrder, initialSelectedChildId: UUID? = nil, dataService: DataServiceProtocol = DependencyContainer.shared.dataService) {
        self.parentWorkOrder = parentWorkOrder
        self.originalState = parentWorkOrder
        self.dataService = dataService

        // If initialSelectedChildId is provided, start with that child selected
        // Otherwise start with parent view
        self.selectedChildId = initialSelectedChildId
        self.isViewingParent = (initialSelectedChildId == nil)
    }

    // MARK: - Child Order Selection

    func selectChild(_ childId: UUID?) {
        selectedChildId = childId
        isViewingParent = (childId == nil)
    }

    func selectParentView() {
        selectedChildId = nil
        isViewingParent = true
    }

    // MARK: - Child Order Updates

    func updateChildActualStartDate(_ date: Date?) {
        guard let index = selectedChildIndex else { return }
        parentWorkOrder.childOrders[index].actualStartDate = date
    }

    func updateChildActualCompletionDate(_ date: Date?) {
        guard let index = selectedChildIndex else { return }
        parentWorkOrder.childOrders[index].actualCompletionDate = date
    }

    // MARK: - Maintenance Procedures (Child)

    func updateProcedureResult(_ procedureId: UUID, result: MaintenanceProcedure.ResultType?) {
        guard let childIndex = selectedChildIndex else { return }
        if let procIndex = parentWorkOrder.childOrders[childIndex].maintenanceProcedures.firstIndex(where: { $0.id == procedureId }) {
            parentWorkOrder.childOrders[childIndex].maintenanceProcedures[procIndex].result = result
        }
    }

    func updateProcedureMeasurement(_ procedureId: UUID, value: String) {
        guard let childIndex = selectedChildIndex else { return }
        if let procIndex = parentWorkOrder.childOrders[childIndex].maintenanceProcedures.firstIndex(where: { $0.id == procedureId }) {
            parentWorkOrder.childOrders[childIndex].maintenanceProcedures[procIndex].measurementValue = value
        }
    }

    func updateProcedureNotes(_ procedureId: UUID, notes: String) {
        guard let childIndex = selectedChildIndex else { return }
        if let procIndex = parentWorkOrder.childOrders[childIndex].maintenanceProcedures.firstIndex(where: { $0.id == procedureId }) {
            parentWorkOrder.childOrders[childIndex].maintenanceProcedures[procIndex].notes = notes
        }
    }

    func setAllProceduresResult(_ result: MaintenanceProcedure.ResultType) {
        guard let childIndex = selectedChildIndex else { return }
        for procIndex in parentWorkOrder.childOrders[childIndex].maintenanceProcedures.indices {
            parentWorkOrder.childOrders[childIndex].maintenanceProcedures[procIndex].result = result
        }
    }

    // MARK: - Materials (Child)

    func toggleMaterialSelection(_ materialId: UUID) {
        guard let childIndex = selectedChildIndex else { return }
        if let matIndex = parentWorkOrder.childOrders[childIndex].materials.firstIndex(where: { $0.id == materialId }) {
            parentWorkOrder.childOrders[childIndex].materials[matIndex].isSelected.toggle()
        }
    }

    func addMaterialToChild(_ materialOption: MaterialOption) {
        guard let childIndex = selectedChildIndex else { return }

        let material = Material(
            id: UUID(),
            materialNumber: materialOption.materialNumber,
            description: materialOption.materialName,
            requiredQuantity: materialOption.plannedQuantity,
            usedQuantity: 0,
            unit: materialOption.unit,
            isSelected: true,
            notes: nil
        )

        parentWorkOrder.childOrders[childIndex].materials.append(material)
    }

    func removeMaterial(_ materialId: UUID) {
        guard let childIndex = selectedChildIndex else { return }
        parentWorkOrder.childOrders[childIndex].materials.removeAll { $0.id == materialId }
    }

    func updateMaterialQuantity(_ materialId: UUID, quantity: Double) {
        guard let childIndex = selectedChildIndex else { return }
        if let matIndex = parentWorkOrder.childOrders[childIndex].materials.firstIndex(where: { $0.id == materialId }) {
            parentWorkOrder.childOrders[childIndex].materials[matIndex].usedQuantity = quantity
        }
    }

    // MARK: - Manpower (Parent Level Aggregation)

    func updateManpowerHours(_ manpowerId: UUID, hours: Double) {
        for childIndex in parentWorkOrder.childOrders.indices {
            if let mpIndex = parentWorkOrder.childOrders[childIndex].manpower.firstIndex(where: { $0.id == manpowerId }) {
                parentWorkOrder.childOrders[childIndex].manpower[mpIndex].maintenanceHours = hours
                break
            }
        }
    }

    func updateManpowerNotes(_ manpowerId: UUID, notes: String) {
        for childIndex in parentWorkOrder.childOrders.indices {
            if let mpIndex = parentWorkOrder.childOrders[childIndex].manpower.firstIndex(where: { $0.id == manpowerId }) {
                parentWorkOrder.childOrders[childIndex].manpower[mpIndex].notes = notes
                break
            }
        }
    }

    // MARK: - API Calls

    func loadAvailableMaterials() async {
        isLoadingMaterials = true
        do {
            availableMaterials = try await dataService.fetchAvailableMaterials()
        } catch {
            errorMessage = "無法載入材料清單：\(error.localizedDescription)"
            showError = true
        }
        isLoadingMaterials = false
    }

    // MARK: - Save & Submit

    func save() async {
        guard hasChanges else { return }

        isSaving = true
        do {
            try await dataService.saveParentWorkOrder(parentWorkOrder)
            // Update original state after successful save
            originalState = parentWorkOrder
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isSaving = false
    }

    func submit() async {
        isSaving = true
        do {
            // Validate all child procedures have results
            for child in parentWorkOrder.childOrders {
                let incomplete = child.maintenanceProcedures.filter { $0.result == nil }
                if !incomplete.isEmpty {
                    throw ValidationError.incompleteProcedures
                }
            }

            try await dataService.saveParentWorkOrder(parentWorkOrder)

            // Add approval record
            let approval = ApprovalRecord(
                id: UUID(),
                approverID: "current_user",
                approverName: "當前使用者",
                approvalDate: Date(),
                comment: submitComment,
                status: .pending
            )

            // Add to first child (or we could add to all)
            if !parentWorkOrder.childOrders.isEmpty {
                parentWorkOrder.childOrders[0].approvalRecords.append(approval)
            }

            parentWorkOrder.status = .reported
            originalState = parentWorkOrder

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

    func resetChanges() {
        parentWorkOrder = originalState
    }

    // MARK: - Helper Methods

    private func areParentWorkOrdersEqual(_ lhs: ParentWorkOrder, _ rhs: ParentWorkOrder) -> Bool {
        // Compare all relevant fields
        guard lhs.id == rhs.id,
              lhs.status == rhs.status,
              lhs.childOrders.count == rhs.childOrders.count else {
            return false
        }

        // Compare each child order
        for (lChild, rChild) in zip(lhs.childOrders, rhs.childOrders) {
            if !areChildOrdersEqual(lChild, rChild) {
                return false
            }
        }

        return true
    }

    private func areChildOrdersEqual(_ lhs: WorkOrder, _ rhs: WorkOrder) -> Bool {
        guard lhs.id == rhs.id,
              lhs.status == rhs.status,
              lhs.actualStartDate == rhs.actualStartDate,
              lhs.actualCompletionDate == rhs.actualCompletionDate,
              lhs.maintenanceProcedures.count == rhs.maintenanceProcedures.count,
              lhs.materials.count == rhs.materials.count,
              lhs.manpower.count == rhs.manpower.count else {
            return false
        }

        // Compare procedures
        for (lProc, rProc) in zip(lhs.maintenanceProcedures, rhs.maintenanceProcedures) {
            if lProc.result != rProc.result ||
               lProc.measurementValue != rProc.measurementValue ||
               lProc.notes != rProc.notes {
                return false
            }
        }

        // Compare materials
        for (lMat, rMat) in zip(lhs.materials, rhs.materials) {
            if lMat.isSelected != rMat.isSelected ||
               lMat.usedQuantity != rMat.usedQuantity {
                return false
            }
        }

        // Compare manpower
        for (lMan, rMan) in zip(lhs.manpower, rhs.manpower) {
            if lMan.maintenanceHours != rMan.maintenanceHours ||
               lMan.notes != rMan.notes {
                return false
            }
        }

        return true
    }
}

// MARK: - Child Order Helper Properties

extension ParentWorkOrderDetailViewModel {
    var currentChildProcedures: [MaintenanceProcedure] {
        selectedChild?.maintenanceProcedures ?? []
    }

    var currentChildMaterials: [Material] {
        selectedChild?.materials ?? []
    }

    var currentChildPendingProcedureCount: Int {
        currentChildProcedures.filter { $0.result == nil }.count
    }

    var currentChildTotalProcedureCount: Int {
        currentChildProcedures.count
    }
}
