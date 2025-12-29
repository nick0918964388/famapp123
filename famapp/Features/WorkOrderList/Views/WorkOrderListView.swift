import SwiftUI

struct WorkOrderListView: View {
    @StateObject private var viewModel = WorkOrderListViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header with logo and search
            headerSection

            // Active filter indicator
            if viewModel.isAdvancedSearchActive {
                advancedSearchIndicator
            }

            // Filter bar
            FilterBarView(
                selectedFilter: $viewModel.selectedFilter,
                filterCounts: viewModel.filterCounts,
                onFilterSelected: viewModel.selectFilter
            )

            Divider()

            // Work order list
            if viewModel.isLoading && viewModel.parentWorkOrders.isEmpty {
                ScrollView {
                    WorkOrderListSkeleton(rowCount: 6)
                }
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else if viewModel.filteredParentWorkOrders.isEmpty {
                emptyView
            } else {
                workOrderList
            }
        }
        .navigationTitle("PM工單回報管理")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadWorkOrders()
        }
        .refreshable {
            await viewModel.refreshWorkOrders()
        }
        .sheet(isPresented: $viewModel.showAdvancedSearch) {
            AdvancedSearchView(viewModel: viewModel)
        }
    }

    private var advancedSearchIndicator: some View {
        HStack {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .foregroundColor(.orange)
            Text("進階篩選已啟用")
                .font(.caption)
                .foregroundColor(.orange)
            Spacer()
            Button("清除") {
                viewModel.clearSearch()
                Task { await viewModel.loadWorkOrders() }
            }
            .font(.caption)
            .foregroundColor(.orange)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.1))
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Logo
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
                .padding(.top, 8)

            // Search bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("請輸入或掃描設備編號條碼", text: $viewModel.searchText)
                        .textFieldStyle(.plain)

                    if !viewModel.searchText.isEmpty {
                        Button(action: { viewModel.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }

                    // Barcode scan button
                    Button(action: { /* TODO: Implement barcode scan */ }) {
                        Image(systemName: "barcode.viewfinder")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)

                // Advanced search link
                Button("進階查詢") {
                    viewModel.showAdvancedSearch = true
                }
                .font(.subheadline)
                .foregroundColor(.orange)
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
    }

    private var workOrderList: some View {
        List {
            ForEach(viewModel.filteredParentWorkOrders) { parent in
                workOrderSection(for: parent)
            }
        }
        .listStyle(.plain)
        .background(
            NavigationLink(
                destination: Group {
                    if let parentOrder = viewModel.selectedParentForNavigation {
                        ParentWorkOrderDetailView(parentWorkOrder: parentOrder)
                    }
                },
                isActive: Binding(
                    get: { viewModel.selectedParentForNavigation != nil },
                    set: { if !$0 { viewModel.selectedParentForNavigation = nil } }
                )
            ) {
                EmptyView()
            }
            .hidden()
        )
    }

    @ViewBuilder
    private func workOrderSection(for parent: ParentWorkOrder) -> some View {
        Section {
            if parent.childOrders.count == 1 {
                singleWorkOrderLink(parent: parent)
            } else {
                parentWorkOrderSection(parent: parent)
            }
        }
    }

    private func singleWorkOrderLink(parent: ParentWorkOrder) -> some View {
        NavigationLink {
            ParentWorkOrderDetailView(parentWorkOrder: parent)
        } label: {
            SingleWorkOrderRow(parent: parent, workOrder: parent.childOrders[0])
        }
    }

    @ViewBuilder
    private func parentWorkOrderSection(parent: ParentWorkOrder) -> some View {
        ParentWorkOrderRow(
            parent: parent,
            isExpanded: viewModel.isParentExpanded(parent.id),
            onToggle: {
                withAnimation {
                    viewModel.toggleParentExpanded(parent.id)
                }
            },
            onNavigate: {
                viewModel.selectedParentForNavigation = parent
            }
        )

        if viewModel.isParentExpanded(parent.id) {
            childWorkOrderRows(for: parent)
        }
    }

    private func childWorkOrderRows(for parent: ParentWorkOrder) -> some View {
        ForEach(parent.childOrders) { child in
            NavigationLink {
                ParentWorkOrderDetailView(parentWorkOrder: parent, initialSelectedChildId: child.id)
            } label: {
                ChildWorkOrderRow(workOrder: child)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 32, bottom: 8, trailing: 16))
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.orange)

            Text("載入失敗")
                .font(.headline)
                .foregroundColor(.primary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: {
                Task { await viewModel.loadWorkOrders() }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("重試")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(Color.orange)
                .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        EmptyStateView(
            icon: "doc.text.magnifyingglass",
            title: "沒有符合條件的工單",
            message: "請嘗試調整搜尋條件或篩選器",
            iconSize: 60
        )
    }
}

// MARK: - Single Work Order Row (for orders with only 1 child)

struct SingleWorkOrderRow: View {
    let parent: ParentWorkOrder
    let workOrder: WorkOrder

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()

    var body: some View {
        HStack(spacing: 8) {
            // 資產編號 + 資產說明
            VStack(alignment: .leading, spacing: 4) {
                Text(workOrder.assetNumber)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(workOrder.equipmentDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(minWidth: 100, alignment: .leading)

            Spacer()

            // 預計執行日
            Text(dateFormatter.string(from: workOrder.scheduledDate))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 75, alignment: .center)

            // 回報人員
            Text(workOrder.reporterID)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 70, alignment: .leading)
                .lineLimit(1)

            // 狀態
            StatusBadge(status: workOrder.displayStatus)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Parent Work Order Row

struct ParentWorkOrderRow: View {
    let parent: ParentWorkOrder
    let isExpanded: Bool
    let onToggle: () -> Void
    let onNavigate: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Expand/collapse button
            Button(action: onToggle) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)

            // Main content - tappable to navigate
            Button(action: onNavigate) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("母工單(\(parent.childCount))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text(parent.orderNumber)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    Spacer()

                    // Status indicator
                    StatusBadge(status: parent.displayStatus)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Child Work Order Row

struct ChildWorkOrderRow: View {
    let workOrder: WorkOrder

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()

    var body: some View {
        HStack(spacing: 8) {
            // Tree line indicator
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 1)
                .padding(.leading, 8)

            // 資產編號 + 資產說明
            VStack(alignment: .leading, spacing: 4) {
                Text(workOrder.assetNumber)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(workOrder.equipmentDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(minWidth: 100, alignment: .leading)

            Spacer()

            // 預計執行日
            Text(dateFormatter.string(from: workOrder.scheduledDate))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 75, alignment: .center)

            // 回報人員
            Text(workOrder.reporterID)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 70, alignment: .leading)
                .lineLimit(1)

            // 狀態
            StatusBadge(status: workOrder.displayStatus)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: WorkOrderStatus

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
            Text(status.displayName)
                .font(.caption)
                .foregroundColor(status.color)
        }
    }
}

