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

    func scheduleReminder(settings: UserSettings, streak: Int = 0) async {
        // Cancel any existing reminder first
        cancelReminder()

        guard settings.reminderEnabled else { return }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Wind Down"
        content.body = settings.reminderMessage ?? smartMessage(for: streak)
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

    // MARK: - Smart Messages

    /// Returns a contextual notification message based on the user's current streak.
    func smartMessage(for streak: Int) -> String {
        switch streak {
        case 0:
            let messages = [
                "Your night routine is waiting for you.",
                "2 minutes now = better sleep tonight.",
                "A small ritual goes a long way.",
                "Wind down. You've earned it.",
            ]
            return messages.randomElement()!
        case 1...3:
            let messages = [
                "You're building something. Keep going. 🔥",
                "Day \(streak + 1) starts tonight.",
                "Small habits, big results. Don't break the chain.",
                "Your streak is just getting started 🌙",
            ]
            return messages.randomElement()!
        case 4...6:
            let messages = [
                "\(streak) nights in. You're making this stick.",
                "Your routine is becoming a ritual. 🌙",
                "Keep it up — \(streak) days and counting 🔥",
                "Almost a week. Don't stop now.",
            ]
            return messages.randomElement()!
        case 7...13:
            let messages = [
                "\(streak) day streak. This is a habit now.",
                "A full week of good nights. Keep going 🔥",
                "You've built something real — \(streak) days strong.",
                "Your future self thanks you. \(streak) days 🌙",
            ]
            return messages.randomElement()!
        default:
            let messages = [
                "\(streak) days. Legendary. 🔥",
                "Don't let \(streak) days end tonight.",
                "Your streak is rare. Protect it 🌙",
                "\(streak) nights of better sleep. Keep the streak alive.",
            ]
            return messages.randomElement()!
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
