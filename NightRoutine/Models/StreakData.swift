import Foundation

struct StreakData: Codable {
    var completedDates: Set<String>
    var frozenDates: Set<String>

    init(completedDates: Set<String> = [], frozenDates: Set<String> = []) {
        self.completedDates = completedDates
        self.frozenDates = frozenDates
    }

    // Custom decoder so existing saved data (without frozenDates) doesn't break
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        completedDates = try container.decode(Set<String>.self, forKey: .completedDates)
        frozenDates = try container.decodeIfPresent(Set<String>.self, forKey: .frozenDates) ?? []
    }

    mutating func markCompleted(dateKey: String) {
        completedDates.insert(dateKey)
    }

    mutating func markIncomplete(dateKey: String) {
        completedDates.remove(dateKey)
    }

    func isCompleted(dateKey: String) -> Bool {
        completedDates.contains(dateKey) || frozenDates.contains(dateKey)
    }

    // MARK: - Streak Calculation

    func currentStreak() -> Int {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current

        var streak = 0
        var checkDate = Date()

        // Check if today counts (completed or frozen), if not start from yesterday
        let todayKey = formatter.string(from: checkDate)
        if !isCompleted(dateKey: todayKey) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                return 0
            }
            checkDate = yesterday
        }

        // Count consecutive days backwards (completed or frozen both count)
        while true {
            let dateKey = formatter.string(from: checkDate)
            if isCompleted(dateKey: dateKey) {
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

    // MARK: - Freeze Logic

    /// Number of freezes used in the current ISO week (Mon–Sun)
    var freezesUsedThisWeek: Int {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current

        let today = Date()
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today)

        return frozenDates.filter { dateKey in
            guard let date = formatter.date(from: dateKey),
                  let interval = weekInterval else { return false }
            return interval.contains(date)
        }.count
    }

    var freezesRemainingThisWeek: Int {
        max(0, AppConstants.maxFreezesPerWeek - freezesUsedThisWeek)
    }

    var canUseFreeze: Bool {
        freezesRemainingThisWeek > 0
    }

    /// Freeze yesterday to protect streak. Returns true if successful.
    mutating func freezeYesterday() -> Bool {
        guard canUseFreeze else { return false }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) else { return false }
        let yesterdayKey = formatter.string(from: yesterday)
        // Only freeze if yesterday was actually missed
        guard !completedDates.contains(yesterdayKey) else { return false }
        frozenDates.insert(yesterdayKey)
        return true
    }

    /// True if yesterday was missed and a streak was active the day before
    func streakAtRisk() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        let calendar = Calendar.current
        let today = Date()

        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
              let dayBefore = calendar.date(byAdding: .day, value: -2, to: today) else { return false }

        let todayKey = formatter.string(from: today)
        let yesterdayKey = formatter.string(from: yesterday)
        let dayBeforeKey = formatter.string(from: dayBefore)

        // At risk if: today not yet done, yesterday was missed, but day before was completed
        return !isCompleted(dateKey: todayKey)
            && !isCompleted(dateKey: yesterdayKey)
            && isCompleted(dateKey: dayBeforeKey)
    }
}
