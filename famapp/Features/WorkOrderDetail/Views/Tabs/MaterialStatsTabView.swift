import SwiftUI

/// Material Statistics Tab - Shows aggregated material data from all child orders
struct MaterialStatsTabView: View {
    @ObservedObject var viewModel: ParentWorkOrderDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            if viewModel.aggregatedMaterials.isEmpty {
                EmptyStateView(
                    icon: "shippingbox",
                    title: "沒有材料資料",
                    message: "此母工單下沒有任何材料記錄"
                )
            } else {
                // Summary stats
                statsSummary

                // Materials list
                materialsList
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("材料統計")
                .font(.headline)
                .foregroundColor(.orange)

            Spacer()

            Text("共 \(viewModel.aggregatedMaterials.count) 筆")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(AppColors.secondaryBackground)
    }

    // MARK: - Stats Summary

    private var statsSummary: some View {
        HStack(spacing: 16) {
            StatBadge(
                title: "總材料數",
                value: "\(viewModel.aggregatedMaterials.count)",
                color: .blue
            )

            StatBadge(
                title: "已選用",
                value: "\(viewModel.selectedMaterialsCount)",
                color: .green
            )

            StatBadge(
                title: "待選用",
                value: "\(viewModel.aggregatedMaterials.count - viewModel.selectedMaterialsCount)",
                color: .orange
            )
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
    }

    // MARK: - Materials List

    private var materialsList: some View {
        List {
            ForEach(groupedMaterials, id: \.key) { childId, materials in
                Section {
                    ForEach(materials) { material in
                        MaterialStatRow(material: material)
                    }
                } header: {
                    if let childOrder = viewModel.parentWorkOrder.childOrders.first(where: { $0.id == childId }) {
                        HStack {
                            Text(childOrder.assetNumber)
                                .font(.caption)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(materials.count) 筆")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private var groupedMaterials: [(key: UUID, value: [Material])] {
        var result: [(key: UUID, value: [Material])] = []
        for child in viewModel.parentWorkOrder.childOrders {
            if !child.materials.isEmpty {
                result.append((key: child.id, value: child.materials))
            }
        }
        return result
    }
}

// MARK: - Stat Badge

struct StatBadge: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Material Stat Row

struct MaterialStatRow: View {
    let material: Material

    var body: some View {
        HStack {
            // Selection status
            Image(systemName: material.isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(material.isSelected ? .green : .gray)

            VStack(alignment: .leading, spacing: 2) {
                Text(material.materialNumber)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(material.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Quantities
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Text("需求:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(Int(material.requiredQuantity))")
                        .font(.caption)
                        .fontWeight(.medium)
                }

                if material.usedQuantity > 0 {
                    HStack(spacing: 4) {
                        Text("已用:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(Int(material.usedQuantity))")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                }
            }

            Text(material.unit)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30)
        }
        .padding(.vertical, 4)
    }
}
