# Changelog

All notable changes to the NightRoutine app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

---

## [1.2.0] - 2026-04-30

### Added
- **Smarter Notifications**: Contextual daily reminder messages based on current streak tier (5 tiers: new user → building → habit forming → week+ → legendary). Messages auto-update after each completed routine.
- **Streak Protection (Freezes)**: Use up to 2 freezes per week to protect a streak after a missed night. Auto-prompt appears on app open when streak is at risk. Freeze badge shown on completion screen when used. Backward-compatible decoder ensures existing streaks survive the update.
- **Focused Routine Mode**: Full-screen step-by-step flow launched from a "Start" button on the Tonight screen. Supports tap to complete, swipe gestures to advance/go back, and per-step skip. Completions sync back to the main checklist.
- **Weekly Insights**: New insights screen accessible via Settings. Shows nights completed this week, average completion %, 7-day dot calendar, current streak, total nights completed, and most skipped step. Backed by a new `DailyRecord`/`DailyHistory` data model recorded on each completion and skip.
- **Shareable Streak Card**: One-tap share from the completion screen generates a 1080×1080 image (moon icon, streak count, date, subtle branding) and opens the native iOS share sheet.
- **Routine Presets**: "Load a Preset Routine" button in Edit Routine opens a preset picker with 4 options — Quick, Deep Wind Down, High Discipline, and Mindful. Each preset is fully editable after applying.
- **Adaptive Suggestions**: When a step has been skipped 3+ times on non-skipped nights, a nudge card appears at the top of Edit Routine suggesting removal, with a one-tap "Remove" button per flagged step.
- **Routine History Calendar**: Full month-by-month calendar in Insights showing completed (purple), freeze-used (cyan), and missed nights. Includes month navigation and a legend.

### Added
- **Home Screen**: Persistent daily landing page shown on every launch. Displays current streak, date, greeting, and a "Begin Tonight's Routine" CTA. Turns green with a checkmark when routine is already completed for the night.

### Changed
- `StreakData` model now includes `frozenDates: Set<String>` (backward-compatible via custom decoder)
- `NotificationService.scheduleReminder` now accepts a `streak` parameter for contextual messaging
- `DailyRecord` and `DailyHistory` models added for per-night step tracking
- `InsightsView` now uses `DailyHistory` for all-time stats and calendar
- Edit Routine screen now shows adaptive skip nudges and preset loader
- App launch flow updated: new users → Onboarding → Home → Checklist; returning users → Home → Checklist
- Streak badge in checklist toolbar now opens Insights on tap (was visual-only)
- Share streak card now includes App Store link alongside image in native share sheet
- Routine presets now enforce free tier step limit (6 steps); paywall shown if preset exceeds limit

### Fixed
- **IAP infinite spinner**: Purchase button no longer freezes indefinitely. Removed automatic `AppStore.sync()` call on paywall open. When price fails to load, a tappable "Unable to load price — Tap to retry" button is shown instead.
- **Share card blank screen**: `ImageRenderer` now guards against nil output and sets `proposedSize` before presenting share sheet.
- **Preset paywall bypass**: Free users applying presets with more than 6 steps were getting all steps for free. Now capped at 6 with paywall prompt.

---

## [1.1.0] - 2026-01-27

### Added
- **"Skip Without Guilt" Button**: Graceful exit option at bottom of Tonight screen
  - "Not tonight — and that's okay" messaging
  - Shows calm completion screen without affecting streak
  - Different icon (moon.zzz) and messaging for skipped nights
- **Step-Level Notes**: Optional personal notes for each routine step
  - Note editing in step edit sheet
  - Subtle note indicator on steps with notes
  - Long-press to reveal note inline
- **Quiet Mode**: Toggle in Settings → Experience section
  - Dims screen with subtle overlay when enabled
  - Disables haptic feedback during routine
- **Quote Theme Packs (Premium)**: 5 themed quote collections
  - Calm, Romantic, Stoic, Minimal, Encouraging themes
  - Theme picker in Settings (Premium only)
  - Completion screen displays themed quotes
- **"Tomorrow Starts Now" Preview**: Reassurance message on completion
  - Rotates through encouraging messages about tomorrow
  - Appears for both completed and skipped states
- **QuoteService**: Centralized service for themed quotes and messages

### Changed
- RoutineStep model now includes optional `note` field
- RoutineState model tracks `wasSkipped` state
- UserSettings includes `quietModeEnabled` and `quoteTheme`
- TonightView refactored with extracted sub-components for better performance
- Completion view now adapts content based on skip vs complete state

---

## [1.0.0] - 2026-01-26

### Added
- **Privacy Policy Link**: Tappable link in Settings opens privacy policy
- **Terms of Service Link**: Tappable link in Settings opens terms
- **Contact Support**: Email link in Settings with support address
- **Legal Links in Paywall**: Terms and Privacy links in purchase screen
- **Improved Error Messages**: User-friendly purchase error handling
- **Purchase Success Haptic**: Haptic feedback on successful purchase

### Changed
- Version updated to 1.0.0 for App Store release
- PaywallViewModel provides clearer error messages for purchase failures
- Settings now uses AppConstants for version display

---

## [0.5.0] - 2026-01-26

### Added
- **HapticService**: Centralized haptic feedback for all interactions
- **Step Toggle Haptics**: Light impact when checking/unchecking steps
- **Routine Complete Haptics**: Success notification when all steps done
- **Selection Haptics**: Feedback on reset and other selections
- **VoiceOver Labels**: Accessibility labels for StepRow, StreakBadge, ProgressCard
- **Accessibility Hints**: Action hints for all interactive elements

### Changed
- TonightView now triggers haptic feedback on step interactions
- Reset button includes selection haptic feedback
- All UI components have proper accessibility labeling

---

## [0.4.0] - 2025-01-26

### Added
- **StoreKitService**: Full StoreKit 2 integration for in-app purchases
- **PaywallView**: Professional paywall screen with feature highlights
- **PaywallViewModel**: MVVM state management for purchase flow
- **Products.storekit**: StoreKit configuration file for testing
- **Lifetime Premium Product**: One-time $4.99 purchase unlocks all features
- **Purchase Flow**: Complete purchase and restore functionality
- **Success State**: Animated success view after purchase completion

### Changed
- Replaced PaywallPlaceholder with real PaywallView
- EditRoutineView now shows actual paywall when step limit reached
- Premium status persists locally after purchase verification

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
| 0.4.0 | 2025-01-26 | Premium purchase working |
| 0.5.0 | 2026-01-26 | UX polish and accessibility |
| 1.0.0 | 2026-01-26 | App Store ready |
| 1.1.0 | 2026-01-27 | Pre-launch features (Skip, Notes, Quiet Mode, Quotes) |
| 1.2.0 | 2026-04-30 | Retention & growth (Home screen, Insights, Streak Protection, Focused Mode, Share Card, Presets, bug fixes) |
