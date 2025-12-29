import SwiftUI

struct OverviewTabView: View {
    @ObservedObject var viewModel: WorkOrderDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Sub-tab bar
            subTabBar

            // Content based on selected sub-tab
            switch viewModel.selectedOverviewSubTab {
            case .workOrder:
                WorkOrderSubTabView(viewModel: viewModel)
            case .maintenanceProcedure:
                MaintenanceProcedureSubTabView(viewModel: viewModel)
            case .materials:
                MaterialsSubTabView(viewModel: viewModel)
            }
        }
    }

    private var subTabBar: some View {
        HStack(spacing: 0) {
            ForEach(WorkOrderDetailViewModel.OverviewSubTab.allCases) { subTab in
                SubTabButton(
                    title: subTabTitle(subTab),
                    isSelected: viewModel.selectedOverviewSubTab == subTab,
                    action: { viewModel.selectedOverviewSubTab = subTab }
                )
            }
        }
        .background(Color.black)
    }

    private func subTabTitle(_ subTab: WorkOrderDetailViewModel.OverviewSubTab) -> String {
        switch subTab {
        case .workOrder:
            return "工單\n(待回報:\(viewModel.pendingProcedureCount)筆)"
        case .maintenanceProcedure:
            return "保養作業程序"
        case .materials:
            return "材料"
        }
    }
}

struct SubTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(isSelected ? .white : .gray)
                .fontWeight(isSelected ? .semibold : .regular)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.black : Color.black.opacity(0.8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Work Order Sub Tab

struct WorkOrderSubTabView: View {
    @ObservedObject var viewModel: WorkOrderDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("項目 (共\(viewModel.totalProcedureCount)筆),待回報:\(viewModel.pendingProcedureCount)筆")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                Spacer()
            }
            .padding()
            .background(AppColors.secondaryBackground)

            // Table header
            HStack {
                Text("工單編號/資產")
                    .frame(width: 150, alignment: .leading)
                Text("說明")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("狀態")
                    .frame(width: 80, alignment: .trailing)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(UIColor.tertiarySystemBackground))

            // Content - simplified for this view
            List {
                // Show the main work order
                HStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.workOrder.orderNumber)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .frame(width: 150, alignment: .leading)

                    Text(viewModel.workOrder.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    StatusBadge(status: viewModel.workOrder.displayStatus)
                        .frame(width: 80, alignment: .trailing)
                }
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Maintenance Procedure Sub Tab

struct MaintenanceProcedureSubTabView: View {
    @ObservedObject var viewModel: WorkOrderDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header with actions
            HStack {
                Text("項目 (共\(viewModel.totalProcedureCount)筆)")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                Spacer()

                // Batch action buttons
                Button("全 ✓") {
                    viewModel.setAllProceduresResult(.pass)
                }
                .buttonStyle(.bordered)

                Button("全 ✗") {
                    viewModel.setAllProceduresResult(.fail)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(AppColors.secondaryBackground)

            // Table header
            procedureTableHeader

            // Procedure list
            List {
                ForEach(viewModel.workOrder.maintenanceProcedures) { procedure in
                    ProcedureRow(
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
            .listStyle(.plain)
        }
    }

    private var procedureTableHeader: some View {
        HStack {
            Text("序號")
                .frame(width: 40, alignment: .leading)
            Text("作業程序與檢查重點")
                .frame(width: 120, alignment: .leading)
            Text("作業規格")
                .frame(width: 100, alignment: .leading)
            Text("結果")
                .frame(width: 100, alignment: .center)
            Text("測量值")
                .frame(width: 60, alignment: .center)
            Text("備註")
                .frame(width: 60, alignment: .center)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.tertiarySystemBackground))
    }
}

struct ProcedureRow: View {
    let procedure: MaintenanceProcedure
    let onResultChanged: (MaintenanceProcedure.ResultType?) -> Void
    let onMeasurementChanged: (String) -> Void
    let onNotesChanged: (String) -> Void

    @State private var measurementText: String = ""
    @State private var notesText: String = ""

    var body: some View {
        HStack {
            Text("\(procedure.sequence)")
                .font(.subheadline)
                .frame(width: 40, alignment: .leading)

            Text(procedure.procedureDescription)
                .font(.caption)
                .frame(width: 120, alignment: .leading)

            Text(procedure.specification)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)

            // Result buttons
            HStack(spacing: 4) {
                ResultButton(
                    type: .pass,
                    isSelected: procedure.result == .pass,
                    action: { onResultChanged(.pass) }
                )
                ResultButton(
                    type: .fail,
                    isSelected: procedure.result == .fail,
                    action: { onResultChanged(.fail) }
                )
                if procedure.hasScadaIntegration {
                    ResultButton(
                        type: .notApplicable,
                        isSelected: procedure.result == .notApplicable,
                        action: { onResultChanged(.notApplicable) }
                    )
                }
            }
            .frame(width: 100, alignment: .center)

            // Measurement
            Text("(必填)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .center)

            // Notes
            Text("(選填)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .center)
        }
        .padding(.vertical, 4)
    }
}

struct ResultButton: View {
    let type: MaintenanceProcedure.ResultType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.caption)
                .foregroundColor(isSelected ? .white : foregroundColor)
                .frame(width: 24, height: 24)
                .background(isSelected ? backgroundColor : Color.clear)
                .overlay(
                    Circle()
                        .stroke(foregroundColor, lineWidth: 1)
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
        switch type {
        case .pass: return .green
        case .fail: return .red
        case .notApplicable: return .gray
        }
    }
}

// MARK: - Materials Sub Tab

struct MaterialsSubTabView: View {
    @ObservedObject var viewModel: WorkOrderDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("材料 (共\(viewModel.workOrder.materials.count)筆)")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                Spacer()
            }
            .padding()
            .background(AppColors.secondaryBackground)

            if viewModel.workOrder.materials.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("沒有材料資料")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.workOrder.materials) { material in
                        MaterialRow(material: material) {
                            viewModel.toggleMaterialSelection(material.id)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

struct MaterialRow: View {
    let material: Material
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: material.isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(material.isSelected ? .green : .secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(material.materialNumber)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(material.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("\(Int(material.requiredQuantity)) \(material.unit)")
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

