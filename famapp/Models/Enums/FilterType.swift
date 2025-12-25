import SwiftUI

enum FilterType: String, CaseIterable, Identifiable {
    case beforeToday = "本日(含)以前"
    case lastWeek = "近一週"
    case overdue = "逾期"
    case all = "全部"
    case todayCompleted = "本日完成"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .beforeToday: return "calendar.badge.minus"
        case .lastWeek: return "calendar.badge.clock"
        case .overdue: return "exclamationmark.triangle"
        case .all: return "list.bullet"
        case .todayCompleted: return "checkmark.circle"
        }
    }
}
