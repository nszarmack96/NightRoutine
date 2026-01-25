# NightRoutine - Technical Architecture

This document describes the technical design decisions and architecture for the Night Routine app.

## Overview

NightRoutine is a native iOS app built with SwiftUI, designed for simplicity and reliability. The app operates entirely offline with local-only data storage.

## Design Principles

1. **Simplicity First**: Minimal dependencies, straightforward architecture
2. **Offline-First**: No network required for core functionality
3. **Privacy-Focused**: All data stays on device
4. **Native Feel**: Follow iOS conventions and HIG

---

## Tech Stack

| Layer | Technology | Rationale |
|-------|------------|-----------|
| UI | SwiftUI | Native, declarative, modern iOS development |
| Architecture | MVVM | Clean separation, testable, SwiftUI-friendly |
| Persistence | UserDefaults + Codable | Simple, no setup, sufficient for small data |
| Notifications | UNUserNotificationCenter | Native local notifications |
| Purchases | StoreKit 2 | Modern async/await API, no third-party SDK |

---

## Data Models

### RoutineStep

Represents a single step in the user's routine.

```swift
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
```

### RoutineState

Tracks the current night's session progress.

```swift
struct RoutineState: Codable {
    var completedStepIDs: Set<UUID>
    var sessionDateKey: String  // Format: "YYYY-MM-DD"

    static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    var isToday: Bool {
        sessionDateKey == Self.todayKey()
    }
}
```

### UserSettings

User preferences and configuration.

```swift
struct UserSettings: Codable {
    var reminderEnabled: Bool
    var reminderHour: Int      // 0-23
    var reminderMinute: Int    // 0-59
    var reminderMessage: String?

    static let `default` = UserSettings(
        reminderEnabled: false,
        reminderHour: 21,
        reminderMinute: 0,
        reminderMessage: nil
    )
}
```

### StreakData

Tracks completed nights for streak calculation.

```swift
struct StreakData: Codable {
    var completedDates: Set<String>  // Set of "YYYY-MM-DD" strings

    func currentStreak() -> Int {
        // Calculate consecutive days ending today or yesterday
        // Implementation handles timezone correctly
    }
}
```

### PremiumStatus

Tracks user's premium entitlement.

```swift
struct PremiumStatus: Codable {
    var isPremium: Bool
    var purchaseDate: Date?

    static let free = PremiumStatus(isPremium: false, purchaseDate: nil)
}
```

---

## Persistence Layer

### Storage Keys

```swift
enum StorageKey: String {
    case routineSteps = "nightroutine.steps"
    case routineState = "nightroutine.state"
    case userSettings = "nightroutine.settings"
    case streakData = "nightroutine.streak"
    case premiumStatus = "nightroutine.premium"
    case hasCompletedOnboarding = "nightroutine.onboarded"
}
```

### PersistenceService

```swift
protocol PersistenceService {
    func save<T: Encodable>(_ value: T, forKey key: StorageKey)
    func load<T: Decodable>(forKey key: StorageKey) -> T?
    func remove(forKey key: StorageKey)
}

class UserDefaultsPersistence: PersistenceService {
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // Implementation...
}
```

---

## App Architecture (MVVM)

### View Layer

```
Views/
├── TonightView.swift          # Main checklist screen
├── EditRoutineView.swift      # Edit/customize steps
├── SettingsView.swift         # App settings
├── PaywallView.swift          # Premium upgrade
└── Components/
    ├── RoutineStepRow.swift   # Single step row
    ├── StreakBadge.swift      # Streak display
    └── CompletionView.swift   # "Done for tonight" state
```

### ViewModel Layer

```swift
@MainActor
class TonightViewModel: ObservableObject {
    @Published var steps: [RoutineStep] = []
    @Published var completedIDs: Set<UUID> = []
    @Published var currentStreak: Int = 0
    @Published var isAllComplete: Bool = false

    private let persistence: PersistenceService

    func toggleStep(_ step: RoutineStep) { }
    func loadTonightState() { }
    private func checkCompletion() { }
}
```

