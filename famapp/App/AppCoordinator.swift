import SwiftUI

final class AppCoordinator: ObservableObject {
    @Published var authState: AuthState = .loading
    @Published var selectedMenuItem: MenuItem = .pmOrders
    @Published var isSideMenuExpanded: Bool = false

    enum AuthState: Equatable {
        case loading
        case unauthenticated
        case authenticated(userId: String)
    }

    enum MenuItem: String, CaseIterable, Identifiable {
        case pmOrders = "PM Orders"
        case cmOrders = "CM Orders"
        case inspectionOrders = "Inspection Orders"
        case inventory = "Inventory"
        case settings = "Settings"
        case systemInfo = "System Info"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .pmOrders: return "wrench.and.screwdriver"
            case .cmOrders: return "exclamationmark.triangle"
            case .inspectionOrders: return "checklist"
            case .inventory: return "shippingbox"
            case .settings: return "gearshape"
            case .systemInfo: return "info.circle"
            }
        }

        var isEnabled: Bool {
            switch self {
            case .pmOrders, .settings, .systemInfo:
                return true
            case .cmOrders, .inspectionOrders, .inventory:
                return false // Disabled in v1
            }
        }
    }

    func checkAuthentication() {
        // Check if user has valid token
        if let _ = KeychainManager.shared.getToken() {
            // TODO: Validate token with server
            authState = .authenticated(userId: "user")
        } else {
            authState = .unauthenticated
        }
    }

    func login(userId: String) {
        authState = .authenticated(userId: userId)
    }

    func logout() {
        KeychainManager.shared.deleteToken()
        authState = .unauthenticated
        selectedMenuItem = .pmOrders
    }

    func selectMenuItem(_ item: MenuItem) {
        guard item.isEnabled else { return }
        selectedMenuItem = item
    }

    func toggleSideMenu() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isSideMenuExpanded.toggle()
        }
    }
}
