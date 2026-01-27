import Foundation
import SwiftUI

@MainActor
final class EditRoutineViewModel: ObservableObject {
    @Published var steps: [RoutineStep] = []
    @Published var showingAddStep = false
    @Published var showingPaywall = false
    @Published var editingStep: RoutineStep?

    private let persistence: PersistenceService
    private let isPremium: Bool

    var canAddMoreSteps: Bool {
        isPremium || steps.count < AppConstants.freeTierStepLimit
    }

    var stepLimitMessage: String {
        "Free tier limited to \(AppConstants.freeTierStepLimit) steps"
    }

    init(persistence: PersistenceService = .shared) {
        self.persistence = persistence
        self.isPremium = persistence.loadPremiumStatus().isPremium
        loadSteps()
    }

    func loadSteps() {
        steps = persistence.loadSteps().sorted { $0.sortOrder < $1.sortOrder }
    }

    func addStep(title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        if !canAddMoreSteps {
            showingPaywall = true
            return
        }

        let newStep = RoutineStep(
            title: title.trimmingCharacters(in: .whitespaces),
            isEnabled: true,
            sortOrder: steps.count
        )
        steps.append(newStep)
        saveSteps()
    }

    func deleteStep(_ step: RoutineStep) {
        steps.removeAll { $0.id == step.id }
        reindexSteps()
        saveSteps()
    }

    func deleteSteps(at offsets: IndexSet) {
        steps.remove(atOffsets: offsets)
        reindexSteps()
        saveSteps()
    }

    func moveSteps(from source: IndexSet, to destination: Int) {
        steps.move(fromOffsets: source, toOffset: destination)
        reindexSteps()
        saveSteps()
    }

    func toggleStepEnabled(_ step: RoutineStep) {
        guard let index = steps.firstIndex(where: { $0.id == step.id }) else { return }
        steps[index].isEnabled.toggle()
        saveSteps()
    }

    func updateStepTitle(_ step: RoutineStep, newTitle: String) {
        guard let index = steps.firstIndex(where: { $0.id == step.id }) else { return }
        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        steps[index].title = trimmedTitle
        saveSteps()
    }

    func resetToDefaults() {
        steps = RoutineStep.defaultSteps()
        saveSteps()
    }

    private func reindexSteps() {
        for index in steps.indices {
            steps[index].sortOrder = index
        }
    }

    private func saveSteps() {
        persistence.saveSteps(steps)
    }
}