### Service Layer

```
Services/
├── PersistenceService.swift   # UserDefaults wrapper
├── NotificationService.swift  # Local notification scheduling
├── StoreService.swift         # StoreKit 2 purchases
└── StreakService.swift        # Streak calculation logic
```

---

## Navigation Structure

```
App Entry
    │
    ▼
┌─────────────────┐
│  TonightView    │  ← Main screen (always visible)
│  (Tab or Root)  │
└────────┬────────┘
         │
    ┌────┴────┬─────────────┐
    ▼         ▼             ▼
┌────────┐ ┌────────┐ ┌──────────┐
│ Edit   │ │Settings│ │ Paywall  │
│Routine │ │        │ │ (Sheet)  │
└────────┘ └────────┘ └──────────┘
```

Navigation approach: **Single-screen focus** with sheets/modals for secondary screens.

---

## Notification System

### Scheduling Logic

```swift
class NotificationService {
    func scheduleNightlyReminder(hour: Int, minute: Int, message: String?) async {
        // 1. Request permission if not granted
        // 2. Remove existing scheduled notifications
        // 3. Create new trigger for daily repeat
        // 4. Schedule notification
    }

    func cancelAllReminders() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["nightly-reminder"])
    }
}
```

### Notification Content

- **Title**: "Time to Wind Down"
- **Body**: Custom message (premium) or default "Your evening routine is waiting"
- **Sound**: Default system sound

---

## StoreKit 2 Integration

### Product Configuration

```swift
enum StoreProduct: String {
    case lifetimePremium = "com.yourname.nightroutine.premium.lifetime"
}
```

### Purchase Flow

```swift
class StoreService: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var products: [Product] = []

    func loadProducts() async { }
    func purchase(_ product: Product) async throws -> Bool { }
    func restorePurchases() async { }
    func checkEntitlement() async { }
}
```

### Entitlement Caching

- Cache premium status in UserDefaults for offline access
- Re-validate with StoreKit on each app launch
- Trust cached value for feature gating

---

## Free vs Premium Features

| Feature | Free | Premium |
|---------|------|---------|
| Routine steps | Up to 6 | Unlimited |
| Default steps | Yes | Yes |
| Reorder steps | Yes | Yes |
| Custom step titles | Yes | Yes |
| Streak tracking | Yes | Yes |
| Nightly reminder | Yes | Yes |
| Custom reminder message | No | Yes |

---

## Constants

```swift
enum AppConstants {
    static let appName = "NightRoutine"
    static let freeTierStepLimit = 6

    static let defaultSteps = [
        "Skincare",
        "Brush teeth",
        "Set phone down",
        "Stretch",
        "Water",
        "Lights off"
    ]
}
```

---

## Error Handling Strategy

### Persistence Errors
- Fail silently, use default values
- Log errors for debugging (no crash)

### StoreKit Errors
- Show user-friendly error messages
- Provide retry option
- Log detailed error for debugging

### Notification Errors
- Handle permission denial gracefully
- Show settings prompt if notifications disabled

---

## Testing Strategy

### Unit Tests
- StreakService calculation logic
- Persistence encoding/decoding
- ViewModel state management

### UI Tests
- Complete routine flow
- Edit routine flow
- Purchase flow (sandbox)

### Manual Testing
- Notification delivery timing
- StoreKit sandbox purchases
- Device rotation and Dynamic Type

---

## Security Considerations

- No sensitive data stored (no passwords, no PII beyond routine titles)
- Premium status validated with StoreKit (no server trust issues)
- All data local to device
- No analytics or tracking in MVP

---

## Future Architecture Considerations

If expanding post-MVP:

- **iCloud Sync**: Would require migrating to CloudKit or SwiftData
- **Widgets**: Would add WidgetKit extension
- **Watch App**: Would add WatchKit extension with shared data model
- **Multiple Routines**: Would require data model refactor

These are explicitly out of scope for MVP.
