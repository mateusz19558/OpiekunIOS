import Foundation
import UIKit

public enum APIError: LocalizedError {
    case invalidURL
    case unauthorized
    case serverError(Int)
    case decodingError(Error)
    case networkError(Error)
    case invalidResponse
    case custom(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Nieprawidłowy adres serwera"
        case .unauthorized:
            return "Brak autoryzacji (nieprawidłowy PIN rodzica)"
        case .serverError(let code):
            return "Błąd serwera (kod: \(code))"
        case .decodingError(let err):
            return "Błąd przetwarzania danych: \(err.localizedDescription)"
        case .networkError(let err):
            return "Błąd sieci: \(err.localizedDescription)"
        case .invalidResponse:
            return "Otrzymano nieprawidłową odpowiedź"
        case .custom(let msg):
            return msg
        }
    }
}

public final class APIService {
    public static let shared = APIService()

    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8
        config.timeoutIntervalForResource = 15
        self.session = URLSession(configuration: config)

        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        self.jsonEncoder = JSONEncoder()
    }

    // Dynamic decoder for camelCase or exact match
    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        // First try standard
        let standardDecoder = JSONDecoder()
        do {
            return try standardDecoder.decode(T.self, from: data)
        } catch {
            // Try with snake_case
            return try jsonDecoder.decode(T.self, from: data)
        }
    }

    private func makeRequest(endpoint: String, method: String = "GET", profile: ConnectionProfile, body: Data? = nil) throws -> URLRequest {
        guard let url = URL(string: "\(profile.baseURLString)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(profile.pin, forHTTPHeaderField: "X-Parent-PIN")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }

        return request
    }

    // MARK: - Status
    public func getStatus(profile: ConnectionProfile) async throws -> GuardianStatus {
        let req = try makeRequest(endpoint: "/api/status", profile: profile)
        let (data, response) = try await session.data(for: req)

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        if http.statusCode == 401 { throw APIError.unauthorized }
        guard (200...299).contains(http.statusCode) else { throw APIError.serverError(http.statusCode) }

        return try decode(GuardianStatus.self, from: data)
    }

    // MARK: - Verify PIN
    public func verifyPin(pin: String, profile: ConnectionProfile) async throws -> Bool {
        let body = try JSONSerialization.data(withJSONObject: ["pin": pin])
        let req = try makeRequest(endpoint: "/api/verify-pin", method: "POST", profile: profile, body: body)
        let (data, response) = try await session.data(for: req)

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.serverError(http.statusCode) }

        struct VerifyResponse: Codable {
            let success: Bool
        }
        let res = try decode(VerifyResponse.self, from: data)
        return res.success
    }

    // MARK: - Lock / Unlock
    public func setManualLock(locked: Bool, profile: ConnectionProfile) async throws {
        let body = try JSONSerialization.data(withJSONObject: ["locked": locked])
        let req = try makeRequest(endpoint: "/api/lock", method: "POST", profile: profile, body: body)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    // MARK: - Internet Killswitch
    public func setInternetBlocked(blocked: Bool, profile: ConnectionProfile) async throws {
        let body = try JSONSerialization.data(withJSONObject: ["blocked": blocked])
        let req = try makeRequest(endpoint: "/api/block-internet", method: "POST", profile: profile, body: body)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    // MARK: - Website Block
    public func setWebsitesBlocked(enabled: Bool, profile: ConnectionProfile) async throws {
        let body = try JSONSerialization.data(withJSONObject: ["enabled": enabled])
        let req = try makeRequest(endpoint: "/api/block-websites", method: "POST", profile: profile, body: body)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    // MARK: - Windows Settings
    public func setWindowsSettingsBlocked(blocked: Bool, profile: ConnectionProfile) async throws {
        let body = try JSONSerialization.data(withJSONObject: ["blocked": blocked])
        let req = try makeRequest(endpoint: "/api/toggle-windows-settings", method: "POST", profile: profile, body: body)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    // MARK: - System Tools (CMD, Regedit, PowerShell)
    public func setSystemToolsBlocked(blocked: Bool, profile: ConnectionProfile) async throws {
        let body = try JSONSerialization.data(withJSONObject: ["blocked": blocked])
        let req = try makeRequest(endpoint: "/api/toggle-system-tools", method: "POST", profile: profile, body: body)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    // MARK: - Blocked Applications Master Toggle
    public func setBlockedApplicationsEnabled(enabled: Bool, profile: ConnectionProfile) async throws {
        let body = try JSONSerialization.data(withJSONObject: ["enabled": enabled])
        let req = try makeRequest(endpoint: "/api/toggle-blocked-apps", method: "POST", profile: profile, body: body)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    // MARK: - Add / Remove Blocked App
    public func addBlockedApp(appName: String, profile: ConnectionProfile) async throws {
        let body = try JSONSerialization.data(withJSONObject: ["appName": appName])
        let req = try makeRequest(endpoint: "/api/add-blocked-app", method: "POST", profile: profile, body: body)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    public func removeBlockedApp(appName: String, profile: ConnectionProfile) async throws {
        let body = try JSONSerialization.data(withJSONObject: ["appName": appName])
        let req = try makeRequest(endpoint: "/api/remove-blocked-app", method: "POST", profile: profile, body: body)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    // MARK: - Running Processes
    public func getRunningApps(profile: ConnectionProfile) async throws -> [RunningApp] {
        let req = try makeRequest(endpoint: "/api/running-apps", profile: profile)
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return try decode([RunningApp].self, from: data)
    }

    // MARK: - Screenshot
    public func fetchScreenshot(profile: ConnectionProfile) async throws -> UIImage {
        let req = try makeRequest(endpoint: "/api/screenshot", profile: profile)
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        guard let image = UIImage(data: data) else {
            throw APIError.custom("Nie udało się zdekodować obrazu zrzutu ekranu")
        }
        return image
    }

    // MARK: - Send Message
    public func sendMessage(message: String, profile: ConnectionProfile) async throws {
        let body = try JSONSerialization.data(withJSONObject: ["message": message])
        let req = try makeRequest(endpoint: "/api/send-message", method: "POST", profile: profile, body: body)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    // MARK: - Bonus Time & Reset
    public func addBonusTime(minutes: Int, profile: ConnectionProfile) async throws {
        let body = try JSONSerialization.data(withJSONObject: ["minutes": minutes])
        let req = try makeRequest(endpoint: "/api/add-bonus-time", method: "POST", profile: profile, body: body)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    public func resetTodayTime(profile: ConnectionProfile) async throws {
        let req = try makeRequest(endpoint: "/api/reset-today-time", method: "POST", profile: profile)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    // MARK: - Scheduled Lock
    public func scheduleLock(minutes: Int, profile: ConnectionProfile) async throws {
        let body = try JSONSerialization.data(withJSONObject: ["minutes": minutes])
        let req = try makeRequest(endpoint: "/api/schedule-lock", method: "POST", profile: profile, body: body)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    public func cancelScheduledLock(profile: ConnectionProfile) async throws {
        let req = try makeRequest(endpoint: "/api/cancel-scheduled-lock", method: "POST", profile: profile)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    // MARK: - Time Request Response
    public func respondTimeRequest(id: String, approved: Bool, minutes: Int? = nil, profile: ConnectionProfile) async throws {
        var payload: [String: Any] = ["id": id, "approved": approved]
        if let minutes = minutes {
            payload["minutes"] = minutes
        }
        let body = try JSONSerialization.data(withJSONObject: payload)
        let req = try makeRequest(endpoint: "/api/time-request/respond", method: "POST", profile: profile, body: body)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    // MARK: - Windows Users
    public func getUsers(profile: ConnectionProfile) async throws -> UsersResponse {
        let req = try makeRequest(endpoint: "/api/users", profile: profile)
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return try decode(UsersResponse.self, from: data)
    }

    // MARK: - Full Settings
    public func getSettings(profile: ConnectionProfile) async throws -> AppSettings {
        let req = try makeRequest(endpoint: "/api/settings", profile: profile)
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return try decode(AppSettings.self, from: data)
    }

    public func saveSettings(settings: AppSettings, profile: ConnectionProfile) async throws {
        let encoder = JSONEncoder()
        let body = try encoder.encode(settings)
        let req = try makeRequest(endpoint: "/api/settings", method: "POST", profile: profile, body: body)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    // MARK: - Logs
    public func getLogs(profile: ConnectionProfile) async throws -> LogsResponse {
        let req = try makeRequest(endpoint: "/api/logs", profile: profile)
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return try decode(LogsResponse.self, from: data)
    }

    public func clearLogs(profile: ConnectionProfile) async throws {
        let req = try makeRequest(endpoint: "/api/logs/clear", method: "POST", profile: profile)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    // MARK: - Remote Mode
    public func setRemoteMode(enabled: Bool, blockInput: Bool, profile: ConnectionProfile) async throws {
        let body = try JSONSerialization.data(withJSONObject: [
            "enabled": enabled,
            "blockInput": blockInput
        ])
        let req = try makeRequest(endpoint: "/api/remote-mode", method: "POST", profile: profile, body: body)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }
}

