import SwiftUI

struct ManpowerTabView: View {
    @ObservedObject var viewModel: WorkOrderDetailViewModel
    @State private var startDate = Date()
    @State private var endDate = Date()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("項目 (共\(viewModel.workOrder.manpower.count)筆)")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                Spacer()

                Button(action: { /* TODO: Add manpower */ }) {
                    Label("+選取計劃人力", systemImage: "plus")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(AppColors.secondaryBackground)

            // Date pickers
            HStack(spacing: 16) {
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()

                DatePicker("", selection: $endDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Table header
            manpowerTableHeader

            // Manpower list
            if viewModel.workOrder.manpower.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.3")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("沒有人力資料")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.workOrder.manpower) { person in
                        ManpowerRow(
                            manpower: person,
                            onHoursChanged: { hours in
                                viewModel.updateManpowerHours(person.id, hours: hours)
                            },
                            onNotesChanged: { notes in
                                viewModel.updateManpowerNotes(person.id, notes: notes)
                            },
                            onDelete: {
                                viewModel.removeManpower(person.id)
                            }
                        )
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private var manpowerTableHeader: some View {
        HStack(spacing: 8) {
            Text("人力")
                .frame(width: 70, alignment: .leading)
            Text("姓名")
                .frame(width: 80, alignment: .leading)
            Text("工時")
                .frame(width: 90, alignment: .center)
            Text("備註")
                .frame(minWidth: 60, alignment: .leading)
            Spacer()
            Text("")
                .frame(width: 32)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.tertiarySystemBackground))
    }
}

struct ManpowerRow: View {
    let manpower: Manpower
    let onHoursChanged: (Double) -> Void
    let onNotesChanged: (String) -> Void
    let onDelete: () -> Void

    @State private var hours: Int = 0
    @State private var notesText: String = ""

    var body: some View {
        HStack(spacing: 8) {
            Text(manpower.personnelID)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 70, alignment: .leading)
                .lineLimit(1)

            Text(manpower.name)
                .font(.caption)
                .frame(width: 80, alignment: .leading)
                .lineLimit(1)

            // 工時調整器
            HStack(spacing: 4) {
                Button(action: {
                    if hours > 0 {
                        hours -= 1
                        onHoursChanged(Double(hours))
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(hours > 0 ? .orange : .gray.opacity(0.4))
                }
                .buttonStyle(.plain)

                Text("\(hours)")
                    .font(.subheadline.bold())
                    .frame(width: 30, alignment: .center)

                Button(action: {
                    hours += 1
                    onHoursChanged(Double(hours))
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 90)

            TextField("備註", text: $notesText)
                .font(.caption)
                .textFieldStyle(.roundedBorder)
                .frame(minWidth: 60)
                .onAppear {
                    notesText = manpower.notes ?? ""
                }
                .onChange(of: notesText) { newValue in
                    onNotesChanged(newValue)
                }

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.orange)
                    .font(.body)
            }
            .buttonStyle(.plain)
            .frame(width: 32)
        }
        .padding(.vertical, 4)
        .onAppear {
            hours = Int(manpower.maintenanceHours)
        }
    }
}

