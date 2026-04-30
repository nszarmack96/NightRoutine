import Foundation
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings: UserSettings
    @Published var showingPermissionAlert = false
    @Published var permissionDenied = false

    private let persistence: PersistenceService
    private let notificationService: NotificationService
    private let isPremium: Bool

    var canCustomizeMessage: Bool {
        isPremium
    }

    var reminderTime: Date {
        get {
            var components = DateComponents()
            components.hour = settings.reminderHour
            components.minute = settings.reminderMinute
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            settings.reminderHour = components.hour ?? 21
            settings.reminderMinute = components.minute ?? 0
            saveAndSchedule()
        }
    }

    @MainActor init(
        persistence: PersistenceService = .shared,
        notificationService: NotificationService = .shared
    ) {
        self.persistence = persistence
        self.notificationService = notificationService
        self.isPremium = persistence.loadPremiumStatus().isPremium
        self.settings = persistence.loadSettings()
    }

    func toggleReminder() async {
        if !settings.reminderEnabled {
            // Turning ON - check permission first
            if notificationService.needsPermissionRequest {
                let granted = await notificationService.requestAuthorization()
                if !granted {
                    permissionDenied = notificationService.isDenied
                    return
                }
            } else if notificationService.isDenied {
                permissionDenied = true
                return
            }

            settings.reminderEnabled = true
        } else {
            // Turning OFF
            settings.reminderEnabled = false
        }

        saveAndSchedule()
    }

    func updateReminderMessage(_ message: String?) {
        guard canCustomizeMessage else { return }
        settings.reminderMessage = message?.trimmingCharacters(in: .whitespaces).isEmpty == true ? nil : message
        saveAndSchedule()
    }

    func toggleQuietMode(_ enabled: Bool) {
        settings.quietModeEnabled = enabled
        persistence.saveSettings(settings)
    }

    func setQuoteTheme(_ theme: QuoteTheme) {
        guard canCustomizeMessage else { return }
        settings.quoteTheme = theme
        persistence.saveSettings(settings)
    }

    private func saveAndSchedule() {
        persistence.saveSettings(settings)
        let streak = persistence.loadStreakData().currentStreak()
        Task {
            await notificationService.scheduleReminder(settings: settings, streak: streak)
        }
    }

    func refreshPermissionStatus() async {
        await notificationService.checkAuthorizationStatus()
        if notificationService.isAuthorized {
            permissionDenied = false
        } else {
            permissionDenied = notificationService.isDenied
        }
    }
}
