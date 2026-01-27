# Changelog

All notable changes to the NightRoutine app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Phase 7: Paywall and premium features
- Phase 8: UX polish and accessibility
- Phase 9: App Store readiness

---

## [0.3.0] - 2025-01-26

### Added
- **NotificationService**: Handles notification authorization and scheduling
- **SettingsView**: Full settings screen with reminder controls
- **SettingsViewModel**: MVVM state management for settings
- **Reminder Toggle**: Enable/disable daily notifications
- **Time Picker**: Select reminder time with wheel picker
- **Custom Message**: Premium users can customize notification text
- **Permission Handling**: Graceful denial handling with Settings redirect

### Changed
- EditRoutineView now links to Settings via "Reminders & Settings" button
- Paywall placeholder updated to mention custom reminder messages

---

## [0.2.0] - 2025-01-26

### Added
- **Edit Routine Screen**: Full routine customization with gear icon navigation
- **EditRoutineViewModel**: MVVM architecture for editing operations
- **Add Step**: Add new custom steps to routine
- **Delete Step**: Remove steps with trash button
- **Reorder Steps**: Drag handles for reordering (onMove support)
- **Toggle Steps**: Enable/disable steps without deleting
- **Edit Step Title**: Modal sheet for renaming steps
- **Free Tier Enforcement**: Paywall placeholder when exceeding 6 steps
- **Reset to Defaults**: Option to restore default routine steps

### Changed
- TonightView now has gear icon in toolbar to access Edit Routine
- EditRoutineView uses sheet presentation with data reload on dismiss

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
| 0.2.0 | 2025-01-26 | Edit routine working |
| 0.3.0 | 2025-01-26 | Notifications working |
| 0.4.0 | TBD | Premium purchase working |
| 1.0.0 | TBD | App Store release |
