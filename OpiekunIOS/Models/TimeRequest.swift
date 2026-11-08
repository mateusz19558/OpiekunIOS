import Foundation

public struct TimeRequest: Identifiable, Codable, Equatable {
    public let id: String
    public let requestedMinutes: Int
    public let reason: String
    public let createdAt: String?
    public let status: String

    public init(id: String = UUID().uuidString, requestedMinutes: Int = 30, reason: String = "", createdAt: String? = nil, status: String = "Pending") {
        self.id = id
        self.requestedMinutes = requestedMinutes
        self.reason = reason
        self.createdAt = createdAt
        self.status = status
    }

    public var isPending: Bool {
        status.caseInsensitiveCompare("Pending") == .orderedSame
    }

    public var formattedMinutes: String {
        "+\(requestedMinutes) min"
    }
}

