import Foundation
import UserNotifications

public final class NotificationService {
    public static let shared = NotificationService()

    private init() {}

    public func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    public func showTimeRequestNotification(from childName: String, minutes: Int, reason: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔔 Prośba o dodatkowy czas!"
        content.subtitle = "\(childName.isEmpty ? "Dziecko" : childName) prosi o +\(minutes) min"
        content.body = reason.isEmpty ? "Brak podanego powodu" : "Powód: \"\(reason)\""
        content.sound = UNNotificationSound.defaultCritical

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

