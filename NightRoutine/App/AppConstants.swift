import Foundation

enum AppConstants {
    static let appName = "Night Routine"
    static let appVersion = "1.0.0"
    static let bundleIdentifier = "io.nightroutine.app"

    // Support URLs (hosted on GitHub Pages)
    static let privacyPolicyURL = URL(string: "https://nszarmack96.github.io/NightRoutine/privacy.html")!
    static let supportEmail = "support@nightroutine.io"
    static let termsOfServiceURL = URL(string: "https://nszarmack96.github.io/NightRoutine/terms.html")!

    // Free tier limits
    static let freeTierStepLimit = 6

    // Default routine steps (seeded on first launch)
    static let defaultSteps = [
        "Skincare",
        "Brush teeth",
        "Set phone down",
        "Stretch",
        "Water",
        "Lights off"
    ]

    // UserDefaults keys
    enum StorageKey: String {
        case routineSteps = "nightroutine.steps"
        case routineState = "nightroutine.state"
        case userSettings = "nightroutine.settings"
        case streakData = "nightroutine.streak"
        case premiumStatus = "nightroutine.premium"
        case hasCompletedOnboarding = "nightroutine.onboarded"
    }

    // StoreKit product identifiers
    enum ProductID: String {
        case lifetimePremium = "io.nightroutine.premium.lifetime"
    }
}
