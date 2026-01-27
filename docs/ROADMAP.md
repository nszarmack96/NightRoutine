# NightRoutine - MVP Roadmap

This document tracks the implementation phases for the Night Routine Wind-Down app.

**Current Phase:** 8 - Polished UX (MVP-Polish)

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

## Phase 8: Polished UX (MVP-Polish)

- [ ] Visual polish
  - [ ] Dark mode as default
  - [ ] Calm, muted color palette
  - [ ] Clean typography

- [ ] Haptics
  - [ ] Light impact on check/uncheck
  - [ ] Success haptic on routine completion

- [ ] Completion state
  - [ ] Simple calm "done" screen state
  - [ ] No heavy animations

- [ ] Accessibility
  - [ ] Dynamic Type support
  - [ ] VoiceOver labels on all interactive elements
  - [ ] Sufficient color contrast

**Deliverable:** App feels calm and "native."

---

## Phase 9: App Store Readiness

- [ ] Legal & Support
  - [ ] Add Privacy Policy link in Settings
  - [ ] Add Support Email link in Settings
  - [ ] Terms of Service (if needed)

- [ ] Offline support
  - [ ] Verify app works completely offline
  - [ ] No network dependency for core features

- [ ] Error handling
  - [ ] StoreKit purchase failure handling
  - [ ] Graceful degradation for edge cases

- [ ] App Store assets
  - [ ] Final app icon
  - [ ] Screenshots for App Store
  - [ ] App description and keywords

- [ ] Testing
  - [ ] TestFlight beta testing
  - [ ] Test on multiple device sizes
  - [ ] Test IAP in sandbox environment

**Deliverable:** Ready for App Store submission.

---

## Future Considerations (Post-MVP)

These are explicitly **not** in scope for MVP:

- [ ] iCloud sync
- [ ] Apple Watch companion app
- [ ] Widgets
- [ ] Multiple routines (morning, evening, etc.)
- [ ] Statistics/analytics dashboard
- [ ] Social features
- [ ] Themes beyond dark mode

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
| 8 | Not Started | Polish and accessibility |
| 9 | Not Started | App Store ready |
