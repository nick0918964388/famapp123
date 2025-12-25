import SwiftUI

enum WorkOrderStatus: String, Codable, CaseIterable {
    case pendingReport = "PENDING_REPORT"   // 待回報
    case reported = "REPORTED"               // 已回報

    var displayName: String {
        switch self {
        case .pendingReport: return "待回報"
        case .reported: return "已回報"
        }
    }

    var color: Color {
        switch self {
        case .pendingReport: return .orange
        case .reported: return .gray
        }
    }
}

enum MaterialStatus: String, Codable, CaseIterable {
    case notRequired = "NOT_REQUIRED"
    case pending = "PENDING"
    case ready = "READY"
    case issued = "ISSUED"

    var displayName: String {
        switch self {
        case .notRequired: return "不需要"
        case .pending: return "待領用"
        case .ready: return "已備料"
        case .issued: return "已領用"
        }
    }
}

enum SyncStatus: String, Codable {
    case synced = "SYNCED"
    case pendingUpload = "PENDING_UPLOAD"
    case pendingDownload = "PENDING_DOWNLOAD"
    case conflict = "CONFLICT"

    var displayName: String {
        switch self {
        case .synced: return "已同步"
        case .pendingUpload: return "待上傳"
        case .pendingDownload: return "待下載"
        case .conflict: return "衝突"
        }
    }

    var color: Color {
        switch self {
        case .synced: return .green
        case .pendingUpload: return .orange
        case .pendingDownload: return .blue
        case .conflict: return .red
        }
    }
}
