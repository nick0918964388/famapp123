import Foundation

final class DependencyContainer: ObservableObject {
    static let shared = DependencyContainer()

    // MARK: - Services
    lazy var networkMonitor: NetworkMonitor = {
        NetworkMonitor.shared
    }()

    lazy var authService: AuthService = {
        AuthService()
    }()

    lazy var dataService: DataServiceProtocol = {
        // Use MockDataService for development
        // Switch to APIDataService when ready for production
        MockDataService()
    }()

    private init() {}
}

// MARK: - Data Service Protocol
protocol DataServiceProtocol {
    func fetchWorkOrders(filter: FilterType?) async throws -> [WorkOrder]
    func fetchParentWorkOrders(filter: FilterType?) async throws -> [ParentWorkOrder]
    func fetchWorkOrderDetail(id: String) async throws -> WorkOrder
    func saveWorkOrder(_ workOrder: WorkOrder) async throws
    func downloadWorkOrder(id: String) async throws -> WorkOrder

    // New methods for material selection and parent work order
    func fetchAvailableMaterials() async throws -> [MaterialOption]
    func saveParentWorkOrder(_ parentWorkOrder: ParentWorkOrder) async throws

