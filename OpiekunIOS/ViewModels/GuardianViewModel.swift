import Foundation
import SwiftUI
import Combine

@MainActor
public final class GuardianViewModel: ObservableObject {
    // Current connection profile
    @Published public var profile: ConnectionProfile {
        didSet {
            saveProfile()
        }
    }

    // State
    @Published public var status: GuardianStatus = GuardianStatus()
    @Published public var isAuthenticated: Bool = false
    @Published public var isConnected: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var toastMessage: String? = nil

    // SSE client
    private let sseClient = SSEClient()
    private var cancellables = Set<AnyCancellable>()
    private var statusPollTimer: Timer?

    public init() {
        // Load saved profile or create default
        if let data = UserDefaults.standard.data(forKey: "saved_connection_profile"),
           let saved = try? JSONDecoder().decode(ConnectionProfile.self, from: data) {
            self.profile = saved
        } else {
            self.profile = ConnectionProfile()
        }

        setupSSE()
    }

    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "saved_connection_profile")
        }
    }

    private func setupSSE() {
        sseClient.onStatusReceived = { [weak self] newStatus in
            guard let self = self else { return }

            // Check if there are new time requests to notify
            let oldIds = Set(self.status.pendingTimeRequests.map { $0.id })
            for req in newStatus.pendingTimeRequests where !oldIds.contains(req.id) {
                NotificationService.shared.showTimeRequestNotification(
                    from: newStatus.targetUserName,
                    minutes: req.requestedMinutes,
                    reason: req.reason
                )
                HapticService.shared.notification(.warning)
            }

            self.status = newStatus
            self.isConnected = true
        }

        sseClient.onConnectionChanged = { [weak self] connected in
            self?.isConnected = connected
        }
    }

    // MARK: - Authentication & Connection
    public func authenticate(pin: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let valid = try await APIService.shared.verifyPin(pin: pin, profile: profile)
            isLoading = false
            if valid {
                profile.pin = pin
                saveProfile()
                isAuthenticated = true
                HapticService.shared.notification(.success)
                await refreshStatus()
                startLiveStream()
                return true
            } else {
                HapticService.shared.notification(.error)
                errorMessage = "Nieprawidłowy kod PIN"
                return false
            }
        } catch {
            isLoading = false
            HapticService.shared.notification(.error)
            errorMessage = error.localizedDescription
            return false
        }
    }

    public func startLiveStream() {
        sseClient.connect(profile: profile)

        // Backup polling every 10s if SSE drops
        statusPollTimer?.invalidate()
        statusPollTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, self.isAuthenticated, !self.sseClient.isConnected else { return }
                await self.refreshStatus()
            }
        }
    }

    public func stopLiveStream() {
        sseClient.disconnect()
        statusPollTimer?.invalidate()
        statusPollTimer = nil
    }

    public func refreshStatus() async {
        do {
            let fetched = try await APIService.shared.getStatus(profile: profile)
            self.status = fetched
            self.isConnected = true
        } catch {
            self.isConnected = false
        }
    }

    // MARK: - Actions
    public func toggleLock() async {
        HapticService.shared.impact(.heavy)
        let targetState = !status.isLocked
        do {
            try await APIService.shared.setManualLock(locked: targetState, profile: profile)
            status.isLocked = targetState
            showToast(targetState ? "Komputer został zablokowany 🔒" : "Komputer odblokowany 🔓")
        } catch {
            showToast("Błąd zmiany blokady: \(error.localizedDescription)")
        }
    }

    public func toggleInternet() async {
        HapticService.shared.impact(.medium)
        let target = !status.isInternetBlocked
        do {
            try await APIService.shared.setInternetBlocked(blocked: target, profile: profile)
            status.isInternetBlocked = target
            showToast(target ? "Odcięto internet na komputerze 🚫" : "Przywrócono połączenie sieciowe 🌐")
        } catch {
            showToast("Błąd przełączania sieci: \(error.localizedDescription)")
        }
    }

    public func toggleWebsitesBlock() async {
        HapticService.shared.impact(.medium)
        let target = !status.blockedWebsitesEnabled
        do {
            try await APIService.shared.setWebsitesBlocked(enabled: target, profile: profile)
            status.blockedWebsitesEnabled = target
            showToast(target ? "Blokada stron www włączona 🛡️" : "Blokada stron www wyłączona")
        } catch {
            showToast("Błąd zmiany blokady stron")
        }
    }

    public func toggleWindowsSettings() async {
        HapticService.shared.impact(.medium)
        let target = !status.blockWindowsSettings
        do {
            try await APIService.shared.setWindowsSettingsBlocked(blocked: target, profile: profile)
            status.blockWindowsSettings = target
            showToast(target ? "Zablokowano Ustawienia Windows ⚙️" : "Odblokowano Ustawienia Windows")
        } catch {
            showToast("Błąd przełączania Ustawień Windows")
        }
    }

    public func toggleSystemTools() async {
        HapticService.shared.impact(.medium)
        let target = !status.blockSystemTools
        do {
            try await APIService.shared.setSystemToolsBlocked(blocked: target, profile: profile)
            status.blockSystemTools = target
            showToast(target ? "Zablokowano CMD, Rejestr i PowerShell 🛑" : "Odblokowano narzędzia systemowe")
        } catch {
            showToast("Błąd przełączania narzędzi systemowych")
        }
    }

    public func toggleBlockedApps() async {
        HapticService.shared.impact(.medium)
        let target = !status.blockedApplicationsEnabled
        do {
            try await APIService.shared.setBlockedApplicationsEnabled(enabled: target, profile: profile)
            status.blockedApplicationsEnabled = target
            showToast(target ? "Blokada aplikacji i gier włączona 🎮" : "Blokada gier wyłączona")
        } catch {
            showToast("Błąd zmiany blokady aplikacji")
        }
    }

    public func addBonusTime(_ minutes: Int) async {
        HapticService.shared.notification(.success)
        do {
            try await APIService.shared.addBonusTime(minutes: minutes, profile: profile)
            showToast("Dodano +\(minutes) minut dla dziecka! ⏱️")
            await refreshStatus()
        } catch {
            showToast("Błąd dodawania czasu: \(error.localizedDescription)")
        }
    }

    public func resetTodayTime() async {
        HapticService.shared.impact(.medium)
        do {
            try await APIService.shared.resetTodayTime(profile: profile)
            showToast("Wyzerowano dzisiejszy czas ↺")
            await refreshStatus()
        } catch {
            showToast("Błąd resetowania czasu")
        }
    }

    public func scheduleLock(minutes: Int) async {
        HapticService.shared.impact(.medium)
        do {
            try await APIService.shared.scheduleLock(minutes: minutes, profile: profile)
            showToast("Zaplanowano blokadę za \(minutes) min ⏳")
            await refreshStatus()
        } catch {
            showToast("Błąd planowania blokady")
        }
    }

    public func cancelScheduledLock() async {
        HapticService.shared.impact(.medium)
        do {
            try await APIService.shared.cancelScheduledLock(profile: profile)
            showToast("Anulowano zaplanowaną blokadę ❌")
            await refreshStatus()
        } catch {
            showToast("Błąd anulowania blokady")
        }
    }

    public func respondToTimeRequest(id: String, approved: Bool, minutes: Int? = nil) async {
        HapticService.shared.notification(approved ? .success : .warning)
        do {
            try await APIService.shared.respondTimeRequest(id: id, approved: approved, minutes: minutes, profile: profile)
            showToast(approved ? "Zaakceptowano prośbę o czas! ✓" : "Odrzucono prośbę ❌")
            await refreshStatus()
        } catch {
            showToast("Błąd odpowiedzi na prośbę")
        }
    }

    public func sendMessage(_ text: String) async -> Bool {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        HapticService.shared.impact(.medium)
        do {
            try await APIService.shared.sendMessage(message: text, profile: profile)
            showToast("Wiadomość wysłana na pulpit! 🚀")
            return true
        } catch {
            showToast("Błąd wysyłania wiadomości: \(error.localizedDescription)")
            return false
        }
    }

    public func showToast(_ message: String) {
        toastMessage = message
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if self.toastMessage == message {
                self.toastMessage = nil
            }
        }
    }
}

