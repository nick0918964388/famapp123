import SwiftUI

// MARK: - Shimmer Effect Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.4),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: phase * geometry.size.width * 2 - geometry.size.width)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Base Skeleton Shape

struct SkeletonShape: View {
    var width: CGFloat?
    var height: CGFloat = 16
    var cornerRadius: CGFloat = 4

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.3))
            .frame(width: width, height: height)
            .shimmer()
    }
}

// MARK: - Skeleton Row

struct SkeletonRow: View {
    var leadingWidth: CGFloat = 80
    var trailingWidth: CGFloat? = nil
    var height: CGFloat = 16

    var body: some View {
        HStack(spacing: 12) {
            SkeletonShape(width: leadingWidth, height: height)
            SkeletonShape(width: trailingWidth, height: height)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

// MARK: - Work Order List Skeleton

struct WorkOrderListSkeleton: View {
    var rowCount: Int = 5

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rowCount, id: \.self) { _ in
                WorkOrderRowSkeleton()
                Divider()
            }
        }
    }
}

struct WorkOrderRowSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Order number
                SkeletonShape(width: 150, height: 18)
                Spacer()
                // Status badge
                SkeletonShape(width: 60, height: 20, cornerRadius: 10)
            }

            HStack {
                // Asset number
                SkeletonShape(width: 100, height: 14)
                Spacer()
                // Date
                SkeletonShape(width: 80, height: 14)
            }

            // Description
            SkeletonShape(width: nil, height: 14)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Table Skeleton

struct TableSkeleton: View {
    var columnWidths: [CGFloat?]
    var rowCount: Int = 5
    var rowHeight: CGFloat = 44

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 8) {
                ForEach(0..<columnWidths.count, id: \.self) { index in
                    SkeletonShape(width: columnWidths[index], height: 14)
                    if index < columnWidths.count - 1 {
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.tertiarySystemBackground))

            // Rows
            ForEach(0..<rowCount, id: \.self) { _ in
                HStack(spacing: 8) {
                    ForEach(0..<columnWidths.count, id: \.self) { index in
                        SkeletonShape(width: columnWidths[index], height: 14)
                        if index < columnWidths.count - 1 {
                            Spacer(minLength: 0)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: rowHeight)
                Divider()
            }
        }
    }
}

// MARK: - Material List Skeleton

struct MaterialListSkeleton: View {
    var rowCount: Int = 5

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rowCount, id: \.self) { _ in
                HStack(spacing: 12) {
                    // Checkbox
                    SkeletonShape(width: 24, height: 24, cornerRadius: 12)

                    VStack(alignment: .leading, spacing: 4) {
                        // Material name
                        SkeletonShape(width: 200, height: 16)
                        // Material number
                        SkeletonShape(width: 100, height: 12)
                    }

                    Spacer()

                    // Quantity
                    SkeletonShape(width: 50, height: 14)
                }
                .padding()
                Divider()
            }
        }
    }
}

// MARK: - Manpower List Skeleton

struct ManpowerListSkeleton: View {
    var rowCount: Int = 3

    var body: some View {
        TableSkeleton(
            columnWidths: [80, 60, 50, nil, 30],
            rowCount: rowCount
        )
    }
}

// MARK: - Tool List Skeleton

struct ToolListSkeleton: View {
    var rowCount: Int = 3

    var body: some View {
        TableSkeleton(
            columnWidths: [80, 80, 60, nil, 30],
            rowCount: rowCount
        )
    }
}

// MARK: - Procedure List Skeleton

struct ProcedureListSkeleton: View {
    var rowCount: Int = 5

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rowCount, id: \.self) { _ in
                HStack(spacing: 12) {
                    // Sequence number
                    SkeletonShape(width: 30, height: 16)

                    // Description
                    VStack(alignment: .leading, spacing: 4) {
                        SkeletonShape(width: nil, height: 14)
                        SkeletonShape(width: 150, height: 12)
                    }

                    // Result buttons
                    HStack(spacing: 8) {
                        SkeletonShape(width: 32, height: 32, cornerRadius: 16)
                        SkeletonShape(width: 32, height: 32, cornerRadius: 16)
                        SkeletonShape(width: 32, height: 32, cornerRadius: 16)
                    }
                }
                .padding()
                Divider()
            }
        }
    }
}

// MARK: - Preview

struct SkeletonView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("Work Order List Skeleton")
                    .font(.headline)
                WorkOrderListSkeleton(rowCount: 3)

                Text("Table Skeleton")
                    .font(.headline)
                TableSkeleton(columnWidths: [80, 60, nil, 50], rowCount: 3)

                Text("Material List Skeleton")
                    .font(.headline)
                MaterialListSkeleton(rowCount: 3)
            }
            .padding()
        }
    }
}
