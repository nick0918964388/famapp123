import SwiftUI

/// Work Items Report Tab - For child order maintenance procedure reporting
struct WorkItemsReportTabView: View {
    @ObservedObject var viewModel: ParentWorkOrderDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header with actions
            headerSection

            if viewModel.currentChildProcedures.isEmpty {
                EmptyStateView(
                    icon: "list.clipboard",
                    title: "沒有工作項目",
                    message: "此子工單沒有保養作業程序"
                )
            } else {
                // Procedure list (卡片樣式)
                procedureList
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("工作項目回報")
                    .font(.headline)
                    .foregroundColor(.orange)

                Text("共 \(viewModel.currentChildTotalProcedureCount) 筆，待回報 \(viewModel.currentChildPendingProcedureCount) 筆")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Batch action buttons
            HStack(spacing: 12) {
                Button(action: { viewModel.setAllProceduresResult(.pass) }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }

                Button(action: { viewModel.setAllProceduresResult(.fail) }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(AppColors.secondaryBackground)
    }

    // MARK: - Procedure List

    private var procedureList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.currentChildProcedures) { procedure in
                    WorkItemCardView(
                        procedure: procedure,
                        onResultChanged: { result in
                            viewModel.updateProcedureResult(procedure.id, result: result)
                        },
                        onMeasurementChanged: { value in
                            viewModel.updateProcedureMeasurement(procedure.id, value: value)
                        },
                        onNotesChanged: { notes in
                            viewModel.updateProcedureNotes(procedure.id, notes: notes)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Work Item Card View

struct WorkItemCardView: View {
    let procedure: MaintenanceProcedure
    let onResultChanged: (MaintenanceProcedure.ResultType?) -> Void
    let onMeasurementChanged: (String) -> Void
    let onNotesChanged: (String) -> Void

    @State private var measurementText: String = ""
    @State private var notesText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 頂部：序號 + 描述 + 結果
            HStack(alignment: .top) {
                // 序號標籤
                Text("\(procedure.sequence)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Color.orange)
                    .cornerRadius(6)

                // 描述
                VStack(alignment: .leading, spacing: 4) {
                    Text(procedure.procedureDescription)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    if !procedure.specification.isEmpty {
                        Text(procedure.specification)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // 結果狀態指示
                resultStatusBadge
            }

            // 結果按鈕
            HStack(spacing: 12) {
                Text("結果")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    WorkItemResultButton(
                        type: .pass,
                        isSelected: procedure.result == .pass,
                        action: { onResultChanged(.pass) }
                    )
                    WorkItemResultButton(
                        type: .fail,
                        isSelected: procedure.result == .fail,
                        action: { onResultChanged(.fail) }
                    )
                    if procedure.hasScadaIntegration {
                        WorkItemResultButton(
                            type: .notApplicable,
                            isSelected: procedure.result == .notApplicable,
                            action: { onResultChanged(.notApplicable) }
                        )
                    }
                }

                Spacer()
            }

            // 輸入欄位
            HStack(spacing: 16) {
                // 測量值
                VStack(alignment: .leading, spacing: 4) {
                    Text("測量值")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("必填", text: $measurementText)
                        .font(.subheadline)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: measurementText) { newValue in
                            onMeasurementChanged(newValue)
                        }
                        .onAppear {
                            measurementText = procedure.measurementValue ?? ""
                        }
                }
                .frame(maxWidth: .infinity)

                // 備註
                VStack(alignment: .leading, spacing: 4) {
                    Text("備註")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("選填", text: $notesText)
                        .font(.subheadline)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: notesText) { newValue in
                            onNotesChanged(newValue)
                        }
                        .onAppear {
                            notesText = procedure.notes ?? ""
                        }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Result Status Badge

    @ViewBuilder
    private var resultStatusBadge: some View {
        if let result = procedure.result {
            HStack(spacing: 4) {
                Image(systemName: result == .pass ? "checkmark.circle.fill" :
                        result == .fail ? "xmark.circle.fill" : "minus.circle.fill")
                Text(result == .pass ? "通過" : result == .fail ? "未通過" : "不適用")
            }
            .font(.caption)
            .foregroundColor(result == .pass ? .green : result == .fail ? .red : .gray)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                (result == .pass ? Color.green : result == .fail ? Color.red : Color.gray)
                    .opacity(0.15)
            )
            .cornerRadius(6)
        } else {
            Text("待回報")
                .font(.caption)
                .foregroundColor(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(6)
        }
    }
}

// MARK: - Work Item Result Button

struct WorkItemResultButton: View {
    let type: MaintenanceProcedure.ResultType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.caption)
                .foregroundColor(isSelected ? .white : foregroundColor)
                .frame(width: 28, height: 28)
                .background(isSelected ? backgroundColor : Color.clear)
                .overlay(
                    Circle()
                        .stroke(foregroundColor, lineWidth: 1.5)
                )
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var iconName: String {
        switch type {
        case .pass: return "checkmark"
        case .fail: return "xmark"
        case .notApplicable: return "minus"
        }
    }

    private var foregroundColor: Color {
        switch type {
        case .pass: return .green
        case .fail: return .red
        case .notApplicable: return .gray
        }
    }

    private var backgroundColor: Color {
        foregroundColor
    }
}
