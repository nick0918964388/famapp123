import Foundation

final class MockDataService: DataServiceProtocol {
    private var mockParentWorkOrders: [ParentWorkOrder] = []
    private let localStorage = LocalStorageService.shared

    init() {
        loadData()
    }

    private func loadData() {
        // Force reload mock data to fix asset number issue
        // TODO: Remove this after testing, restore localStorage loading
        loadMockData()
        try? localStorage.saveParentWorkOrders(mockParentWorkOrders)
    }

    private func loadMockData() {
        // Create mock work orders based on the reference design
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"

        let baseDate = dateFormatter.date(from: "2016/07/22 10:24") ?? Date()

        // Parent Work Order 1
        let parent1Children = [
            createMockWorkOrder(
                orderNumber: "F15-ASSET100",
                assetNumber: "F15-ASSET100",
                status: .pendingReport,
                reporterID: "MAXADAMO",
                baseDate: baseDate
            ),
            createMockWorkOrder(
                orderNumber: "F15-ASSET101",
                assetNumber: "F15-ASSET101",
                status: .reported,
                reporterID: "MAXADAMO",
                baseDate: baseDate
            ),
            createMockWorkOrder(
                orderNumber: "F15-ASSET102",
                assetNumber: "F15-ASSET102",
                status: .reported,
                reporterID: "MAXADAMO",
                baseDate: baseDate
            )
        ]

        let parent1 = ParentWorkOrder(
            id: UUID(),
            orderNumber: "WO20170000013420",
            orderType: .preventiveMaintenance,
            childOrders: parent1Children,
            status: .pendingReport,
            childCount: 3
        )

        // Parent Work Order 2
        let parent2Children = [
            createMockWorkOrder(
                orderNumber: "P1THC-ZERO-C01",
                assetNumber: "P1THC-ZERO-C01",
                status: .pendingReport,
                reporterID: "Y_TILSMJ",
                baseDate: baseDate
            )
        ]

        let parent2 = ParentWorkOrder(
            id: UUID(),
            orderNumber: "WO20170000013424",
            orderType: .preventiveMaintenance,
            childOrders: parent2Children,
            status: .pendingReport,
            childCount: 1
        )

        // Parent Work Order 3 (PM母工單)
        let parent3Children = [
            createMockWorkOrder(
                orderNumber: "F15-ASSET100",
                assetNumber: "F15-ASSET100",
                status: .pendingReport,
                reporterID: "MAXADAMO",
                baseDate: baseDate
            ),
            createMockWorkOrder(
                orderNumber: "F15-ASSET101",
                assetNumber: "F15-ASSET101",
                status: .reported,
                reporterID: "MAXADAMO",
                baseDate: baseDate
            ),
            createMockWorkOrder(
                orderNumber: "F15-ASSET102",
                assetNumber: "F15-ASSET102",
                status: .reported,
                reporterID: "MAXADAMO",
                baseDate: baseDate
            )
        ]

        let parent3 = ParentWorkOrder(
            id: UUID(),
            orderNumber: "WO20170000013310",
            orderType: .preventiveMaintenance,
            childOrders: parent3Children,
            status: .pendingReport,
            childCount: 13
        )

        // Parent Work Order 4
        let parent4Children = [
            createMockWorkOrder(
                orderNumber: "F15-ASSET100",
                assetNumber: "F15-ASSET100",
                status: .pendingReport,
                reporterID: "Y_TILSMJ",
                baseDate: baseDate
            ),
            createMockWorkOrder(
                orderNumber: "F15-ASSET100",
                assetNumber: "F15-ASSET100",
                status: .pendingReport,
                reporterID: "MAXADAMO",
                baseDate: baseDate
            ),
            createMockWorkOrder(
                orderNumber: "F15-ASSET101",
                assetNumber: "F15-ASSET101",
                status: .reported,
                reporterID: "MAXADAMO",
                baseDate: baseDate
            ),
            createMockWorkOrder(
                orderNumber: "F15-ASSET102",
                assetNumber: "F15-ASSET102",
                status: .reported,
                reporterID: "MAXADAMO",
                baseDate: baseDate
            )
        ]

        let parent4 = ParentWorkOrder(
            id: UUID(),
            orderNumber: "WO20170000013311",
            orderType: .preventiveMaintenance,
            childOrders: parent4Children,
            status: .pendingReport,
            childCount: 3
        )

        let parent5 = ParentWorkOrder(
            id: UUID(),
            orderNumber: "WO20170000013312",
            orderType: .preventiveMaintenance,
            childOrders: [
                createMockWorkOrder(
                    orderNumber: "F15-ASSET100",
                    assetNumber: "F15-ASSET100",
                    status: .pendingReport,
                    reporterID: "MAXADAMO",
                    baseDate: baseDate
                )
            ],
            status: .pendingReport,
            childCount: 3
        )

        mockParentWorkOrders = [parent1, parent2, parent3, parent4, parent5]
    }

