import Foundation

public struct ConnectionProfile: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var host: String // np. 192.168.1.150 lub https://xxx.trycloudflare.com
    public var port: Int
    public var pin: String
    public var useHttps: Bool
    public var isDefault: Bool

    public init(
        id: UUID = UUID(),
        name: String = "Komputer Dziecka",
        host: String = "192.168.1.150",
        port: Int = 5050,
        pin: String = "1234",
        useHttps: Bool = false,
        isDefault: Bool = true
    ) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.pin = pin
        self.useHttps = useHttps
        self.isDefault = isDefault
    }

    public var baseURLString: String {
        let clean = host.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.lowercased().hasPrefix("http://") || clean.lowercased().hasPrefix("https://") {
            // Jeśli host ma już schemat (np. Cloudflare Tunnel https://...)
            return clean.hasSuffix("/") ? String(clean.dropLast()) : clean
        }
        let scheme = useHttps ? "https" : "http"
        return "\(scheme)://\(clean):\(port)"
    }
}

