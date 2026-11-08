import Foundation

@MainActor
public final class ScheduleViewModel: ObservableObject {
    @Published public var settings: AppSettings = AppSettings()
    @Published public var isLoading: Bool = false
    @Published public var isSaving: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var saveSuccessMessage: String? = nil

    public let daysOrder = [
        "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    ]

    public let dayNamesPolish: [String: String] = [
        "Monday": "Poniedziałek",
        "Tuesday": "Wtorek",
        "Wednesday": "Środa",
        "Thursday": "Czwartek",
        "Friday": "Piątek",
        "Saturday": "Sobota",
        "Sunday": "Niedziela"
    ]

    public init() {}

    public func loadSettings(profile: ConnectionProfile) async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await APIService.shared.getSettings(profile: profile)
            self.settings = fetched
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }

    public func saveSettings(profile: ConnectionProfile) async -> Bool {
        isSaving = true
        errorMessage = nil

        do {
            try await APIService.shared.saveSettings(settings: settings, profile: profile)
            self.isSaving = false
            self.saveSuccessMessage = "Harmonogram zapisany!"
            HapticService.shared.notification(.success)
            return true
        } catch {
            self.isSaving = false
            self.errorMessage = error.localizedDescription
            HapticService.shared.notification(.error)
            return false
        }
    }

    public func copyWeekdaysToAll() {
        guard let monday = settings.weeklySchedule["Monday"] else { return }
        for day in ["Tuesday", "Wednesday", "Thursday", "Friday"] {
            settings.weeklySchedule[day] = monday
        }
        HapticService.shared.impact(.light)
    }

    public func copyWeekend() {
        guard let saturday = settings.weeklySchedule["Saturday"] else { return }
        settings.weeklySchedule["Sunday"] = saturday
        HapticService.shared.impact(.light)
    }

    public func resetToDefaults() {
        settings.weeklySchedule = AppSettings.defaultSchedule()
        HapticService.shared.impact(.medium)
    }
}

