import Foundation

public struct RunningApp: Identifiable, Codable, Equatable {
    public var id: String { processName }
    public let processName: String
    public let windowTitle: String

    public init(processName: String, windowTitle: String) {
        self.processName = processName
        self.windowTitle = windowTitle
    }
}

public struct UsersResponse: Codable {
    public let users: [String]
    public let activeUser: String
}

