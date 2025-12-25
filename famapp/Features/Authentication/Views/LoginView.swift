import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: LoginViewModel

    init() {
        // Will be properly initialized in onAppear
        _viewModel = StateObject(wrappedValue: LoginViewModel(authService: AuthService()))
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.1)

                    // Logo Section
                    logoSection

                    Spacer()
                        .frame(height: 60)

                    // Login Form
                    loginForm

                    Spacer()
                }
                .frame(minHeight: geometry.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(AppColors.background)
        .onAppear {
            // Re-initialize viewModel with proper authService
            viewModel.clearError()
        }
        .alert("登入錯誤", isPresented: $viewModel.showError) {
            Button("確定", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: authService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                coordinator.authState = .authenticated(userId: authService.currentUser?.id ?? "")
            }
        }
    }

    private var logoSection: some View {
        VStack(spacing: 16) {
            // App Logo - Replace with actual logo image
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text("PM工單回報管理")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            Text("設備保養管理系統")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
    }

    private var loginForm: some View {
        VStack(spacing: 20) {
            // Username Field
            VStack(alignment: .leading, spacing: 8) {
                Text("帳號")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)

                HStack {
                    Image(systemName: "person")
                        .foregroundColor(AppColors.textSecondary)
                    TextField("請輸入帳號", text: $viewModel.username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding()
                .background(AppColors.secondaryBackground)
                .cornerRadius(12)
            }

            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("密碼")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)

                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(AppColors.textSecondary)
                    SecureField("請輸入密碼", text: $viewModel.password)
                        .textContentType(.password)
                }
                .padding()
                .background(AppColors.secondaryBackground)
                .cornerRadius(12)
            }

            // Login Button
            PrimaryButton(
                title: "登入",
                isLoading: viewModel.isLoading || authService.isLoading,
                isDisabled: !viewModel.isFormValid
            ) {
                Task {
                    await loginWithAuthService()
                }
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 32)
    }

    private func loginWithAuthService() async {
        guard viewModel.isFormValid else {
            viewModel.errorMessage = "請輸入帳號和密碼"
            viewModel.showError = true
            return
        }

        do {
            try await authService.login(
                username: viewModel.username.trimmingCharacters(in: .whitespaces),
                password: viewModel.password
            )
        } catch let error as AuthError {
            viewModel.errorMessage = error.errorDescription
            viewModel.showError = true
        } catch {
            viewModel.errorMessage = "登入失敗，請稍後再試"
            viewModel.showError = true
        }
    }
}

