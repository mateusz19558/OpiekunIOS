import Foundation

public struct LogEntry: Identifiable, Codable, Equatable {
    public var id = UUID()
    public let timestamp: String
    public let level: String
    public let source: String
    public let message: String
    public let exceptionDetails: String?

    enum CodingKeys: String, CodingKey {
        case timestamp, level, source, message, exceptionDetails
    }
}

public struct LogsResponse: Codable {
    public let success: Bool
    public let logFilePath: String?
    public let totalCount: Int
    public let logs: [LogEntry]
}

