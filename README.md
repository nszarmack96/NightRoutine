# NightRoutine

A calm, focused iOS app to help you build a consistent nighttime wind-down routine.

## About

NightRoutine helps users establish healthy bedtime habits through a simple, frictionless checklist experience. No social features, no gamification pressure — just a peaceful way to end your day.

### Key Features

- **Tonight Screen**: One-tap checklist to complete your nightly routine
- **Customizable Steps**: Add, remove, reorder, and rename routine steps
- **Gentle Streaks**: Track consistency without shame or pressure
- **Nightly Reminders**: Optional local notifications at your chosen time
- **Premium Upgrade**: One-time purchase for unlimited steps and custom reminders

## Tech Stack

| Component | Technology |
|-----------|------------|
| **UI Framework** | SwiftUI |
| **Minimum iOS** | iOS 16.0+ |
| **Persistence** | UserDefaults + Codable |
| **Notifications** | UNUserNotificationCenter |
| **In-App Purchase** | StoreKit 2 |
| **Architecture** | MVVM |

## Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 16.0+ deployment target
- Apple Developer account (for testing IAP and notifications)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/nszarmack96/NightRoutine.git
   cd NightRoutine_App
   ```

2. Open the Xcode project:
   ```bash
   open NightRoutine.xcodeproj
   ```

3. Select your development team in Signing & Capabilities

4. Build and run on simulator or device

## Project Structure

```
NightRoutine_App/
├── NightRoutine/              # Xcode project source
│   ├── App/                   # App entry point, constants
│   ├── Models/                # Data models (RoutineStep, etc.)
│   ├── Views/                 # SwiftUI views
│   ├── ViewModels/            # View models
│   ├── Services/              # Persistence, notifications, StoreKit
│   └── Resources/             # Assets, LaunchScreen
├── docs/
│   ├── ROADMAP.md            # MVP phases and progress
│   ├── ARCHITECTURE.md       # Technical design decisions
│   └── CHANGELOG.md          # Version history
└── README.md
```

## Documentation

- [Roadmap](docs/ROADMAP.md) - MVP phases and task tracking
- [Architecture](docs/ARCHITECTURE.md) - Technical design and data models
- [Changelog](docs/CHANGELOG.md) - Version history

## License

Private project - All rights reserved.
