import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        List {
            Section {
                Toggle(isOn: $themeManager.isDarkMode) {
                    Label("深色模式", systemImage: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                }
            } header: {
                Text("外觀")
            }
        }
        .navigationTitle("設定")
    }
}

