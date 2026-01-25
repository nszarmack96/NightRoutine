import Foundation

struct RoutineState: Codable {
    var completedStepIDs: Set<UUID>
    var sessionDateKey: String

    init(completedStepIDs: Set<UUID> = [], sessionDateKey: String = RoutineState.todayKey()) {
        self.completedStepIDs = completedStepIDs
        self.sessionDateKey = sessionDateKey
    }

    static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: Date())
    }

    var isToday: Bool {
        sessionDateKey == Self.todayKey()
    }

    mutating func toggleStep(_ stepID: UUID) {
        if completedStepIDs.contains(stepID) {
            completedStepIDs.remove(stepID)
        } else {
            completedStepIDs.insert(stepID)
        }
    }

    func isStepCompleted(_ stepID: UUID) -> Bool {
        completedStepIDs.contains(stepID)
    }

    mutating func resetIfNewDay() {
        if !isToday {
            completedStepIDs = []
            sessionDateKey = Self.todayKey()
        }
    }
}
