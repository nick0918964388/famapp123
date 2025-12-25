import Foundation

enum OrderType: String, Codable, CaseIterable {
    case preventiveMaintenance = "PM"
    case correctiveMaintenance = "CM"
    case inspection = "INSP"
    case inventory = "INV"

    var displayName: String {
        switch self {
        case .preventiveMaintenance: return "PM工單"
        case .correctiveMaintenance: return "CM工單"
        case .inspection: return "巡檢工單"
        case .inventory: return "庫存查詢"
        }
    }

    var isEnabled: Bool {
        switch self {
        case .preventiveMaintenance:
            return true
        case .correctiveMaintenance, .inspection, .inventory:
            return false // Disabled in v1
        }
    }
}
