import SwiftUI

struct AdvancedSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WorkOrderListViewModel

    var body: some View {
        NavigationStack {
            Form {
                // 預計執行日範圍
                Section("預計執行日") {
                    DatePicker(
                        "開始日期",
                        selection: $viewModel.advancedSearch.startDate,
                        displayedComponents: .date
                    )

                    DatePicker(
                        "結束日期",
                        selection: $viewModel.advancedSearch.endDate,
                        displayedComponents: .date
                    )
                }

                // 人員
                Section("人員") {
                    TextField("輸入人員編號或姓名", text: $viewModel.advancedSearch.personnel)
                        .textInputAutocapitalization(.never)
                }

                // 課別
                Section("課別") {
                    Picker("選擇課別", selection: $viewModel.advancedSearch.department) {
                        Text("全部").tag("")
                        ForEach(viewModel.availableDepartments, id: \.self) { dept in
                            Text(dept).tag(dept)
                        }
                    }
                }

                // 工單狀態
                Section("工單狀態") {
                    Picker("狀態", selection: $viewModel.advancedSearch.status) {
                        Text("全部").tag(WorkOrderStatus?.none)
                        Text("待回報").tag(WorkOrderStatus?.some(.pendingReport))
                        Text("已回報").tag(WorkOrderStatus?.some(.reported))
                    }
                }

                // 工單類型
                Section("工單類型") {
                    Picker("類型", selection: $viewModel.advancedSearch.orderType) {
                        Text("全部").tag(OrderType?.none)
                        ForEach(OrderType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(OrderType?.some(type))
                        }
                    }
                }
            }
            .navigationTitle("進階查詢")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("搜尋") {
                        Task {
                            await viewModel.performAdvancedSearch()
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    Button {
                        viewModel.resetAdvancedSearch()
                    } label: {
                        Text("重設條件")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
        }
    }
}

// MARK: - Advanced Search Model

struct AdvancedSearchCriteria {
    var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    var endDate: Date = Date()
    var personnel: String = ""
    var department: String = ""
    var status: WorkOrderStatus? = nil
    var orderType: OrderType? = nil

    var isEmpty: Bool {
        personnel.isEmpty && department.isEmpty && status == nil && orderType == nil
    }

    mutating func reset() {
        startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        endDate = Date()
        personnel = ""
        department = ""
        status = nil
        orderType = nil
    }
}
