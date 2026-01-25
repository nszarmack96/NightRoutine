import Foundation

struct RoutineStep: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isEnabled: Bool
    var sortOrder: Int

    init(id: UUID = UUID(), title: String, isEnabled: Bool = true, sortOrder: Int) {
        self.id = id
        self.title = title
        self.isEnabled = isEnabled
        self.sortOrder = sortOrder
    }
}

extension RoutineStep {
    static func defaultSteps() -> [RoutineStep] {
        AppConstants.defaultSteps.enumerated().map { index, title in
            RoutineStep(title: title, sortOrder: index)
        }
    }
}
