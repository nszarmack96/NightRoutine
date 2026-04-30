import Foundation

protocol PersistenceServiceProtocol {
    func save<T: Encodable>(_ value: T, forKey key: AppConstants.StorageKey)
    func load<T: Decodable>(forKey key: AppConstants.StorageKey) -> T?
    func remove(forKey key: AppConstants.StorageKey)
}

final class PersistenceService: PersistenceServiceProtocol {
    static let shared = PersistenceService()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {}

    func save<T: Encodable>(_ value: T, forKey key: AppConstants.StorageKey) {
        do {
            let data = try encoder.encode(value)
            defaults.set(data, forKey: key.rawValue)
        } catch {
            print("PersistenceService: Failed to encode \(key.rawValue): \(error)")
        }
    }

    func load<T: Decodable>(forKey key: AppConstants.StorageKey) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else {
            return nil
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("PersistenceService: Failed to decode \(key.rawValue): \(error)")
            return nil
        }
    }

    func remove(forKey key: AppConstants.StorageKey) {
        defaults.removeObject(forKey: key.rawValue)
    }
}

// MARK: - Convenience Methods

extension PersistenceService {
    // MARK: Routine Steps

    func loadSteps() -> [RoutineStep] {
        load(forKey: .routineSteps) ?? []
    }

    func saveSteps(_ steps: [RoutineStep]) {
        save(steps, forKey: .routineSteps)
    }

    // MARK: Routine State

    func loadRoutineState() -> RoutineState {
        load(forKey: .routineState) ?? RoutineState()
    }

    func saveRoutineState(_ state: RoutineState) {
        save(state, forKey: .routineState)
    }

    // MARK: User Settings

    func loadSettings() -> UserSettings {
        load(forKey: .userSettings) ?? .default
    }

    func saveSettings(_ settings: UserSettings) {
        save(settings, forKey: .userSettings)
    }

    // MARK: Streak Data

    func loadStreakData() -> StreakData {
        load(forKey: .streakData) ?? StreakData()
    }

    func saveStreakData(_ data: StreakData) {
        save(data, forKey: .streakData)
    }

    // MARK: Premium Status

    func loadPremiumStatus() -> PremiumStatus {
        load(forKey: .premiumStatus) ?? .free
    }

    func savePremiumStatus(_ status: PremiumStatus) {
        save(status, forKey: .premiumStatus)
    }

    // MARK: Daily History

    func loadDailyHistory() -> DailyHistory {
        load(forKey: .dailyHistory) ?? [:]
    }

    func saveDailyHistory(_ history: DailyHistory) {
        save(history, forKey: .dailyHistory)
    }

    /// Returns step IDs that have been present but not completed 3 or more times.
    /// Only considers non-skipped nights so skip-without-guilt doesn't pollute the signal.
    func frequentlySkippedStepIDs(threshold: Int = 3) -> Set<UUID> {
        let history = loadDailyHistory()
        var skipCounts: [UUID: Int] = [:]
        for record in history.values where !record.wasSkipped {
            for snapshot in record.stepSnapshots where !record.completedStepIDs.contains(snapshot.id) {
                skipCounts[snapshot.id, default: 0] += 1
            }
        }
        return Set(skipCounts.filter { $0.value >= threshold }.keys)
    }

    func recordDay(dateKey: String, completedStepIDs: Set<UUID>, steps: [RoutineStep], wasSkipped: Bool) {
        var history = loadDailyHistory()
        let snapshots = steps.map { StepSnapshot(id: $0.id, title: $0.title) }
        history[dateKey] = DailyRecord(
            completedStepIDs: completedStepIDs,
            stepSnapshots: snapshots,
            wasSkipped: wasSkipped
        )
        saveDailyHistory(history)
    }

    // MARK: Onboarding

    func hasCompletedOnboarding() -> Bool {
        defaults.bool(forKey: AppConstants.StorageKey.hasCompletedOnboarding.rawValue)
    }

    func setOnboardingCompleted() {
        defaults.set(true, forKey: AppConstants.StorageKey.hasCompletedOnboarding.rawValue)
    }

    // MARK: First Launch Seeding

    func seedDefaultStepsIfNeeded() {
        let existingSteps: [RoutineStep]? = load(forKey: .routineSteps)
        if existingSteps == nil || existingSteps?.isEmpty == true {
            saveSteps(RoutineStep.defaultSteps())
        }
    }
}
