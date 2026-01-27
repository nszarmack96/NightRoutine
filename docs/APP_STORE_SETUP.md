# App Store Connect Setup Guide

This guide walks you through setting up Night Routine for App Store submission.

---

## Prerequisites

- [ ] Apple Developer Program membership ($99/year)
- [ ] Xcode installed with valid signing certificate
- [ ] App icon (1024x1024 PNG)
- [ ] Screenshots for required device sizes

---

## Step 1: Create App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** → **+** → **New App**
3. Fill in:
   - **Platform:** iOS
   - **Name:** Night Routine
   - **Primary Language:** English (U.S.)
   - **Bundle ID:** io.nightroutine.app (must match Xcode)
   - **SKU:** nightroutine-ios-001 (any unique identifier)
   - **User Access:** Full Access

---

## Step 2: Create In-App Purchase Product

1. In your app, go to **Features** → **In-App Purchases**
2. Click **+** → **Non-Consumable**
3. Fill in:
   - **Reference Name:** Lifetime Premium
   - **Product ID:** io.nightroutine.premium.lifetime
   - **Price:** $4.99 (Price Tier 5)

4. Add Localization (English):
   - **Display Name:** Lifetime Premium
   - **Description:** Unlock unlimited steps, custom reminder messages, and quote theme packs forever.

5. **Review Information:**
   - Screenshot of the paywall (take from simulator)
   - Review notes: "One-time purchase unlocking premium features. No subscription."

6. Click **Save** → **Submit for Review** (with your app)

---

## Step 3: App Store Listing

### App Information Tab
- **Name:** Night Routine
- **Subtitle:** Wind Down, Sleep Better
- **Category:** Health & Fitness
- **Secondary Category:** Lifestyle
- **Content Rights:** Does not contain third-party content

### Pricing and Availability
- **Price:** Free (with IAP)
- **Availability:** All countries (or select specific)

### App Privacy
1. Go to **App Privacy** section
2. Select **Data Types:** None collected
3. Night Routine does NOT collect:
   - No analytics
   - No tracking
   - No personal data
   - All data stored locally

---

## Step 4: Version Information

### Required Fields
- **Version:** 1.1.0
- **Copyright:** © 2026 Night Routine
- **Support URL:** https://nszarmack96.github.io/NightRoutine/
- **Privacy Policy URL:** https://nszarmack96.github.io/NightRoutine/privacy.html

### Description
Copy from [APP_STORE_METADATA.md](./APP_STORE_METADATA.md)

### Keywords
```
sleep,routine,bedtime,habit,tracker,checklist,wind down,evening,night,wellness,self care,healthy,relax,mindful,calm
```

### What's New
```
New features for a better wind-down experience:

• "Skip Without Guilt" — End your routine early without shame
• Step Notes — Add personal notes to any routine step
• Quiet Mode — Dims screen and disables haptics
• Quote Themes — Choose from 5 quote styles (Premium)
• Tomorrow Preview — Encouraging messages after completion
```

---

## Step 5: Screenshots

### Required Sizes

| Device | Size | Required |
|--------|------|----------|
| iPhone 6.9" (16 Pro Max) | 1320 x 2868 | Yes |
| iPhone 6.7" (15 Pro Max) | 1290 x 2796 | Yes |
| iPhone 6.5" (11 Pro Max) | 1284 x 2778 | Optional (uses 6.7") |
| iPhone 5.5" (8 Plus) | 1242 x 2208 | Yes (for older devices) |
| iPad Pro 12.9" | 2048 x 2732 | If supporting iPad |

### How to Take Screenshots

1. Open Simulator with target device
2. Run the app: `Cmd + R`
3. Navigate to desired screen
4. Take screenshot: `Cmd + S` (saves to Desktop)

### Recommended Screenshots (5-10 per device)

1. **Main Tonight screen** - Show the checklist with some items checked
2. **Completion screen** - "Done for tonight" with moon and quote
3. **Edit Routine screen** - Show customization options
4. **Settings screen** - Show reminder settings
5. **Paywall** - Show premium features (optional)

### Screenshot Tips
- Use consistent device frame style
- Add text overlays explaining features
- Use dark backgrounds (matches app theme)
- Tools: [Rotato](https://rotato.app), [Screenshots Pro](https://screenshots.pro), or Figma

---

## Step 6: Build & Upload

### Archive the App

1. In Xcode, select **Any iOS Device** as build target
2. **Product** → **Archive**
3. Wait for archive to complete
4. **Distribute App** → **App Store Connect** → **Upload**

### Before Uploading, Verify:
- [ ] Version number matches App Store Connect (1.1.0)
- [ ] Bundle ID matches (io.nightroutine.app)
- [ ] App icon included
- [ ] No debug code or test data
- [ ] StoreKit pointing to production (not test config)

---

## Step 7: Submit for Review

1. In App Store Connect, select your build
2. Fill in **App Review Information:**
   - Contact info
   - Demo account: Not required
   - Notes: See APP_STORE_METADATA.md

3. Answer questionnaire:
   - **Export Compliance:** No (no encryption beyond iOS standard)
   - **Advertising ID:** No (we don't track)
   - **Content Rights:** Yes, we own all content

4. Click **Submit for Review**

---

## Step 8: Testing (Before Submit)

### Sandbox IAP Testing

1. Create a sandbox test account:
   - App Store Connect → Users and Access → Sandbox → Testers
   - Add a test email (can be fake)

2. On test device:
   - Settings → App Store → Sign out
   - Launch app, try to purchase
   - Sign in with sandbox account when prompted
   - Purchase should work (no real charge)

3. Test scenarios:
   - [ ] Purchase completes successfully
   - [ ] Premium features unlock
   - [ ] Restore purchases works
   - [ ] Purchase persists after app restart

### TestFlight (Optional but Recommended)

1. Upload build to App Store Connect
2. Go to TestFlight tab
3. Add internal testers (your Apple ID)
4. Install via TestFlight app on device
5. Test all features thoroughly

---

## Common Rejection Reasons & How to Avoid

| Reason | Solution |
|--------|----------|
| Broken links | Verify privacy/terms URLs work |
| IAP not working | Test in sandbox before submit |
| Misleading screenshots | Show actual app UI |
| Missing privacy policy | We have this covered |
| Crashes | Test on multiple devices |
| Guideline 4.2 (minimum functionality) | App has sufficient features |

---

## Timeline Expectations

- **Review time:** 24-48 hours typically
- **First submission:** May take longer (up to 1 week)
- **Rejections:** Common on first try, usually quick fixes
- **After approval:** Can release immediately or schedule

---

## Post-Launch Checklist

- [ ] Monitor App Store Connect for reviews
- [ ] Respond to any crash reports
- [ ] Set up TestFlight for future beta testing
- [ ] Consider App Store Optimization (ASO) improvements
- [ ] Plan next version features

---

## Quick Reference

| Item | Value |
|------|-------|
| Bundle ID | io.nightroutine.app |
| Product ID | io.nightroutine.premium.lifetime |
| Price | Free (with $4.99 IAP) |
| Category | Health & Fitness |
| iOS Version | 16.0+ |
| Privacy Policy | https://nszarmack96.github.io/NightRoutine/privacy.html |
| Terms | https://nszarmack96.github.io/NightRoutine/terms.html |
| Support | https://nszarmack96.github.io/NightRoutine/ |
