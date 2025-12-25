import Foundation

final class AuthService: ObservableObject {
    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var currentUser: User?
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    private let keychainManager = KeychainManager.shared

    init() {
        checkAuthentication()
    }

    func checkAuthentication() {
        if let token = keychainManager.getToken(), !token.isExpired {
            currentUser = keychainManager.getUser()
            isAuthenticated = true
        } else {
            isAuthenticated = false
            currentUser = nil
        }
    }

    func login(username: String, password: String) async throws {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        // Simulate network delay for mock
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Mock authentication - accept any non-empty credentials
        guard !username.isEmpty, !password.isEmpty else {
            await MainActor.run {
                isLoading = false
                errorMessage = "請輸入帳號和密碼"
            }
            throw AuthError.invalidCredentials
        }

        // Mock user data
        let mockUser = User(
            id: "U001",
            username: username,
            displayName: "工程師 \(username)",
            role: .engineer,
            factory: "F15"
        )

        let mockToken = AuthToken(
            accessToken: "mock_access_token_\(UUID().uuidString)",
            refreshToken: "mock_refresh_token_\(UUID().uuidString)",
            expiresAt: Date().addingTimeInterval(86400 * 7) // 7 days
        )

        // Save to keychain
        keychainManager.saveUser(mockUser)
        keychainManager.saveToken(mockToken)

        await MainActor.run {
            currentUser = mockUser
            isAuthenticated = true
            isLoading = false
        }
    }

    func logout() {
        keychainManager.clearAll()
        currentUser = nil
        isAuthenticated = false
    }

    func refreshTokenIfNeeded() async throws {
        guard let token = keychainManager.getToken() else {
            throw AuthError.notAuthenticated
        }

        if token.isExpired {
            // In real implementation, call refresh token API
            // For mock, just re-authenticate
            throw AuthError.tokenExpired
        }
    }
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case notAuthenticated
    case tokenExpired
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "帳號或密碼錯誤"
        case .notAuthenticated:
            return "請先登入"
        case .tokenExpired:
            return "登入已過期，請重新登入"
        case .networkError:
            return "網路連線錯誤"
        }
    }
}
