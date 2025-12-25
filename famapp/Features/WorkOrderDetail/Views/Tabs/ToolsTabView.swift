import SwiftUI

struct ToolsTabView: View {
    @ObservedObject var viewModel: WorkOrderDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("項目 (共\(viewModel.workOrder.tools.count)筆)")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                Spacer()

                Button(action: { /* TODO: Add tool */ }) {
                    Label("+選取計劃工具", systemImage: "plus")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(AppColors.secondaryBackground)

            // Table header
            toolsTableHeader

            // Tools list
            if viewModel.workOrder.tools.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("沒有工具資料")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.workOrder.tools) { tool in
                        ToolRow(
                            tool: tool,
                            onReselect: {
                                // TODO: Implement reselect
                            },
                            onDelete: {
                                viewModel.removeTool(tool.id)
                            }
                        )
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private var toolsTableHeader: some View {
        HStack {
            Text("工具種類")
                .frame(width: 80, alignment: .leading)
            Text("工具類別")
                .frame(width: 100, alignment: .leading)
            Text("")
                .frame(width: 60)
            Text("工具資訊")
                .frame(width: 80, alignment: .center)
            Text("儀器名稱")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("")
                .frame(width: 40)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.tertiarySystemBackground))
    }
}

struct ToolRow: View {
    let tool: Tool
    let onReselect: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text(tool.toolType)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)

            Text(tool.toolCategory)
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)

            Button("重選") {
                onReselect()
            }
            .font(.caption)
            .buttonStyle(.bordered)
            .tint(.orange)
            .frame(width: 60)

            Text(tool.toolInfo)
                .font(.subheadline)
                .frame(width: 80, alignment: .center)

            Text(tool.instrumentName)
                .font(.subheadline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.orange)
            }
            .frame(width: 40)
        }
        .padding(.vertical, 4)
    }
}

