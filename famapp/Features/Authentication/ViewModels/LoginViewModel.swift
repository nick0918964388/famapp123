import Foundation
import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    private let authService: AuthService

    var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    init(authService: AuthService) {
        self.authService = authService
    }

    func login() async {
        guard isFormValid else {
            errorMessage = "請輸入帳號和密碼"
            showError = true
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.login(
                username: username.trimmingCharacters(in: .whitespaces),
                password: password
            )
        } catch let error as AuthError {
            errorMessage = error.errorDescription
            showError = true
        } catch {
            errorMessage = "登入失敗，請稍後再試"
            showError = true
        }

        isLoading = false
    }

    func clearError() {
        errorMessage = nil
        showError = false
    }
}
