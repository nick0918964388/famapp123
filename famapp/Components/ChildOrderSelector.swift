import SwiftUI

/// Child Order Selector - Horizontal scrollable selector for switching between child orders
struct ChildOrderSelector: View {
    let childOrders: [WorkOrder]
    @Binding var selectedChildId: UUID?
    var onParentTap: (() -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Parent order button (總覽)
                ParentOrderButton(
                    isSelected: selectedChildId == nil,
                    childCount: childOrders.count,
                    onTap: {
                        selectedChildId = nil
                        onParentTap?()
                    }
                )

                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 32)
                    .padding(.horizontal, 4)

                // Child order buttons
                ForEach(childOrders) { child in
                    ChildOrderButton(
                        order: child,
                        isSelected: selectedChildId == child.id,
                        onTap: {
                            selectedChildId = child.id
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(AppColors.secondaryBackground)
    }
}

// MARK: - Parent Order Button

struct ParentOrderButton: View {
    let isSelected: Bool
    let childCount: Int
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "folder.fill")
                        .font(.caption)
                    Text("母工單")
                        .font(.caption.bold())
                }

                Text("共 \(childCount) 筆")
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.orange : Color.gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Child Order Button

struct ChildOrderButton: View {
    let order: WorkOrder
    let isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                // 設備編號
                Text(order.assetNumber)
                    .font(.caption.bold())
                    .lineLimit(1)

                // 狀態
                HStack(spacing: 4) {
                    Circle()
                        .fill(order.displayStatus.color)
                        .frame(width: 6, height: 6)
                    Text(order.displayStatus.displayName)
                        .font(.caption2)
                }
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.orange : Color.gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Compact Child Order Selector (Segmented Style)

struct CompactChildOrderSelector: View {
    let childOrders: [WorkOrder]
    @Binding var selectedChildId: UUID?
    var showParentOption: Bool = true
    var onParentTap: (() -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                if showParentOption {
                    CompactSelectorButton(
                        title: "總覽",
                        subtitle: "\(childOrders.count)筆",
                        isSelected: selectedChildId == nil,
                        isFirst: true,
                        isLast: false
                    ) {
                        selectedChildId = nil
                        onParentTap?()
                    }
                }

                ForEach(Array(childOrders.enumerated()), id: \.element.id) { index, order in
                    CompactSelectorButton(
                        title: order.assetNumber,
                        subtitle: order.displayStatus.displayName,
                        statusColor: order.displayStatus.color,
                        isSelected: selectedChildId == order.id,
                        isFirst: !showParentOption && index == 0,
                        isLast: index == childOrders.count - 1
                    ) {
                        selectedChildId = order.id
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(AppColors.secondaryBackground)
    }
}

struct CompactSelectorButton: View {
    let title: String
    var subtitle: String?
    var statusColor: Color?
    let isSelected: Bool
    var isFirst: Bool = false
    var isLast: Bool = false
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    if let statusColor = statusColor {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                    }
                    Text(title)
                        .font(.caption)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .lineLimit(1)
                }

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                CustomRoundedRectangle(
                    topLeading: isFirst ? 8 : 0,
                    bottomLeading: isFirst ? 8 : 0,
                    bottomTrailing: isLast ? 8 : 0,
                    topTrailing: isLast ? 8 : 0
                )
                .fill(isSelected ? Color.orange : Color.gray.opacity(0.15))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Rounded Rectangle (iOS 16 compatible)

struct CustomRoundedRectangle: Shape {
    var topLeading: CGFloat = 0
    var bottomLeading: CGFloat = 0
    var bottomTrailing: CGFloat = 0
    var topTrailing: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)

        // Start from top-left, after the corner
        path.move(to: CGPoint(x: topLeft.x + topLeading, y: topLeft.y))

        // Top edge to top-right corner
        path.addLine(to: CGPoint(x: topRight.x - topTrailing, y: topRight.y))
        path.addArc(
            center: CGPoint(x: topRight.x - topTrailing, y: topRight.y + topTrailing),
            radius: topTrailing,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        // Right edge to bottom-right corner
        path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - bottomTrailing))
        path.addArc(
            center: CGPoint(x: bottomRight.x - bottomTrailing, y: bottomRight.y - bottomTrailing),
            radius: bottomTrailing,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        // Bottom edge to bottom-left corner
        path.addLine(to: CGPoint(x: bottomLeft.x + bottomLeading, y: bottomLeft.y))
        path.addArc(
            center: CGPoint(x: bottomLeft.x + bottomLeading, y: bottomLeft.y - bottomLeading),
            radius: bottomLeading,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        // Left edge to top-left corner
        path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + topLeading))
        path.addArc(
            center: CGPoint(x: topLeft.x + topLeading, y: topLeft.y + topLeading),
            radius: topLeading,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

struct ChildOrderSelector_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Standard Selector")
                .font(.headline)
            ChildOrderSelectorPreviewWrapper()

            Text("Compact Selector")
                .font(.headline)
            CompactChildOrderSelectorPreviewWrapper()
        }
    }
}

private struct ChildOrderSelectorPreviewWrapper: View {
    @State private var selectedId: UUID?

