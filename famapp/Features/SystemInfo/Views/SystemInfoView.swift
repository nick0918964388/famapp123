import SwiftUI

struct SystemInfoView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var networkMonitor: NetworkMonitor

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        List {
            Section {
                InfoRow(label: "版本", value: "\(appVersion) (\(buildNumber))")
                InfoRow(label: "最後更新時間", value: formattedDate(Date()))
            } header: {
                Text("應用程式資訊")
            }

            Section {
                HStack {
                    Text("網路狀態")
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(networkMonitor.isConnected ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(networkMonitor.isConnected ? "已連線" : "離線")
                            .foregroundColor(.secondary)
                    }
                }

                if networkMonitor.isConnected {
                    InfoRow(label: "連線類型", value: connectionTypeString)
                }
            } header: {
                Text("連線狀態")
            }

            if let user = authService.currentUser {
                Section {
                    InfoRow(label: "使用者", value: user.displayName)
                    InfoRow(label: "帳號", value: user.username)
                    InfoRow(label: "廠區", value: user.factory)
                } header: {
                    Text("登入資訊")
                }
            }
        }
        .navigationTitle("系統資訊")
    }

    private var connectionTypeString: String {
        switch networkMonitor.connectionType {
        case .wifi: return "Wi-Fi"
        case .cellular: return "行動網路"
        case .ethernet: return "有線網路"
        case .unknown: return "未知"
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