    private func createMockWorkOrder(
        orderNumber: String,
        assetNumber: String,
        status: WorkOrderStatus,
        reporterID: String,
        baseDate: Date
    ) -> WorkOrder {
        WorkOrder(
            id: UUID(),
            orderNumber: orderNumber,
            assetNumber: assetNumber,
            equipmentGroup: "00203V03-R5034",
            workPlan: "300MM FAC Zero Air產生器保養紀錄(1M)",
            description: "我是備註說明文字兩行超過後...",
            scheduledDate: baseDate,
            executionDeadline: baseDate,
            reporterEngineer: "回報保養工程師",
            reporterID: reporterID,
            status: status,
            equipmentDescription: "F15P1 CUP ZEROC01 零產生器(VO...",
            groupDescription: "F-CHV-03-03-006 F15P1 CUP Zero ...",
            planDescription: "F15P1 CUP Zero Air產生器保養#C01",
            maintenanceProcedures: createMockProcedures(),
            materials: createMockMaterials(),
            manpower: createMockManpower(),
            tools: createMockTools(),
            approvalRecords: [],
            actualStartDate: nil,
            actualCompletionDate: nil,
            isDownloaded: false,
            lastModified: Date(),
            syncStatus: .synced,
            uploadHistory: []
        )
    }

    private func createMockProcedures() -> [MaintenanceProcedure] {
        [
            MaintenanceProcedure(
                id: UUID(),
                sequence: 10,
                procedureDescription: "施工前溫度",
                specification: "輸入溫度監測值(度C)",
                result: nil,
                measurementValue: nil,
                notes: nil,
                hasScadaIntegration: false
            ),
            MaintenanceProcedure(
                id: UUID(),
                sequence: 20,
                procedureDescription: "施工後溫度檢測",
                specification: "輸入溫度監測值(度C)",
                result: nil,
                measurementValue: nil,
                notes: nil,
                hasScadaIntegration: true
            ),
            MaintenanceProcedure(
                id: UUID(),
                sequence: 30,
                procedureDescription: "施工前設備壓力檢測",
                specification: "標準值1±9psi",
                result: nil,
                measurementValue: nil,
                notes: nil,
                hasScadaIntegration: false
            ),
            MaintenanceProcedure(
                id: UUID(),
                sequence: 40,
                procedureDescription: "施工後設備壓力檢測",
                specification: "標準值1±9psi",
                result: nil,
                measurementValue: nil,
                notes: nil,
                hasScadaIntegration: false
            )
        ]
    }

    private func createMockMaterials() -> [Material] {
        [
            Material(
                id: UUID(),
                materialNumber: "MAT001",
                description: "密封墊片",
                requiredQuantity: 2,
                usedQuantity: 0,
                unit: "個",
                isSelected: false,
                notes: nil
            ),
            Material(
                id: UUID(),
                materialNumber: "MAT002",
                description: "潤滑油",
                requiredQuantity: 1,
                usedQuantity: 0,
                unit: "罐",
                isSelected: false,
                notes: nil
            )
        ]
    }

    private func createMockManpower() -> [Manpower] {
        [
            Manpower(
                id: UUID(),
                personnelID: "B9439680",
                name: "廠商-xxxx",
                maintenanceHours: 8.0,
                notes: "輸入文字",
                startDate: Date(),
                endDate: Date()
            ),
            Manpower(
                id: UUID(),
                personnelID: "B9439680",
                name: "廠商-xxxx",
                maintenanceHours: 12.0,
                notes: "說明文字",
                startDate: Date(),
                endDate: Date()
            )
        ]
    }

    private func createMockTools() -> [Tool] {
        [
            Tool(
                id: UUID(),
                toolType: "廠商校驗",
                toolCategory: "電表-三用電錶",
                toolInfo: "25813028",
                instrumentName: "F15P1/2三用電錶",
                isSelected: true,
                notes: nil
            ),
            Tool(
                id: UUID(),
                toolType: "廠商校驗",
                toolCategory: "電表-三用電錶",
                toolInfo: "25813028",
                instrumentName: "F15P1/2三用電錶",
                isSelected: true,
                notes: nil
            )
        ]
    }

    // MARK: - DataServiceProtocol

    func fetchWorkOrders(filter: FilterType?) async throws -> [WorkOrder] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        var allOrders: [WorkOrder] = []
        for parent in mockParentWorkOrders {
            allOrders.append(contentsOf: parent.childOrders)
        }

        guard let filter = filter else {
            return allOrders
        }

