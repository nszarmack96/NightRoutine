import Foundation
import SwiftUI

@MainActor
final class TonightViewModel: ObservableObject {
    @Published var steps: [RoutineStep] = []
    @Published var routineState: RoutineState = RoutineState()
    @Published var streakData: StreakData = StreakData()

    private let persistence: PersistenceService

    var enabledSteps: [RoutineStep] {
        steps.filter { $0.isEnabled }.sorted { $0.sortOrder < $1.sortOrder }
    }

    var allComplete: Bool {
        guard !enabledSteps.isEmpty else { return false }
        return enabledSteps.allSatisfy { routineState.isStepCompleted($0.id) }
    }

    var currentStreak: Int {
        streakData.currentStreak()
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
        persistence.saveRoutineState(routineState)

        // Remove today from streak if we reset
        let todayKey = RoutineState.todayKey()
        streakData.markIncomplete(dateKey: todayKey)
        persistence.saveStreakData(streakData)
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
