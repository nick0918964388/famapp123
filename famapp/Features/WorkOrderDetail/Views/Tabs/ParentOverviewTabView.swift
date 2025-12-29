import SwiftUI

/// Parent Overview Tab - Shows aggregated statistics of all child orders
struct ParentOverviewTabView: View {
    @ObservedObject var viewModel: ParentWorkOrderDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Summary cards
                summarySection

                // Child orders list
                childOrdersSection
            }
            .padding()
        }
        .background(AppColors.background)
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        VStack(spacing: 12) {
            Text("總覽統計")
                .font(.headline)
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "子工單數",
                    value: "\(viewModel.totalChildCount)",
                    subtitle: "筆",
                    icon: "doc.text.fill",
                    color: .blue
                )

                StatCard(
                    title: "已完成",
                    value: "\(viewModel.completedChildCount)",
                    subtitle: "筆",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatCard(
                    title: "待回報",
                    value: "\(viewModel.pendingChildCount)",
                    subtitle: "筆",
                    icon: "clock.fill",
                    color: .orange
                )

                StatCard(
                    title: "總工時",
                    value: "\(Int(viewModel.totalManpowerHours))",
                    subtitle: "小時",
                    icon: "person.fill",
                    color: .purple
                )
            }

            // Completion progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("完成進度")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(viewModel.completedChildCount)/\(viewModel.totalChildCount)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green)
                            .frame(
                                width: geometry.size.width * progressPercentage,
                                height: 8
                            )
                    }
                }
                .frame(height: 8)
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }

    private var progressPercentage: CGFloat {
        guard viewModel.totalChildCount > 0 else { return 0 }
        return CGFloat(viewModel.completedChildCount) / CGFloat(viewModel.totalChildCount)
    }

    // MARK: - Child Orders Section

    private var childOrdersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("子工單清單")
                .font(.headline)
                .foregroundColor(.orange)

            ForEach(viewModel.parentWorkOrder.childOrders) { child in
                ChildOrderCard(
                    order: child,
                    isSelected: viewModel.selectedChildId == child.id,
                    onTap: {
                        viewModel.selectChild(child.id)
                    }
                )
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.15))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Child Order Card

struct ChildOrderCard: View {
    let order: WorkOrder
    let isSelected: Bool
    var onTap: () -> Void

    private var completedCount: Int {
        order.maintenanceProcedures.filter { $0.result != nil }.count
    }

    private var totalCount: Int {
        order.maintenanceProcedures.count
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                // Status indicator
                Circle()
                    .fill(order.displayStatus.color)
                    .frame(width: 10, height: 10)

                VStack(alignment: .leading, spacing: 4) {
                    // 資產編號
                    Text(order.assetNumber)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    // 資產說明（設備說明）
                    Text(order.equipmentDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // 完成進度與狀態
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(completedCount)/\(totalCount)")
                        .font(.caption)
                        .fontWeight(.medium)

                    // 根據 displayStatus 顯示狀態
                    Text(order.displayStatus.displayName)
                        .font(.caption2)
                        .foregroundColor(order.displayStatus.color)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.orange.opacity(0.1) : AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