        // Apply filter (simplified for mock)
        switch filter {
        case .beforeToday, .all:
            return allOrders
        case .lastWeek:
            return Array(allOrders.prefix(3))
        case .overdue:
            return allOrders.filter { $0.status == .pendingReport }
        case .todayCompleted:
            return allOrders.filter { $0.status == .reported }
        }
    }

    func fetchParentWorkOrders(filter: FilterType?) async throws -> [ParentWorkOrder] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        guard let filter = filter else {
            return mockParentWorkOrders
        }

        // Apply filter to parent work orders based on child order criteria
        switch filter {
        case .all:
            return mockParentWorkOrders
        case .beforeToday:
            // Return all orders with scheduledDate <= today
            return mockParentWorkOrders.map { parent in
                var filtered = parent
                filtered.childOrders = parent.childOrders.filter { $0.scheduledDate <= Date() }
                return filtered
            }.filter { !$0.childOrders.isEmpty }
        case .lastWeek:
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return mockParentWorkOrders.map { parent in
                var filtered = parent
                filtered.childOrders = parent.childOrders.filter { $0.scheduledDate >= oneWeekAgo }
                return filtered
            }.filter { !$0.childOrders.isEmpty }
        case .overdue:
            return mockParentWorkOrders.map { parent in
                var filtered = parent
                filtered.childOrders = parent.childOrders.filter {
                    $0.status == .pendingReport && $0.executionDeadline < Date()
                }
                return filtered
            }.filter { !$0.childOrders.isEmpty }
        case .todayCompleted:
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
            return mockParentWorkOrders.map { parent in
                var filtered = parent
                filtered.childOrders = parent.childOrders.filter {
                    $0.status == .reported && $0.lastModified >= today && $0.lastModified < tomorrow
                }
                return filtered
            }.filter { !$0.childOrders.isEmpty }
        }
    }

    func fetchWorkOrderDetail(id: String) async throws -> WorkOrder {
        try await Task.sleep(nanoseconds: 300_000_000)

        for parent in mockParentWorkOrders {
            if let order = parent.childOrders.first(where: { $0.id.uuidString == id }) {
                return order
            }
        }

        throw DataServiceError.notFound
    }

    func saveWorkOrder(_ workOrder: WorkOrder) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)

        // Update in-memory data
        for parentIndex in mockParentWorkOrders.indices {
            if let childIndex = mockParentWorkOrders[parentIndex].childOrders.firstIndex(where: { $0.id == workOrder.id }) {
                mockParentWorkOrders[parentIndex].childOrders[childIndex] = workOrder

                // Update parent status based on children
                let allReported = mockParentWorkOrders[parentIndex].childOrders.allSatisfy { $0.status == .reported }
                mockParentWorkOrders[parentIndex].status = allReported ? .reported : .pendingReport
                break
            }
        }

        // Persist to local storage
        try localStorage.saveParentWorkOrders(mockParentWorkOrders)
    }

    func downloadWorkOrder(id: String) async throws -> WorkOrder {
        var order = try await fetchWorkOrderDetail(id: id)
        order.isDownloaded = true
        return order
    }

    // MARK: - Material Options API

    func fetchAvailableMaterials() async throws -> [MaterialOption] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        return createMockMaterialOptions()
    }

    private func createMockMaterialOptions() -> [MaterialOption] {
        [
            MaterialOption(
                materialNumber: "MAT-001",
                materialName: "密封墊片 A型",
                plannedQuantity: 10,
                unit: "個"
            ),
            MaterialOption(
                materialNumber: "MAT-002",
                materialName: "潤滑油 Shell Omala S4",
                plannedQuantity: 5,
                unit: "罐"
            ),
            MaterialOption(
                materialNumber: "MAT-003",
                materialName: "濾芯 10微米",
                plannedQuantity: 2,
                unit: "組"
            ),
            MaterialOption(
                materialNumber: "MAT-004",
                materialName: "O型環 Viton",
                plannedQuantity: 20,
                unit: "個"
            ),
            MaterialOption(
                materialNumber: "MAT-005",
                materialName: "軸承 SKF 6205",
                plannedQuantity: 4,
                unit: "個"
            ),
            MaterialOption(
                materialNumber: "MAT-006",
                materialName: "皮帶 3V-500",
                plannedQuantity: 2,
                unit: "條"
            ),
            MaterialOption(
                materialNumber: "MAT-007",
                materialName: "電磁閥 24V DC",
                plannedQuantity: 1,
                unit: "組"
            ),
            MaterialOption(
                materialNumber: "MAT-008",
                materialName: "壓力錶 0-10 bar",
                plannedQuantity: 1,
                unit: "個"
            ),
            MaterialOption(
                materialNumber: "MAT-009",
                materialName: "溫度感測器 PT100",
                plannedQuantity: 2,
                unit: "支"
            ),
            MaterialOption(
                materialNumber: "MAT-010",
                materialName: "保險絲 5A",
                plannedQuantity: 10,
                unit: "個"
            )
        ]
    }

    // MARK: - Parent Work Order Save

    func saveParentWorkOrder(_ parentWorkOrder: ParentWorkOrder) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        // Update in-memory data
        if let index = mockParentWorkOrders.firstIndex(where: { $0.id == parentWorkOrder.id }) {
            mockParentWorkOrders[index] = parentWorkOrder
        }

        // Persist to local storage
        try localStorage.saveParentWorkOrders(mockParentWorkOrders)
    }
}

enum DataServiceError: LocalizedError {
    case notFound
    case networkError
    case serverError

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "找不到工單"
        case .networkError:
            return "網路連線錯誤"
        case .serverError:
            return "伺服器錯誤"
        }
    }
}

