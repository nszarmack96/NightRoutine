# NightRoutine - MVP Roadmap

This document tracks the implementation phases for the Night Routine Wind-Down app.

**Current Phase:** Complete - Ready for App Store Submission

---

## Phase 0: Project Setup - COMPLETE

- [x] Create new iOS app project in Xcode
- [x] Configure SwiftUI as UI framework
- [x] Add basic app icon placeholder
- [x] Add launch screen placeholder
- [x] Define app constants (app name, version, default routine steps)
- [x] Create basic "Tonight" screen shell

**Deliverable:** App launches to a single "Tonight" screen.

---

## Phase 1: Data Model (Local-Only) - COMPLETE

### Models to Define

- [x] `RoutineStep` model
  - `id` (UUID)
  - `title` (String)
  - `isEnabled` (Bool)
  - `sortOrder` (Int)

- [x] `RoutineState` model (current night/session)
  - `completedStepIDs` (Set<UUID>)
  - `sessionDateKey` (String, format: "YYYY-MM-DD")

- [x] `UserSettings` model
  - `reminderEnabled` (Bool)
  - `reminderTime` (DateComponents)
  - `reminderMessage` (String, optional)
  - `freeTierStepLimit` (Int constant = 6)

### Persistence

- [x] Implement UserDefaults + Codable storage
- [x] Define storage keys: `routineSteps`, `settings`, `streakData`
- [x] Create persistence service with save/load methods

**Deliverable:** Steps and settings persist across app restarts.

---

## Phase 2: Default Routine Seed - COMPLETE

- [x] Create default steps list:
  1. "Skincare"
  2. "Brush teeth"
  3. "Set phone down"
  4. "Stretch"
  5. "Water"
  6. "Lights off"

- [x] Implement first-launch seeding logic
- [x] Make seeding idempotent (only if no saved steps exist)

**Deliverable:** New users see a full default routine.

---

## Phase 3: Tonight Screen (Core Flow) - COMPLETE

- [x] Build main "Tonight" checklist screen
  - [x] Header: "Wind Down" + subtle date display
  - [x] List of enabled steps in sort order
  - [x] Large tap targets for each row
  - [x] Visual "complete" state per step

- [x] Implement completion logic
  - [x] Tap toggles step completion for tonight's session
  - [x] Track completions in RoutineState
  - [x] Reset completions at midnight or new session

- [x] Add completion celebration
  - [x] Show calm "Done for tonight" state when all steps complete

**Deliverable:** One-screen, no-friction routine completion.

---

## Phase 4: Streak (Minimal + Non-Shaming) - COMPLETE

- [x] Define completion criteria
  - [x] "Completed night" = all enabled steps checked

- [x] Implement streak storage
  - [x] Save completion per day (date key: "YYYY-MM-DD")
  - [x] Store as Set<String> of completed dates

- [x] Compute streak
  - [x] Count consecutive days with completion
  - [x] Handle timezone correctly

- [x] Display streak
  - [x] Show single number on Tonight screen (small, subtle)
  - [x] No "broken streak" messaging
  - [x] No shame, just information

**Deliverable:** Streak number updates correctly.

---

## Phase 5: Edit Routine (Basic Customization) - COMPLETE

- [x] Create "Edit Routine" screen
  - [x] Navigate from Tonight screen (gear icon or edit button)

- [x] Implement editing features
  - [x] Reorder steps (drag to reorder)
  - [x] Toggle steps enabled/disabled
  - [x] Edit step title (inline or modal)
  - [x] Add new step
  - [x] Delete step (swipe to delete)

- [x] Enforce free-tier limit
  - [x] Check step count before adding
  - [x] If user is free and tries to add > 6 steps, show paywall

**Deliverable:** User can fully customize routine (within tier limits).

---

## Phase 6: Nightly Reminder Notifications - COMPLETE

- [x] Request notification permission
  - [x] Friendly one-time prompt with explanation
  - [x] Handle denial gracefully

- [x] Create Settings screen
  - [x] Toggle reminder on/off
  - [x] Time picker for reminder time
  - [x] Custom reminder message field (premium only)

- [x] Implement notification scheduling
  - [x] Schedule repeating daily local notification
  - [x] Update schedule when time changes
  - [x] Cancel notifications when disabled

**Deliverable:** Reminders fire daily at the chosen time.

---

## Phase 7: Paywall + Entitlements - COMPLETE

### Monetization: One-time "Lifetime Premium" unlock

