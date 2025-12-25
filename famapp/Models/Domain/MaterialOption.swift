import Foundation

/// 材料選項 (from API for dropdown selection)
struct MaterialOption: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let materialNumber: String       // 材料編號
    let materialName: String         // 材料名稱
    let plannedQuantity: Double      // 計畫數量
    let unit: String                 // 單位

    init(
        id: UUID = UUID(),
        materialNumber: String,
        materialName: String,
        plannedQuantity: Double,
        unit: String
    ) {
        self.id = id
        self.materialNumber = materialNumber
        self.materialName = materialName
        self.plannedQuantity = plannedQuantity
        self.unit = unit
    }
}
