# Changelog

All notable changes to the NightRoutine app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Phase 5: Edit routine screen
- Phase 6: Nightly reminder notifications
- Phase 7: Paywall and premium features
- Phase 8: UX polish and accessibility
- Phase 9: App Store readiness

---

## [0.1.0] - 2025-01-25

### Added
- **Data Models**: RoutineStep, RoutineState, UserSettings, StreakData, PremiumStatus
- **Persistence**: UserDefaults + Codable storage with PersistenceService
- **Default Routine**: 6 default steps seeded on first launch
- **Tonight Screen**: Full checklist with completion tracking
- **Streak Tracking**: Consecutive day streak with flame badge display
- **TonightViewModel**: MVVM architecture for state management

### Changed
- TonightView now uses real persistence instead of placeholder data
- App resets completed steps at midnight automatically

---

## [0.0.1] - 2025-01-25

### Added
- Initial project setup
- Xcode project structure (iOS 16.0+, SwiftUI)
- Project documentation (README, ROADMAP, ARCHITECTURE)
- Basic Tonight screen shell
- Git repository initialized
- GitHub repository created

---

## Version History

| Version | Date | Milestone |
|---------|------|-----------|
| 0.0.1 | 2025-01-25 | Project setup |
| 0.1.0 | 2025-01-25 | Tonight screen working with persistence |
| 0.2.0 | TBD | Edit routine working |
| 0.3.0 | TBD | Notifications working |
| 0.4.0 | TBD | Premium purchase working |
| 1.0.0 | TBD | App Store release |
