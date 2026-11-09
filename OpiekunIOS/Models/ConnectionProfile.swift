import Foundation

public enum ConnectionMode: String, Codable, CaseIterable, Sendable {
    case auto = "Automatyczny (Smart)"
    case local = "Tylko Dom (Wi-Fi)"
    case remote = "Tylko Poza Domem (LTE)"

    public var shortName: String {
        switch self {
        case .auto: return "Auto"
        case .local: return "Dom (Wi-Fi)"
        case .remote: return "Zdalnie (LTE)"
        }
    }

    public var iconName: String {
        switch self {
        case .auto: return "bolt.horizontal.fill"
        case .local: return "house.fill"
        case .remote: return "globe"
        }
    }
}

public struct ConnectionProfile: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    
    // Adres domowy (sieć lokalna Wi-Fi)
    public var host: String
    public var port: Int
    public var useHttps: Bool
    
    // Adres zdalny poza domem (Tunel Cloudflare HTTPS lub publiczny adres)
    public var remoteURL: String
    
    // Tryb połączenia
    public var mode: ConnectionMode
    public var isRemoteFallbackActive: Bool

    // PIN rodzica
    public var pin: String
    public var isDefault: Bool

    public init(
        id: UUID = UUID(),
        name: String = "Komputer Dziecka",
        host: String = "192.168.1.150",
        port: Int = 5050,
        remoteURL: String = "",
        mode: ConnectionMode = .auto,
        pin: String = "1234",
        useHttps: Bool = false,
        isDefault: Bool = true
    ) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.remoteURL = remoteURL
        self.mode = mode
        self.isRemoteFallbackActive = false
        self.pin = pin
        self.useHttps = useHttps
        self.isDefault = isDefault
    }

    // Obliczony adres lokalny
    public var localBaseURLString: String {
        let clean = host.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.lowercased().hasPrefix("http://") || clean.lowercased().hasPrefix("https://") {
            return clean.hasSuffix("/") ? String(clean.dropLast()) : clean
        }
        let scheme = useHttps ? "https" : "http"
        return "\(scheme)://\(clean):\(port)"
    }

    // Obliczony adres zdalny
    public var cleanRemoteURLString: String {
        let clean = remoteURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return "" }
        if clean.lowercased().hasPrefix("http://") || clean.lowercased().hasPrefix("https://") {
            return clean.hasSuffix("/") ? String(clean.dropLast()) : clean
        }
        return "https://\(clean)"
    }

    // Aktywny adres bazowy (uwzględnia tryb i automatyczne przełączanie poza domem)
    public var baseURLString: String {
        switch mode {
        case .remote:
            return !cleanRemoteURLString.isEmpty ? cleanRemoteURLString : localBaseURLString
        case .local:
            return localBaseURLString
        case .auto:
            if isRemoteFallbackActive && !cleanRemoteURLString.isEmpty {
                return cleanRemoteURLString
            }
            return localBaseURLString
        }
    }

    public var isCurrentlyUsingRemote: Bool {
        switch mode {
        case .remote: return true
        case .local: return false
        case .auto: return isRemoteFallbackActive && !cleanRemoteURLString.isEmpty
        }
    }
}
