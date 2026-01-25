# NightRoutine - MVP Roadmap

This document tracks the implementation phases for the Night Routine Wind-Down app.

**Current Phase:** 1 - Data Model

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

## Phase 1: Data Model (Local-Only)

### Models to Define

- [ ] `RoutineStep` model
  - `id` (UUID)
  - `title` (String)
  - `isEnabled` (Bool)
  - `sortOrder` (Int)

- [ ] `RoutineState` model (current night/session)
  - `completedStepIDs` (Set<UUID>)
  - `sessionDateKey` (String, format: "YYYY-MM-DD")

- [ ] `UserSettings` model
  - `reminderEnabled` (Bool)
  - `reminderTime` (DateComponents)
  - `reminderMessage` (String, optional)
  - `freeTierStepLimit` (Int constant = 6)

### Persistence

- [ ] Implement UserDefaults + Codable storage
- [ ] Define storage keys: `routineSteps`, `settings`, `streakData`
- [ ] Create persistence service with save/load methods

**Deliverable:** Steps and settings persist across app restarts.

---

## Phase 2: Default Routine Seed

- [ ] Create default steps list:
  1. "Skincare"
  2. "Brush teeth"
  3. "Set phone down"
  4. "Stretch"
  5. "Water"
  6. "Lights off"

- [ ] Implement first-launch seeding logic
- [ ] Make seeding idempotent (only if no saved steps exist)

**Deliverable:** New users see a full default routine.

---

## Phase 3: Tonight Screen (Core Flow)

- [ ] Build main "Tonight" checklist screen
  - [ ] Header: "Wind Down" + subtle date display
  - [ ] List of enabled steps in sort order
  - [ ] Large tap targets for each row
  - [ ] Visual "complete" state per step

- [ ] Implement completion logic
  - [ ] Tap toggles step completion for tonight's session
  - [ ] Track completions in RoutineState
  - [ ] Reset completions at midnight or new session

- [ ] Add completion celebration
  - [ ] Show calm "Done for tonight" state when all steps complete

**Deliverable:** One-screen, no-friction routine completion.

---

## Phase 4: Streak (Minimal + Non-Shaming)

- [ ] Define completion criteria
  - [ ] "Completed night" = all enabled steps checked

- [ ] Implement streak storage
  - [ ] Save completion per day (date key: "YYYY-MM-DD")
  - [ ] Store as Set<String> of completed dates

- [ ] Compute streak
  - [ ] Count consecutive days with completion
  - [ ] Handle timezone correctly

- [ ] Display streak
  - [ ] Show single number on Tonight screen (small, subtle)
  - [ ] No "broken streak" messaging
  - [ ] No shame, just information

**Deliverable:** Streak number updates correctly.

---

## Phase 5: Edit Routine (Basic Customization)

- [ ] Create "Edit Routine" screen
  - [ ] Navigate from Tonight screen (gear icon or edit button)

- [ ] Implement editing features
  - [ ] Reorder steps (drag to reorder)
  - [ ] Toggle steps enabled/disabled
  - [ ] Edit step title (inline or modal)
  - [ ] Add new step
  - [ ] Delete step (swipe to delete)

- [ ] Enforce free-tier limit
  - [ ] Check step count before adding
  - [ ] If user is free and tries to add > 6 steps, show paywall

**Deliverable:** User can fully customize routine (within tier limits).

---

## Phase 6: Nightly Reminder Notifications

- [ ] Request notification permission
  - [ ] Friendly one-time prompt with explanation
  - [ ] Handle denial gracefully

- [ ] Create Settings screen
  - [ ] Toggle reminder on/off
  - [ ] Time picker for reminder time
  - [ ] Custom reminder message field (premium only)

- [ ] Implement notification scheduling
  - [ ] Schedule repeating daily local notification
  - [ ] Update schedule when time changes
  - [ ] Cancel notifications when disabled

**Deliverable:** Reminders fire daily at the chosen time.

---

## Phase 7: Paywall + Entitlements

### Monetization: One-time "Lifetime Premium" unlock

- [ ] Configure StoreKit 2
  - [ ] Create non-consumable product: `premium_lifetime`
  - [ ] Set up App Store Connect product

- [ ] Define premium features
  - [ ] Unlimited steps (free tier = 6)
  - [ ] Custom reminder message
  - [ ] (Optional) Extra themes

- [ ] Build paywall screen
  - [ ] Clear value proposition bullets
  - [ ] Price button with localized price
  - [ ] Restore purchases button
  - [ ] Terms/Privacy links

- [ ] Implement purchase flow
  - [ ] Handle purchase success
  - [ ] Handle purchase failure/cancellation
  - [ ] Cache entitlement state locally
  - [ ] Validate with StoreKit on launch

- [ ] Add restore purchases flow

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
| 1 | Not Started | Data persists across restarts |
| 2 | Not Started | Default routine for new users |
| 3 | Not Started | Core checklist functionality |
| 4 | Not Started | Streak tracking |
| 5 | Not Started | Routine customization |
| 6 | Not Started | Daily reminders |
| 7 | Not Started | Premium purchase |
| 8 | Not Started | Polish and accessibility |
| 9 | Not Started | App Store ready |
