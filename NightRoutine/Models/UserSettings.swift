import Foundation

// Quote theme options for completion screen (Premium feature)
enum QuoteTheme: String, Codable, CaseIterable {
    case calm = "Calm"
    case romantic = "Romantic"
    case stoic = "Stoic"
    case minimal = "Minimal"
    case encouraging = "Encouraging"

    var displayName: String { rawValue }
}

struct UserSettings: Codable {
    var reminderEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int
    var reminderMessage: String?
    var quietModeEnabled: Bool  // Dims UI and disables haptics
    var quoteTheme: QuoteTheme  // Premium: Selected quote theme

    init(
        reminderEnabled: Bool = false,
        reminderHour: Int = 21,
        reminderMinute: Int = 0,
        reminderMessage: String? = nil,
        quietModeEnabled: Bool = false,
        quoteTheme: QuoteTheme = .calm
    ) {
        self.reminderEnabled = reminderEnabled
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.reminderMessage = reminderMessage
        self.quietModeEnabled = quietModeEnabled
        self.quoteTheme = quoteTheme
    }

    static let `default` = UserSettings()

    var reminderTimeComponents: DateComponents {
        var components = DateComponents()
        components.hour = reminderHour
        components.minute = reminderMinute
        return components
    }

    var reminderTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        var components = DateComponents()
        components.hour = reminderHour
        components.minute = reminderMinute
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }
}
