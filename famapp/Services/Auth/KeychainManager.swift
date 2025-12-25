import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()

    private let serviceName = "com.txxx.famapp"
    private let tokenKey = "authToken"
    private let userKey = "currentUser"

    private init() {}

    // MARK: - Token Management

    func saveToken(_ token: AuthToken) {
        guard let data = try? JSONEncoder().encode(token) else { return }
        save(data: data, forKey: tokenKey)
    }

    func getToken() -> AuthToken? {
        guard let data = getData(forKey: tokenKey) else { return nil }
        return try? JSONDecoder().decode(AuthToken.self, from: data)
    }

    func deleteToken() {
        delete(forKey: tokenKey)
    }

    // MARK: - User Management

    func saveUser(_ user: User) {
        guard let data = try? JSONEncoder().encode(user) else { return }
        save(data: data, forKey: userKey)
    }

    func getUser() -> User? {
        guard let data = getData(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    func deleteUser() {
        delete(forKey: userKey)
    }

    // MARK: - Clear All

    func clearAll() {
        deleteToken()
        deleteUser()
    }

    // MARK: - Private Keychain Operations

    private func save(data: Data, forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        // Delete existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        var newQuery = query
        newQuery[kSecValueData as String] = data

        SecItemAdd(newQuery as CFDictionary, nil)
    }

    private func getData(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    private func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
