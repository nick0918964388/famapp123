import SwiftUI

struct ApprovalRecordsTabView: View {
    @ObservedObject var viewModel: WorkOrderDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("核簽紀錄 (共\(viewModel.workOrder.approvalRecords.count)筆)")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                Spacer()
            }
            .padding()
            .background(AppColors.secondaryBackground)

            // Records list
            if viewModel.workOrder.approvalRecords.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "signature")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("沒有核簽紀錄")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.workOrder.approvalRecords) { record in
                        ApprovalRecordRow(record: record)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

struct ApprovalRecordRow: View {
    let record: ApprovalRecord

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.approverName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(record.approverID)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                ApprovalStatusBadge(status: record.status)
            }

            Text(dateFormatter.string(from: record.approvalDate))
                .font(.caption)
                .foregroundColor(.secondary)

            if !record.comment.isEmpty {
                Text("意見：\(record.comment)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ApprovalStatusBadge: View {
    let status: ApprovalRecord.ApprovalStatus

    var body: some View {
        Text(statusText)
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .cornerRadius(4)
    }

    private var statusText: String {
        switch status {
        case .approved: return "已核准"
        case .rejected: return "已駁回"
        case .pending: return "待核簽"
        }
    }

    private var statusColor: Color {
        switch status {
        case .approved: return .green
        case .rejected: return .red
        case .pending: return .orange
        }
    }
}

