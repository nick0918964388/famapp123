import SwiftUI

/// Parent Work Order Detail View - Main view for parent and child order management
struct ParentWorkOrderDetailView: View {
    @StateObject private var viewModel: ParentWorkOrderDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isChildHeaderCollapsed = true

    init(parentWorkOrder: ParentWorkOrder) {
        _viewModel = StateObject(wrappedValue: ParentWorkOrderDetailViewModel(parentWorkOrder: parentWorkOrder))
    }

    var body: some View {
        mainContent
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .alert("錯誤", isPresented: $viewModel.showError) {
                Button("確定", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $viewModel.showSubmitDialog) {
                ParentSubmitApprovalSheet(viewModel: viewModel)
            }
            .overlay(savingOverlay)
            .onChange(of: viewModel.selectedChildId) { newValue in
                viewModel.isViewingParent = (newValue == nil)
            }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            childOrderSelectorSection
            headerSection
            currentTabBar
            tabContent
            Spacer(minLength: 0)
        }
    }

    private var childOrderSelectorSection: some View {
        ChildOrderSelector(
            childOrders: viewModel.parentWorkOrder.childOrders,
            selectedChildId: $viewModel.selectedChildId,
            onParentTap: {
                viewModel.selectParentView()
            }
        )
    }

    private var currentTabBar: some View {
        Group {
            if viewModel.isViewingParent {
                parentTabBar
            } else {
                childTabBar
            }
        }
    }

    private var savingOverlay: some View {
        Group {
            if viewModel.isSaving {
                LoadingCardOverlay(icon: "arrow.clockwise", message: "儲存中...")
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            principalToolbarItem
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            trailingToolbarItems
        }
    }

    private var principalToolbarItem: some View {
        HStack {
            Text(viewModel.parentWorkOrder.orderNumber)
                .font(.headline)
            StatusBadge(status: viewModel.parentWorkOrder.status)
        }
    }

    private var trailingToolbarItems: some View {
        HStack(spacing: 16) {
            if viewModel.hasChanges {
                Button("儲存") {
                    Task { await viewModel.save() }
                }
                .foregroundColor(.orange)
            }

            if viewModel.isViewingParent {
                Button("呈核") {
                    viewModel.showSubmitDialog = true
                }
                .foregroundColor(.orange)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        Group {
            if viewModel.isViewingParent {
                parentHeaderSection
            } else if let child = viewModel.selectedChild {
                childHeaderSection(child)
            }
        }
    }

    private var parentHeaderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                InfoColumn(label: "工單編號", value: viewModel.parentWorkOrder.orderNumber)
                InfoColumn(label: "工單類型", value: viewModel.parentWorkOrder.orderType.displayName)
            }

            HStack(alignment: .top) {
                InfoColumn(label: "子工單數", value: "\(viewModel.totalChildCount) 筆")
                InfoColumn(label: "待回報", value: "\(viewModel.pendingChildCount) 筆")
            }
        }
        .padding()
        .background(AppColors.secondaryBackground)
    }

    private func childHeaderSection(_ child: WorkOrder) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Collapse toggle bar
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isChildHeaderCollapsed.toggle()
                }
            }) {
                HStack {
                    Text("基本資訊")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    if isChildHeaderCollapsed {
                        Text("- \(child.assetNumber)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: isChildHeaderCollapsed ? "chevron.down" : "chevron.up")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(AppColors.secondaryBackground)
            }
            .buttonStyle(.plain)

            // Expandable content
            if !isChildHeaderCollapsed {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        InfoColumn(label: "資產編號", value: child.assetNumber)
                        InfoColumn(label: "說明", value: child.equipmentDescription)
                    }

                    HStack(alignment: .top) {
                        InfoColumn(label: "設備群組", value: child.equipmentGroup)
                        InfoColumn(label: "說明", value: child.groupDescription)
                    }

                    HStack(alignment: .top) {
                        InfoColumn(label: "工作計劃", value: child.workPlan)
                        InfoColumn(label: "說明", value: child.planDescription)
                    }

                    HStack(alignment: .top) {
                        InfoColumn(label: "預計執行日", value: formatDate(child.scheduledDate))
                        InfoColumn(label: "回報保養工程師", value: child.reporterEngineer)
                    }

                    HStack(alignment: .top) {
                        InfoColumn(label: "工單執行期限", value: formatDate(child.executionDeadline))
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
                .background(AppColors.secondaryBackground)
            }

            Divider()
        }
    }

    // MARK: - Parent Tab Bar

    private var parentTabBar: some View {
        HStack(spacing: 0) {
            ForEach(ParentWorkOrderDetailViewModel.ParentTab.allCases) { tab in
                TabButton(
                    title: tab.rawValue,
                    isSelected: viewModel.selectedParentTab == tab,
                    action: { viewModel.selectedParentTab = tab }
                )
            }
        }
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Child Tab Bar

    private var childTabBar: some View {
        HStack(spacing: 0) {
            ForEach(ParentWorkOrderDetailViewModel.ChildTab.allCases) { tab in
                TabButton(
                    title: tab.rawValue,
                    isSelected: viewModel.selectedChildTab == tab,
                    action: { viewModel.selectedChildTab = tab }
                )
            }
        }
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        if viewModel.isViewingParent {
            parentTabContent
        } else {
            childTabContent
        }
    }

    @ViewBuilder
    private var parentTabContent: some View {
        switch viewModel.selectedParentTab {
        case .manpowerReport:
            ManpowerTabView(viewModel: createLegacyViewModel())
        case .materialStats:
            MaterialStatsTabView(viewModel: viewModel)
        case .approvalRecords:
            ApprovalRecordsTabView(viewModel: createLegacyViewModel())
        case .overview:
            ParentOverviewTabView(viewModel: viewModel)
        }
    }

    @ViewBuilder
    private var childTabContent: some View {
        switch viewModel.selectedChildTab {
        case .workItems:
            WorkItemsReportTabView(viewModel: viewModel)
        case .plannedMaterial:
            PlannedMaterialReportTabView(viewModel: viewModel)
        case .dates:
            DatesReportTabView(viewModel: viewModel)
        }
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }

    // Legacy ViewModel for existing tab views
    private func createLegacyViewModel() -> WorkOrderDetailViewModel {
        let child = viewModel.selectedChild ?? viewModel.parentWorkOrder.childOrders.first!
        return WorkOrderDetailViewModel(workOrder: child)
    }
}

// MARK: - Parent Submit Approval Sheet

struct ParentSubmitApprovalSheet: View {
    @ObservedObject var viewModel: ParentWorkOrderDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("完成工作流程設定")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("作業：")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("請您執行-說明: \(viewModel.parentWorkOrder.orderNumber)")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(AppColors.secondaryBackground)
                .cornerRadius(8)

                // Validation status
                if !viewModel.allProceduresCompleted {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("尚有未完成的保養作業程序")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("輸入簽核意見")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextEditor(text: $viewModel.submitComment)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(AppColors.secondaryBackground)
                        .cornerRadius(8)
                }

                Spacer()

                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "呈核",
                        isLoading: viewModel.isSaving,
                        isDisabled: !viewModel.allProceduresCompleted
                    ) {
                        Task { await viewModel.submit() }
                    }

                    SecondaryButton(title: "取消") {
                        dismiss()
                    }
                }
            }
            .padding()
            .navigationTitle("呈核")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
