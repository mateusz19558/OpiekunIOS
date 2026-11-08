import Foundation

@MainActor
public final class LogsViewModel: ObservableObject {
    @Published public var logs: [LogEntry] = []
    @Published public var logFilePath: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var selectedFilter: String = "ALL" // ALL, ERROR, WARN, INFO
    @Published public var searchText: String = ""

    public init() {}

    public var filteredLogs: [LogEntry] {
        logs.filter { entry in
            let matchesFilter: Bool
            if selectedFilter == "ALL" {
                matchesFilter = true
            } else {
                matchesFilter = entry.level.caseInsensitiveCompare(selectedFilter) == .orderedSame
            }

            let matchesSearch: Bool
            if searchText.isEmpty {
                matchesSearch = true
            } else {
                matchesSearch = entry.message.localizedCaseInsensitiveContains(searchText)
                    || entry.source.localizedCaseInsensitiveContains(searchText)
            }

            return matchesFilter && matchesSearch
        }
    }

    public func loadLogs(profile: ConnectionProfile) async {
        isLoading = true
        errorMessage = nil

        do {
            let res = try await APIService.shared.getLogs(profile: profile)
            self.logs = res.logs
            self.logFilePath = res.logFilePath ?? ""
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }

    public func clearLogs(profile: ConnectionProfile) async {
        do {
            try await APIService.shared.clearLogs(profile: profile)
            self.logs = []
            HapticService.shared.notification(.success)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

