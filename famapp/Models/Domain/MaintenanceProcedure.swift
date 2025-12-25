import Foundation

/// 保養作業程序 (Maintenance Procedure / Work Item)
struct MaintenanceProcedure: Identifiable, Codable, Equatable {
    let id: UUID
    let sequence: Int                    // 序號 (10, 20, 30, 40...)
    let procedureDescription: String     // 作業程序與檢查重點
    let specification: String            // 作業規格 (e.g., "輸入溫度監測值(度C)", "標準值1±9psi")
    var result: ResultType?              // 結果 (✓/✗/NA)
    var measurementValue: String?        // 測量值 (必填)
    var notes: String?                   // 備註 (選填)
    var hasScadaIntegration: Bool        // 是否有 SCADA 整合

    enum ResultType: String, Codable, CaseIterable {
        case pass = "PASS"       // ✓
        case fail = "FAIL"       // ✗
        case notApplicable = "NA" // NA

        var displayIcon: String {
            switch self {
            case .pass: return "checkmark"
            case .fail: return "xmark"
            case .notApplicable: return "minus"
            }
        }

        var displayText: String {
            switch self {
            case .pass: return "✓"
            case .fail: return "✗"
            case .notApplicable: return "NA"
            }
        }
    }
}
