import Foundation

public final class SSEClient: ObservableObject {
    private var streamTask: Task<Void, Never>?
    private let session: URLSession

    @Published public private(set) var isConnected: Bool = false

    public var onStatusReceived: ((GuardianStatus) -> Void)?
    public var onConnectionChanged: ((Bool) -> Void)?

    public init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(300)
        configuration.timeoutIntervalForResource = TimeInterval(600)
        self.session = URLSession(configuration: configuration)
    }

    public func connect(profile: ConnectionProfile) {
        disconnect()

        guard let url = URL(string: "\(profile.baseURLString)/api/events") else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue(profile.pin, forHTTPHeaderField: "X-Parent-PIN")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        streamTask = Task { [weak self] in
            guard let self = self else { return }

            while !Task.isCancelled {
                do {
                    let (asyncBytes, response) = try await self.session.bytes(for: request)

                    guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                        await MainActor.run {
                            self.isConnected = false
                            self.onConnectionChanged?(false)
                        }
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        continue
                    }

                    await MainActor.run {
                        self.isConnected = true
                        self.onConnectionChanged?(true)
                    }

                    let decoder = JSONDecoder()

                    for try await line in asyncBytes.lines {
                        if Task.isCancelled { break }

                        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

                        if trimmed.hasPrefix("data:") {
                            let jsonString = trimmed.dropFirst(5).trimmingCharacters(in: .whitespaces)
                            if let data = jsonString.data(using: .utf8) {
                                if let status = try? decoder.decode(GuardianStatus.self, from: data) {
                                    await MainActor.run {
                                        self.onStatusReceived?(status)
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    if Task.isCancelled { break }
                    await MainActor.run {
                        self.isConnected = false
                        self.onConnectionChanged?(false)
                    }
                    // Wait before reconnecting
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                }
            }
        }
    }

    public func disconnect() {
        streamTask?.cancel()
        streamTask = nil
        isConnected = false
        onConnectionChanged?(false)
    }

    deinit {
        disconnect()
    }
}

