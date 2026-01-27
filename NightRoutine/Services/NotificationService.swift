import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let notificationCenter = UNUserNotificationCenter.current()
    private let reminderIdentifier = "nightroutine.daily.reminder"

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("NotificationService: Authorization request failed: \(error)")
            return false
        }
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }

    var needsPermissionRequest: Bool {
        authorizationStatus == .notDetermined
    }

    var isDenied: Bool {
        authorizationStatus == .denied
    }

    // MARK: - Scheduling

    func scheduleReminder(settings: UserSettings) async {
        // Cancel any existing reminder first
        cancelReminder()

        guard settings.reminderEnabled else { return }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Wind Down"
        content.body = settings.reminderMessage ?? "Your night routine is waiting for you."
        content.sound = .default
        content.badge = 1

        // Create trigger for daily notification at specified time
        var dateComponents = DateComponents()
        dateComponents.hour = settings.reminderHour
        dateComponents.minute = settings.reminderMinute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        // Create the request
        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
            print("NotificationService: Reminder scheduled for \(settings.reminderHour):\(String(format: "%02d", settings.reminderMinute))")
        } catch {
            print("NotificationService: Failed to schedule reminder: \(error)")
        }
    }

    func cancelReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        print("NotificationService: Reminder cancelled")
    }

    // MARK: - Badge Management

    func clearBadge() async {
        do {
            try await notificationCenter.setBadgeCount(0)
        } catch {
            print("NotificationService: Failed to clear badge: \(error)")
        }
    }
}
