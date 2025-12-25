import Foundation

/// 工具
struct Tool: Identifiable, Codable, Equatable {
    let id: UUID
    let toolType: String                 // 工具種類 (e.g., "廠商校驗")
    let toolCategory: String             // 工具類別 (e.g., "電表-三用電錶")
    let toolInfo: String                 // 工具資訊 (e.g., "25813028")
    let instrumentName: String           // 儀器名稱 (e.g., "F15P1/2三用電錶")
    var isSelected: Bool                 // 是否選取
    var notes: String?                   // 備註
}
