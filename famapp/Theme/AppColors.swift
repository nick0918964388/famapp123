import SwiftUI

enum AppColors {
    // MARK: - Primary Colors
    static let primary = Color("Primary", bundle: nil)
    static let primaryVariant = Color("PrimaryVariant", bundle: nil)

    // MARK: - Background Colors
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)

    // MARK: - Text Colors
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)

    // MARK: - Status Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue

    // MARK: - Work Order Status Colors
    static let statusPending = Color.orange
    static let statusInProgress = Color.blue
    static let statusCompleted = Color.green
    static let statusCancelled = Color.gray

    // MARK: - Material Status Colors
    static let materialNotRequired = Color.gray
    static let materialPending = Color.orange
    static let materialReady = Color.green
    static let materialIssued = Color.blue

    // MARK: - Card Colors
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let cardBorder = Color(UIColor.separator)

    // MARK: - Sync Status Colors
    static let syncPending = Color.orange
    static let syncSynced = Color.green
    static let syncConflict = Color.red
}

// MARK: - Color Extensions
extension Color {
    static func workOrderStatus(_ status: String) -> Color {
        switch status {
        case "PENDING":
            return AppColors.statusPending
        case "IN_PROGRESS":
            return AppColors.statusInProgress
        case "COMPLETED":
            return AppColors.statusCompleted
        case "CANCELLED":
            return AppColors.statusCancelled
        default:
            return AppColors.textSecondary
        }
    }

    static func materialStatus(_ status: String) -> Color {
        switch status {
        case "NOT_REQUIRED":
            return AppColors.materialNotRequired
        case "PENDING":
            return AppColors.materialPending
        case "READY":
            return AppColors.materialReady
        case "ISSUED":
            return AppColors.materialIssued
        default:
            return AppColors.textSecondary
        }
    }
}
