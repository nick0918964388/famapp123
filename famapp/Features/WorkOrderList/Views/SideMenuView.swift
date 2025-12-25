import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var authService: AuthService

    var body: some View {
        List {
            // Work Order Section
            Section {
                ForEach(workOrderMenuItems, id: \.self) { item in
                    menuItemButton(item)
                }
            } header: {
                Text("工單管理")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Settings Section
            Section {
                ForEach(settingsMenuItems, id: \.self) { item in
                    menuItemButton(item)
                }
            } header: {
                Text("系統")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Logout Section
            Section {
                Button(action: logout) {
                    Label("登出", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("選單")
    }

    private var workOrderMenuItems: [AppCoordinator.MenuItem] {
        [.pmOrders, .cmOrders, .inspectionOrders, .inventory]
    }

    private var settingsMenuItems: [AppCoordinator.MenuItem] {
        [.settings, .systemInfo]
    }

    @ViewBuilder
    private func menuItemButton(_ item: AppCoordinator.MenuItem) -> some View {
        Button {
            coordinator.selectMenuItem(item)
        } label: {
            HStack {
                Label(item.rawValue, systemImage: item.icon)
                    .foregroundColor(item.isEnabled ? .primary : .secondary)

                Spacer()

                if !item.isEnabled {
                    Text("即將推出")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                }
            }
        }
        .disabled(!item.isEnabled)
        .opacity(item.isEnabled ? 1.0 : 0.6)
        .listRowBackground(coordinator.selectedMenuItem == item ? Color.accentColor.opacity(0.2) : Color.clear)
    }

    private func logout() {
        authService.logout()
        coordinator.logout()
    }
}
