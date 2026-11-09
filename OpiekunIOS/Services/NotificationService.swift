import Foundation
import UserNotifications

public final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationService()

    public static let categoryId = "TIME_REQUEST_CATEGORY"
    public static let actionApprove15 = "ACTION_APPROVE_15"
    public static let actionApprove30 = "ACTION_APPROVE_30"
    public static let actionReject = "ACTION_REJECT"

    public var onTimeRequestAction: ((_ requestId: String, _ approved: Bool, _ minutes: Int?) -> Void)?

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupCategories()
    }

    public func setupCategories() {
        let act15 = UNNotificationAction(
            identifier: Self.actionApprove15,
            title: "✓ Zezwól na +15 min",
            options: []
        )
        let act30 = UNNotificationAction(
            identifier: Self.actionApprove30,
            title: "✓ Zezwól na +30 min",
            options: []
        )
        let actReject = UNNotificationAction(
            identifier: Self.actionReject,
            title: "✕ Odrzuć",
            options: [.destructive]
        )

        let category = UNNotificationCategory(
            identifier: Self.categoryId,
            actions: [act15, act30, actReject],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    public func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    public func showTimeRequestNotification(requestId: String, from childName: String, minutes: Int, reason: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔔 Nowa prośba o czas na komputerze!"
        content.subtitle = "\(childName.isEmpty ? "Dziecko" : childName) prosi o +\(minutes) min"
        content.body = reason.isEmpty ? "Dotknij, aby zezwolić lub odrzucić." : "Powód: \"\(reason)\""
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = Self.categoryId
        content.userInfo = ["requestId": requestId, "requestedMinutes": minutes]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "time_req_\(requestId)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    // Wyświetlanie powiadomień również gdy aplikacja jest na pierwszym planie
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    // Obsługa interaktywnych przycisków w powiadomieniu
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let reqId = userInfo["requestId"] as? String else {
            completionHandler()
            return
        }

        switch response.actionIdentifier {
        case Self.actionApprove15:
            onTimeRequestAction?(reqId, true, 15)
        case Self.actionApprove30:
            onTimeRequestAction?(reqId, true, 30)
        case Self.actionReject:
            onTimeRequestAction?(reqId, false, nil)
        default:
            break
        }

        completionHandler()
    }
}
