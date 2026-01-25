import Foundation

struct StreakData: Codable {
    var completedDates: Set<String>

    init(completedDates: Set<String> = []) {
        self.completedDates = completedDates
    }

    mutating func markCompleted(dateKey: String) {
        completedDates.insert(dateKey)
    }

    mutating func markIncomplete(dateKey: String) {
        completedDates.remove(dateKey)
    }

    func isCompleted(dateKey: String) -> Bool {
        completedDates.contains(dateKey)
    }

    func currentStreak() -> Int {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current

        var streak = 0
        var checkDate = Date()

        // Check if today is completed, if not start from yesterday
        let todayKey = formatter.string(from: checkDate)
        if !completedDates.contains(todayKey) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                return 0
            }
            checkDate = yesterday
        }

        // Count consecutive days backwards
        while true {
            let dateKey = formatter.string(from: checkDate)
            if completedDates.contains(dateKey) {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                    break
                }
                checkDate = previousDay
            } else {
                break
            }
        }

        return streak
    }
}
