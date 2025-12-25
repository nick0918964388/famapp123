import SwiftUI

/// Planned Material Report Tab - For child order material selection from API
struct PlannedMaterialReportTabView: View {
    @ObservedObject var viewModel: ParentWorkOrderDetailViewModel
    @State private var showMaterialPicker = false
    @State private var selectedMaterialOption: MaterialOption?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            // Material selection area
            if viewModel.isLoadingMaterials {
                MaterialListSkeleton(rowCount: 3)
            } else {
                // Selected materials list
                if viewModel.currentChildMaterials.isEmpty {
                    emptyStateSection
                } else {
                    selectedMaterialsList
                }
            }
        }
        .sheet(isPresented: $showMaterialPicker) {
            MaterialPickerSheet(
                materials: viewModel.availableMaterials,
                onSelect: { material in
                    viewModel.addMaterialToChild(material)
                    showMaterialPicker = false
                },
                onCancel: {
                    showMaterialPicker = false
                }
            )
        }
        .task {
            if viewModel.availableMaterials.isEmpty {
                await viewModel.loadAvailableMaterials()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("計畫材料回報")
                    .font(.headline)
                    .foregroundColor(.orange)

                Text("已選 \(viewModel.currentChildMaterials.count) 筆材料")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: { showMaterialPicker = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                    Text("選取計畫材料")
                }
                .font(.subheadline)
                .foregroundColor(.orange)
            }
        }
        .padding()
        .background(AppColors.secondaryBackground)
    }

    // MARK: - Empty State

    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.secondary.opacity(0.5))

            Text("尚未選取材料")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("點擊上方「選取計畫材料」從清單中選擇")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)

            Button(action: { showMaterialPicker = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("選取計畫材料")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.orange)
                .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Selected Materials List

    private var selectedMaterialsList: some View {
        VStack(spacing: 0) {
            // Table header
            HStack {
                Text("材料編號")
                    .frame(width: 80, alignment: .leading)
                Text("材料名稱")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("計畫")
                    .frame(width: 40, alignment: .center)
                Text("實際數量")
                    .frame(width: 90, alignment: .center)
                Text("")
                    .frame(width: 30)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(UIColor.tertiarySystemBackground))

            List {
                ForEach(viewModel.currentChildMaterials) { material in
                    SelectedMaterialRow(
                        material: material,
                        onQuantityChanged: { quantity in
                            viewModel.updateMaterialQuantity(material.id, quantity: quantity)
                        },
                        onRemove: {
                            viewModel.removeMaterial(material.id)
                        }
                    )
                }
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Selected Material Row

struct SelectedMaterialRow: View {
    let material: Material
    let onQuantityChanged: (Double) -> Void
    let onRemove: () -> Void

    @State private var quantity: Int = 0

    var body: some View {
        HStack {
            Text(material.materialNumber)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)
                .lineLimit(1)

            Text(material.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)

            Text("\(Int(material.requiredQuantity))")
                .font(.caption)
                .frame(width: 40, alignment: .center)

            // 數量調整器
            HStack(spacing: 4) {
                Button(action: {
                    if quantity > 0 {
                        quantity -= 1
                        onQuantityChanged(Double(quantity))
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(quantity > 0 ? .orange : .gray.opacity(0.4))
                }
                .buttonStyle(.plain)

                Text("\(quantity)")
                    .font(.subheadline.bold())
                    .frame(width: 30, alignment: .center)

                Button(action: {
                    quantity += 1
                    onQuantityChanged(Double(quantity))
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 90)

            Button(action: onRemove) {
                Image(systemName: "trash.fill")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.8))
            }
            .frame(width: 30)
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .onAppear {
            quantity = Int(material.usedQuantity)
        }
    }
}

// MARK: - Material Picker Sheet

struct MaterialPickerSheet: View {
    let materials: [MaterialOption]
    let onSelect: (MaterialOption) -> Void
    let onCancel: () -> Void

    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("搜尋材料...", text: $searchText)
                        .textFieldStyle(.plain)

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))

                // Materials list
                List {
                    ForEach(filteredMaterials) { material in
                        MaterialOptionRow(material: material) {
                            onSelect(material)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("選取計畫材料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { onCancel() }
                }
            }
        }
    }

    private var filteredMaterials: [MaterialOption] {
        if searchText.isEmpty {
            return materials
        }
        return materials.filter {
            $0.materialNumber.localizedCaseInsensitiveContains(searchText) ||
            $0.materialName.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - Material Option Row

struct MaterialOptionRow: View {
    let material: MaterialOption
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(material.materialNumber)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(material.materialName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("計畫數量")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text("\(Int(material.plannedQuantity)) \(material.unit)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Image(systemName: "plus.circle")
                    .foregroundColor(.orange)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}