- [x] Configure StoreKit 2
  - [x] Create non-consumable product: `premium_lifetime`
  - [x] Set up StoreKit configuration for testing

- [x] Define premium features
  - [x] Unlimited steps (free tier = 6)
  - [x] Custom reminder message
  - [x] (Optional) Extra themes

- [x] Build paywall screen
  - [x] Clear value proposition bullets
  - [x] Price button with localized price
  - [x] Restore purchases button
  - [x] Terms/Privacy links

- [x] Implement purchase flow
  - [x] Handle purchase success
  - [x] Handle purchase failure/cancellation
  - [x] Cache entitlement state locally
  - [x] Validate with StoreKit on launch

- [x] Add restore purchases flow

**Deliverable:** Purchase unlocks features, restore works.

---

## Phase 8: Polished UX (MVP-Polish) - COMPLETE

- [x] Visual polish
  - [x] Dark mode as default
  - [x] Calm, muted color palette
  - [x] Clean typography

- [x] Haptics
  - [x] Light impact on check/uncheck
  - [x] Success haptic on routine completion

- [x] Completion state
  - [x] Simple calm "done" screen state
  - [x] No heavy animations

- [x] Accessibility
  - [x] VoiceOver labels on all interactive elements
  - [x] Sufficient color contrast

**Deliverable:** App feels calm and "native."

---

## Phase 9: App Store Readiness - COMPLETE

- [x] Legal & Support
  - [x] Add Privacy Policy link in Settings
  - [x] Add Support Email link in Settings
  - [x] Add Terms of Service link in Settings
  - [x] Add legal links to PaywallView

- [x] Offline support
  - [x] App works completely offline (UserDefaults storage)
  - [x] No network dependency for core features

- [x] Error handling
  - [x] StoreKit purchase failure handling with user-friendly messages
  - [x] Graceful degradation for edge cases
  - [x] Haptic feedback on successful purchase

- [ ] App Store assets (manual steps)
  - [ ] Final app icon
  - [ ] Screenshots for App Store
  - [ ] App description and keywords

- [ ] Testing (manual steps)
  - [ ] TestFlight beta testing
  - [ ] Test on multiple device sizes
  - [ ] Test IAP in sandbox environment

**Deliverable:** Code ready for App Store submission.

---

## Phase 10: Pre-Launch Features - COMPLETE

### "Skip Without Guilt" Button
- [x] Add graceful exit button at bottom of Tonight screen
- [x] "Not tonight — and that's okay" messaging
- [x] Shows calm completion screen without affecting streak
- [x] Different icon (moon.zzz) and messaging for skipped state

### Step-Level Notes
- [x] Add optional `note` field to RoutineStep model
- [x] Support note editing in EditStepSheet
- [x] Show subtle note indicator on steps with notes
- [x] Long-press gesture reveals note inline

### Quiet Mode
- [x] Add toggle in Settings → Experience section
- [x] Dims screen with subtle overlay when enabled
- [x] Disables haptic feedback during routine
- [x] Respects setting across all interactions

### Quote Theme Packs (Premium)
- [x] Add QuoteTheme enum with 5 themes: Calm, Romantic, Stoic, Minimal, Encouraging
- [x] Create QuoteService with themed quote arrays
- [x] Theme picker in Settings (Premium only)
- [x] Completion screen shows themed quotes

### "Tomorrow Starts Now" Preview
- [x] Add reassurance message on completion screen
- [x] Rotates through encouraging messages about tomorrow
- [x] Appears for both completed and skipped states

**Deliverable:** Enhanced user experience with graceful flexibility.

---

## Future Considerations (Post-MVP)

These are explicitly **not** in scope for MVP:

- [ ] iCloud sync
- [ ] Apple Watch companion app
- [ ] Widgets
- [ ] Multiple routines (morning, evening, etc.)
- [ ] Statistics/analytics dashboard
- [ ] Social features

---

## Progress Summary

| Phase | Status | Deliverable |
|-------|--------|-------------|
| 0 | Complete | App launches to Tonight screen |
| 1 | Complete | Data persists across restarts |
| 2 | Complete | Default routine for new users |
| 3 | Complete | Core checklist functionality |
| 4 | Complete | Streak tracking |
| 5 | Complete | Routine customization |
| 6 | Complete | Daily reminders |
| 7 | Complete | Premium purchase |
| 8 | Complete | Polish and accessibility |
| 9 | Complete | App Store ready |
| 10 | Complete | Pre-launch features |
