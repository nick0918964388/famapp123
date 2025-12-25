import SwiftUI

final class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false

    var colorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }

    func toggleTheme() {
        isDarkMode.toggle()
    }
}
