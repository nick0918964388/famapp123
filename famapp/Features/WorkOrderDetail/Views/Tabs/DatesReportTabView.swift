import SwiftUI

/// Dates Report Tab - For child order actual start and completion dates
struct DatesReportTabView: View {
    @ObservedObject var viewModel: ParentWorkOrderDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            // Date form
            ScrollView {
                VStack(spacing: 24) {
                    // Scheduled dates (read-only)
                    scheduledDatesCard

                    // Actual dates (editable)
                    actualDatesCard

                    // Date validation message
                    if let validationMessage = dateValidationMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(validationMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("日期回報")
                .font(.headline)
                .foregroundColor(.orange)

            Spacer()

            if let child = viewModel.selectedChild {
                Text(child.assetNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(AppColors.secondaryBackground)
    }

    // MARK: - Scheduled Dates Card (Read-only)

    private var scheduledDatesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text("計畫日期")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            if let child = viewModel.selectedChild {
                VStack(spacing: 12) {
                    DateInfoRow(
                        label: "預計執行日",
                        date: child.scheduledDate,
                        icon: "calendar.badge.clock"
                    )

                    DateInfoRow(
                        label: "工單執行期限",
                        date: child.executionDeadline,
                        icon: "calendar.badge.exclamationmark"
                    )
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Actual Dates Card (Editable)

    private var actualDatesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.plus")
                    .foregroundColor(.orange)
                Text("實際日期")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("必填")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(4)
            }

            VStack(spacing: 16) {
                // Actual Start Date
                DateInputRow(
                    label: "實際開工日",
                    date: Binding(
                        get: { viewModel.selectedChild?.actualStartDate },
                        set: { viewModel.updateChildActualStartDate($0) }
                    ),
                    icon: "play.circle.fill"
                )

                Divider()

                // Actual Completion Date
                DateInputRow(
                    label: "實際完工日",
                    date: Binding(
                        get: { viewModel.selectedChild?.actualCompletionDate },
                        set: { viewModel.updateChildActualCompletionDate($0) }
                    ),
                    icon: "checkmark.circle.fill"
                )
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Validation

    private var dateValidationMessage: String? {
        guard let child = viewModel.selectedChild,
              let startDate = child.actualStartDate,
              let endDate = child.actualCompletionDate else {
            return nil
        }

        if endDate < startDate {
            return "實際完工日不能早於實際開工日"
        }

        if endDate > child.executionDeadline {
            return "實際完工日已超過工單執行期限"
        }

        return nil
    }
}

// MARK: - Date Info Row (Read-only)

struct DateInfoRow: View {
    let label: String
    let date: Date
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(formatDate(date))
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Date Input Row (Editable)

struct DateInputRow: View {
    let label: String
    @Binding var date: Date?
    let icon: String

    @State private var showDatePicker = false
    @State private var tempDate: Date = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                    .frame(width: 24)

                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Spacer()

                if let selectedDate = date {
                    Text(formatDate(selectedDate))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Button(action: { date = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("尚未設定")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Button(action: {
                    tempDate = date ?? Date()
                    showDatePicker = true
                }) {
                    Image(systemName: "calendar")
                        .foregroundColor(.orange)
                }
            }

            if showDatePicker {
                VStack(spacing: 8) {
                    DatePicker(
                        "",
                        selection: $tempDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()

                    HStack {
                        Button("取消") {
                            showDatePicker = false
                        }
                        .foregroundColor(.secondary)

                        Spacer()

                        Button("確認") {
                            date = tempDate
                            showDatePicker = false
                        }
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}
