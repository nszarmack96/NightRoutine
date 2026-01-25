import Foundation

struct UserSettings: Codable {
    var reminderEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int
    var reminderMessage: String?

    init(
        reminderEnabled: Bool = false,
        reminderHour: Int = 21,
        reminderMinute: Int = 0,
        reminderMessage: String? = nil
    ) {
        self.reminderEnabled = reminderEnabled
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.reminderMessage = reminderMessage
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
