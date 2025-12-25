import Foundation

struct User: Codable, Equatable {
    let id: String
    let username: String
    let displayName: String
    let role: UserRole
    let factory: String

    enum UserRole: String, Codable {
        case technician = "TECHNICIAN"
        case engineer = "ENGINEER"
        case supervisor = "SUPERVISOR"
        case admin = "ADMIN"
    }
}

struct AuthToken: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date

    var isExpired: Bool {
        Date() >= expiresAt
    }
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let user: User
    let token: AuthToken
}
