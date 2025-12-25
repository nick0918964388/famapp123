import Foundation

/// 材料
struct Material: Identifiable, Codable, Equatable {
    let id: UUID
    let materialNumber: String           // 材料編號
    let description: String              // 說明
    var requiredQuantity: Double         // 需求數量
    var usedQuantity: Double             // 使用數量
    let unit: String                     // 單位
    var isSelected: Bool                 // 是否選取
    var notes: String?                   // 備註
}
