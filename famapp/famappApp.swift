//
//  famappApp.swift
//  famapp
//
//  Created by nickall on 2025/12/24.
//

import SwiftUI

@main
struct famappApp: App {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var authService = AuthService()
    @StateObject private var networkMonitor = NetworkMonitor.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(coordinator)
                .environmentObject(themeManager)
                .environmentObject(authService)
                .environmentObject(networkMonitor)
                .preferredColorScheme(themeManager.colorScheme)
                .onAppear {
                    coordinator.checkAuthentication()
                }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            switch coordinator.authState {
            case .loading:
                SplashView()
            case .unauthenticated:
                LoginView()
            case .authenticated:
                MainView()
            }
        }
        .animation(.easeInOut, value: coordinator.authState)
    }
}

struct SplashView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            Text("PM工單回報管理")
                .font(.title2)
                .fontWeight(.semibold)
            ProgressView()
        }
    }
}
