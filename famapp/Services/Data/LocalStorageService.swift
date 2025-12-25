import Foundation

final class LocalStorageService {
    static let shared = LocalStorageService()

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var workOrdersDirectory: URL {
        documentsDirectory.appendingPathComponent("WorkOrders", isDirectory: true)
    }

    private var parentWorkOrdersFile: URL {
        workOrdersDirectory.appendingPathComponent("parent_work_orders.json")
    }

    private init() {
        createDirectoryIfNeeded()
    }

    private func createDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: workOrdersDirectory.path) {
            try? fileManager.createDirectory(at: workOrdersDirectory, withIntermediateDirectories: true)
        }
    }

    // MARK: - Save Operations

    func saveParentWorkOrders(_ orders: [ParentWorkOrder]) throws {
        let data = try encoder.encode(orders)
        try data.write(to: parentWorkOrdersFile)
    }

    func saveWorkOrder(_ workOrder: WorkOrder) throws {
        var orders = loadParentWorkOrders()

        // Find and update the work order in parent orders
        for parentIndex in orders.indices {
            if let childIndex = orders[parentIndex].childOrders.firstIndex(where: { $0.id == workOrder.id }) {
                orders[parentIndex].childOrders[childIndex] = workOrder
                try saveParentWorkOrders(orders)
                return
            }
        }

        throw LocalStorageError.workOrderNotFound
    }

    // MARK: - Load Operations

    func loadParentWorkOrders() -> [ParentWorkOrder] {
        guard fileManager.fileExists(atPath: parentWorkOrdersFile.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: parentWorkOrdersFile)
            return try decoder.decode([ParentWorkOrder].self, from: data)
        } catch {
            print("Failed to load parent work orders: \(error)")
            return []
        }
    }

    func loadWorkOrder(id: UUID) -> WorkOrder? {
        let orders = loadParentWorkOrders()
        for parent in orders {
            if let workOrder = parent.childOrders.first(where: { $0.id == id }) {
                return workOrder
            }
        }
        return nil
    }

    // MARK: - Check if data exists

    func hasStoredData() -> Bool {
        fileManager.fileExists(atPath: parentWorkOrdersFile.path)
    }

    // MARK: - Clear data

    func clearAllData() throws {
        if fileManager.fileExists(atPath: parentWorkOrdersFile.path) {
            try fileManager.removeItem(at: parentWorkOrdersFile)
        }
    }
}

enum LocalStorageError: LocalizedError {
    case workOrderNotFound
    case saveFailed
    case loadFailed

    var errorDescription: String? {
        switch self {
        case .workOrderNotFound:
            return "找不到工單"
        case .saveFailed:
            return "儲存失敗"
        case .loadFailed:
            return "讀取失敗"
        }
    }
}
