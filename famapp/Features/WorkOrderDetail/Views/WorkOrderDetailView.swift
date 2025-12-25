import SwiftUI

struct WorkOrderDetailView: View {
    @StateObject private var viewModel: WorkOrderDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(workOrder: WorkOrder) {
        _viewModel = StateObject(wrappedValue: WorkOrderDetailViewModel(workOrder: workOrder))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header info
            headerSection

            // Main tabs
            mainTabBar

            // Content
            tabContent

            // Bottom navigation bar
            if !viewModel.nextStepTitle.isEmpty {
                bottomNavigationBar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(viewModel.workOrder.orderNumber)
                        .font(.headline)
                    StatusBadge(status: viewModel.workOrder.status)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button("儲存") {
                        Task { await viewModel.save() }
                    }
                    .foregroundColor(.orange)

                    Button("呈核") {
                        viewModel.showSubmitDialog = true
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .alert("錯誤", isPresented: $viewModel.showError) {
            Button("確定", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $viewModel.showSubmitDialog) {
            SubmitApprovalSheet(viewModel: viewModel)
        }
        .overlay(
            Group {
                if viewModel.isSaving {
                    LoadingOverlay(message: "儲存中...")
                }
            }
        )
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Row 1
            HStack(alignment: .top) {
                InfoColumn(label: "資產編號", value: viewModel.workOrder.assetNumber)
                InfoColumn(label: "說明", value: viewModel.workOrder.equipmentDescription)
            }

            // Row 2
            HStack(alignment: .top) {
                InfoColumn(label: "設備群組", value: viewModel.workOrder.equipmentGroup)
                InfoColumn(label: "說明", value: viewModel.workOrder.groupDescription)
            }

            // Row 3
            HStack(alignment: .top) {
                InfoColumn(label: "工作計劃", value: viewModel.workOrder.workPlan)
                InfoColumn(label: "說明", value: viewModel.workOrder.planDescription)
            }

            // Row 4
            HStack(alignment: .top) {
                InfoColumn(label: "預計執行日", value: formatDate(viewModel.workOrder.scheduledDate))
                InfoColumn(label: "回報保養工程師", value: viewModel.workOrder.reporterEngineer)
            }

            // Row 5
            HStack(alignment: .top) {
                InfoColumn(label: "工單執行期限", value: formatDate(viewModel.workOrder.executionDeadline))
                Spacer()
            }
        }
        .padding()
        .background(AppColors.secondaryBackground)
    }

    // MARK: - Main Tab Bar

    private var mainTabBar: some View {
        HStack(spacing: 0) {
            ForEach(WorkOrderDetailViewModel.DetailTab.allCases) { tab in
                TabButton(
                    title: tab.rawValue,
                    isSelected: viewModel.selectedTab == tab,
                    action: { viewModel.selectedTab = tab }
                )
            }
        }
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .manpower:
            ManpowerTabView(viewModel: viewModel)
        case .tools:
            ToolsTabView(viewModel: viewModel)
        case .approvalRecords:
            ApprovalRecordsTabView(viewModel: viewModel)
        case .overview:
            OverviewTabView(viewModel: viewModel)
        }
    }

    // MARK: - Bottom Navigation Bar

    private var bottomNavigationBar: some View {
        Button(action: viewModel.nextStep) {
            Text(viewModel.nextStepTitle)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.8))
        }
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct InfoColumn: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .fontWeight(isSelected ? .semibold : .regular)

                Rectangle()
                    .fill(isSelected ? Color.primary : Color.clear)
                    .frame(height: 2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Submit Approval Sheet

struct SubmitApprovalSheet: View {
    @ObservedObject var viewModel: WorkOrderDetailViewModel
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
                    Text("請您執行-說明:\(viewModel.workOrder.orderNumber) \(viewModel.workOrder.planDescription)")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(AppColors.secondaryBackground)
                .cornerRadius(8)

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
                        isLoading: viewModel.isSaving
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