    var body: some View {
        ChildOrderSelector(
            childOrders: mockChildOrders,
            selectedChildId: $selectedId
        )
    }

    private var mockChildOrders: [WorkOrder] {
        [
            createMockOrder(assetNumber: "F15-ASSET001", status: .pendingReport),
            createMockOrder(assetNumber: "F15-ASSET002", status: .reported),
            createMockOrder(assetNumber: "F15-ASSET003", status: .pendingReport)
        ]
    }

    private func createMockOrder(assetNumber: String, status: WorkOrderStatus) -> WorkOrder {
        WorkOrder(
            id: UUID(),
            orderNumber: "WO2017000001",
            assetNumber: assetNumber,
            equipmentGroup: "",
            workPlan: "",
            description: "",
            scheduledDate: Date(),
            executionDeadline: Date(),
            reporterEngineer: "",
            reporterID: "",
            status: status,
            equipmentDescription: "",
            groupDescription: "",
            planDescription: "",
            maintenanceProcedures: [],
            materials: [],
            manpower: [],
            tools: [],
            approvalRecords: [],
            actualStartDate: nil,
            actualCompletionDate: nil,
            isDownloaded: true,
            lastModified: Date(),
            syncStatus: .synced,
            uploadHistory: []
        )
    }
}

private struct CompactChildOrderSelectorPreviewWrapper: View {
    @State private var selectedId: UUID?

    var body: some View {
        CompactChildOrderSelector(
            childOrders: mockChildOrders,
            selectedChildId: $selectedId
        )
    }

    private var mockChildOrders: [WorkOrder] {
        [
            createMockOrder(assetNumber: "ASSET001", status: .pendingReport),
            createMockOrder(assetNumber: "ASSET002", status: .reported),
            createMockOrder(assetNumber: "ASSET003", status: .pendingReport)
        ]
    }

    private func createMockOrder(assetNumber: String, status: WorkOrderStatus) -> WorkOrder {
        WorkOrder(
            id: UUID(),
            orderNumber: "WO2017000001",
            assetNumber: assetNumber,
            equipmentGroup: "",
            workPlan: "",
            description: "",
            scheduledDate: Date(),
            executionDeadline: Date(),
            reporterEngineer: "",
            reporterID: "",
            status: status,
            equipmentDescription: "",
            groupDescription: "",
            planDescription: "",
            maintenanceProcedures: [],
            materials: [],
            manpower: [],
            tools: [],
            approvalRecords: [],
            actualStartDate: nil,
            actualCompletionDate: nil,
            isDownloaded: true,
            lastModified: Date(),
            syncStatus: .synced,
            uploadHistory: []
        )
    }
}
