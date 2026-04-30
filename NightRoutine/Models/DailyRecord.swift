import Foundation

/// A snapshot of one night's routine — what was enabled, what was completed.
struct DailyRecord: Codable {
    /// IDs of steps that were checked off that night
    var completedStepIDs: Set<UUID>
    /// All enabled steps that night (id + title), for "most skipped step" analysis
    var stepSnapshots: [StepSnapshot]
    /// Whether the routine was skipped without guilt
    var wasSkipped: Bool

    var totalSteps: Int { stepSnapshots.count }

    var completionPercentage: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(completedStepIDs.count) / Double(totalSteps)
    }

    /// IDs of steps that existed but were NOT completed
    var skippedStepIDs: Set<UUID> {
        let allIDs = Set(stepSnapshots.map(\.id))
        return allIDs.subtracting(completedStepIDs)
    }
}

struct StepSnapshot: Codable, Identifiable {
    var id: UUID
    var title: String
}

/// Keyed by "yyyy-MM-dd" date strings
typealias DailyHistory = [String: DailyRecord]
