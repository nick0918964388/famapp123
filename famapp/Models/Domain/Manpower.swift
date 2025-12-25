import Foundation

/// 人力
struct Manpower: Identifiable, Codable, Equatable {
    let id: UUID
    let personnelID: String              // 人力 ID (e.g., "B9439680")
    let name: String                     // 姓名 (e.g., "廠商-xxxx")
    var maintenanceHours: Double         // 保養工時 (e.g., 8.0, 12.0, 23.0)
    var notes: String?                   // 備註
    var startDate: Date                  // 開始日期
    var endDate: Date                    // 結束日期
}
