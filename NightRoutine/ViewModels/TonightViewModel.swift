import Foundation
import SwiftUI

@MainActor
final class TonightViewModel: ObservableObject {
    @Published var steps: [RoutineStep] = []
    @Published var routineState: RoutineState = RoutineState()
    @Published var streakData: StreakData = StreakData()
    @Published var settings: UserSettings = .default

    private let persistence: PersistenceService

    var enabledSteps: [RoutineStep] {
        steps.filter { $0.isEnabled }.sorted { $0.sortOrder < $1.sortOrder }
    }

    var allComplete: Bool {
        guard !enabledSteps.isEmpty else { return false }
        return enabledSteps.allSatisfy { routineState.isStepCompleted($0.id) }
    }

    /// True if routine is complete OR was skipped
    var showCompletion: Bool {
        allComplete || routineState.wasSkipped
    }

    /// True if this was a skip (not full completion)
    var wasSkipped: Bool {
        routineState.wasSkipped
    }

    var currentStreak: Int {
        streakData.currentStreak()
    }

    /// Check if haptics should be played (respects Quiet Mode)
    var hapticsEnabled: Bool {
        !settings.quietModeEnabled
    }

    init(persistence: PersistenceService = .shared) {
        self.persistence = persistence
        loadData()
    }

    func loadData() {
        // Seed default steps on first launch
        persistence.seedDefaultStepsIfNeeded()

        // Load all data
        steps = persistence.loadSteps()
        routineState = persistence.loadRoutineState()
        streakData = persistence.loadStreakData()
        settings = persistence.loadSettings()

        // Reset state if it's a new day
        routineState.resetIfNewDay()
        persistence.saveRoutineState(routineState)
    }

    func toggleStep(_ step: RoutineStep) {
        routineState.toggleStep(step.id)
        persistence.saveRoutineState(routineState)

        // Check if routine is now complete
        updateStreakIfNeeded()
    }

    func isStepCompleted(_ step: RoutineStep) -> Bool {
        routineState.isStepCompleted(step.id)
    }

    func resetTonight() {
        routineState.completedStepIDs = []
        routineState.wasSkipped = false
        persistence.saveRoutineState(routineState)

        // Remove today from streak if we reset
        let todayKey = RoutineState.todayKey()
        streakData.markIncomplete(dateKey: todayKey)
        persistence.saveStreakData(streakData)
    }

    /// Skip the routine without guilt - shows completion screen but doesn't increment streak
    func skipWithoutGuilt() {
        routineState.skipWithoutGuilt()
        persistence.saveRoutineState(routineState)
        // Note: We intentionally do NOT update streak here
    }

    private func updateStreakIfNeeded() {
        let todayKey = RoutineState.todayKey()

        if allComplete {
            streakData.markCompleted(dateKey: todayKey)
        } else {
            streakData.markIncomplete(dateKey: todayKey)
        }

        persistence.saveStreakData(streakData)
    }
}
