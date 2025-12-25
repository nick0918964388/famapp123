import SwiftUI

struct MainView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
    @State private var showSideMenu = false

    var body: some View {
        if horizontalSizeClass == .compact {
            // iPhone: Use NavigationStack with sheet menu
            compactLayout
        } else {
            // iPad: Use NavigationSplitView
            regularLayout
        }
    }

    // MARK: - iPhone Layout
    private var compactLayout: some View {
        NavigationStack {
            contentView
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showSideMenu = true
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                    }
                }
                .sheet(isPresented: $showSideMenu) {
                    NavigationStack {
                        SideMenuView()
                            .navigationTitle("選單")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("關閉") {
                                        showSideMenu = false
                                    }
                                }
                            }
                    }
                    .presentationDetents([.medium, .large])
                }
        }
        .onChange(of: coordinator.selectedMenuItem) { _ in
            showSideMenu = false
        }
    }

    // MARK: - iPad Layout
    private var regularLayout: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SideMenuView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        } detail: {
            contentView
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private var contentView: some View {
        switch coordinator.selectedMenuItem {
        case .pmOrders:
            WorkOrderListView()
        case .cmOrders:
            DisabledFeatureView(title: "CM工單", message: "此功能將在未來版本開放")
        case .inspectionOrders:
            DisabledFeatureView(title: "巡檢工單", message: "此功能將在未來版本開放")
        case .inventory:
            DisabledFeatureView(title: "庫存查詢", message: "此功能將在未來版本開放")
        case .settings:
            SettingsView()
        case .systemInfo:
            SystemInfoView()
        }
    }
}

struct DisabledFeatureView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .navigationTitle(title)
    }
}
