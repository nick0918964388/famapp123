import Foundation
import SwiftUI

@MainActor
final class WorkOrderListViewModel: ObservableObject {
    @Published var parentWorkOrders: [ParentWorkOrder] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedFilter: FilterType = .beforeToday
    @Published var searchText: String = ""
    @Published var expandedParentIds: Set<UUID> = []
    @Published var selectedParentForNavigation: ParentWorkOrder?
    @Published var showAdvancedSearch: Bool = false
    @Published var advancedSearch: AdvancedSearchCriteria = AdvancedSearchCriteria()
    @Published var isAdvancedSearchActive: Bool = false

    private let dataService: DataServiceProtocol

    var availableDepartments: [String] {
        ["FAC課", "設備課", "製程課", "品保課", "生產課"]
    }

    var filteredParentWorkOrders: [ParentWorkOrder] {
        var orders = parentWorkOrders

        // Apply search filter
        if !searchText.isEmpty {
            orders = orders.map { parent in
                var filtered = parent
                filtered.childOrders = parent.childOrders.filter { child in
                    child.orderNumber.localizedCaseInsensitiveContains(searchText) ||
                    child.assetNumber.localizedCaseInsensitiveContains(searchText) ||
                    child.description.localizedCaseInsensitiveContains(searchText) ||
                    child.reporterID.localizedCaseInsensitiveContains(searchText)
                }
                return filtered
            }.filter { parent in
                parent.orderNumber.localizedCaseInsensitiveContains(searchText) ||
                !parent.childOrders.isEmpty
            }
        }

        // Apply advanced search filters
        if isAdvancedSearchActive {
            orders = orders.map { parent in
                var filtered = parent
                filtered.childOrders = parent.childOrders.filter { child in
                    // Date range filter
                    let inDateRange = child.scheduledDate >= advancedSearch.startDate &&
                                      child.scheduledDate <= advancedSearch.endDate

                    // Personnel filter
                    let matchesPersonnel = advancedSearch.personnel.isEmpty ||
                        child.reporterID.localizedCaseInsensitiveContains(advancedSearch.personnel) ||
                        child.reporterEngineer.localizedCaseInsensitiveContains(advancedSearch.personnel)

                    // Status filter
                    let matchesStatus = advancedSearch.status == nil ||
                        child.status == advancedSearch.status

                    return inDateRange && matchesPersonnel && matchesStatus
                }
                return filtered
            }.filter { !$0.childOrders.isEmpty }
        }

        return orders
    }

    var filterCounts: [FilterType: Int] {
        var counts: [FilterType: Int] = [:]
        let allOrders = parentWorkOrders.flatMap { $0.childOrders }

        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) ?? Date()

        // 本日(含)以前：預計執行日 <= 今天
        counts[.beforeToday] = allOrders.filter { $0.scheduledDate < tomorrow }.count

        // 近一週：預計執行日在過去7天內
        counts[.lastWeek] = allOrders.filter { $0.scheduledDate >= oneWeekAgo && $0.scheduledDate < tomorrow }.count

        // 逾期：執行期限已過 且 尚未回報
        counts[.overdue] = allOrders.filter { $0.executionDeadline < today && $0.displayStatus == .pendingReport }.count

        // 全部
        counts[.all] = allOrders.count

        // 本日完成：今天回報完成的
        counts[.todayCompleted] = allOrders.filter {
            $0.displayStatus == .reported && $0.lastModified >= today && $0.lastModified < tomorrow
        }.count

        return counts
    }

    init(dataService: DataServiceProtocol = DependencyContainer.shared.dataService) {
        self.dataService = dataService
    }

    func loadWorkOrders() async {
        isLoading = true
        errorMessage = nil

        do {
            parentWorkOrders = try await dataService.fetchParentWorkOrders(filter: selectedFilter)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshWorkOrders() async {
        await loadWorkOrders()
    }

    func selectFilter(_ filter: FilterType) {
        selectedFilter = filter
        Task {
            await loadWorkOrders()
        }
    }

    func toggleParentExpanded(_ parentId: UUID) {
        if expandedParentIds.contains(parentId) {
            expandedParentIds.remove(parentId)
        } else {
            expandedParentIds.insert(parentId)
        }
    }

    func isParentExpanded(_ parentId: UUID) -> Bool {
        expandedParentIds.contains(parentId)
    }

    // MARK: - Advanced Search

    func performAdvancedSearch() async {
        isAdvancedSearchActive = true
        await loadWorkOrders()
    }

    func resetAdvancedSearch() {
        advancedSearch.reset()
        isAdvancedSearchActive = false
    }

    func clearSearch() {
        searchText = ""
        isAdvancedSearchActive = false
        advancedSearch.reset()
    }
}
