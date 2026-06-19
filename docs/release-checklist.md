# Release Checklist / Runbook (Mac-side)

Everything needed to take FaceColour from this repo to the App Store. Items marked
**[done]** are already handled in the repo; the rest require a Mac, Xcode, and an
Apple Developer Program membership.

## 0. Prerequisites
- [ ] Mac with Xcode (latest stable).
- [ ] Apple Developer Program membership (~$99/yr).
- [ ] `brew install xcodegen` (project is generated, not committed).

## 1. Generate & open
```sh
cd FaceColour
xcodegen generate
open FaceColour.xcodeproj
```

## 2. Signing & identity
- [ ] In Xcode → target **FaceColour** → Signing & Capabilities: select your Team
      (or set `DEVELOPMENT_TEAM` in `project.yml`).
- [ ] Confirm bundle id `com.faceColour.app` (change if taken; update `project.yml`).
- [ ] Set `MARKETING_VERSION` (e.g. `1.0`) and `CURRENT_PROJECT_VERSION` (e.g. `1`)
      in `project.yml`.

## 3. App icon
- [ ] Add a 1024×1024 PNG (no alpha) to
      `Sources/FaceColour/Resources/Assets.xcassets/AppIcon.appiconset/` and reference
      it in that set's `Contents.json`. (Currently a placeholder — build warns until added.)

## 4. Privacy & compliance — **[done in repo]**
- [done] Camera usage string (`NSCameraUsageDescription`) in `Info.plist`.
- [done] Privacy manifest `PrivacyInfo.xcprivacy` (no tracking, no data collected).
- [done] `ITSAppUsesNonExemptEncryption = false` in `Info.plist`.
- [ ] Host `PRIVACY.md` somewhere public and note the URL for App Store Connect.

## 5. Run & verify on real input  ← do this before investing in store assets
- [ ] Run on an iOS 17+ **simulator** (photo library works there).
- [ ] Run on a **physical device** to test the camera and try several real faces in
      different lighting.
- [ ] Sanity-check undertone/season/shade results; **calibrate `SkinThresholds` /
      `SeasonThresholds`** if they feel off (see `docs/color-algorithm.md`).
- [ ] Run tests: `⌘U` (or `xcodebuild test`, as CI does).

## 6. Screenshots
- [ ] Capture required sizes (6.7" and 6.5" iPhone at minimum; 5.5" if supporting older).
      Use the simulator (Device → Save Screen) or a real device.
- [ ] Suggested shots: empty home, detected face + skin result, season palette,
      shade matches, shop list.

## 7. App Store Connect
- [ ] Create the app record (name **FaceColour**, bundle id, primary language).
- [ ] Fill metadata from `docs/appstore.md` (subtitle, promo text, description,
      keywords, support/marketing/privacy URLs, category, age rating).
- [ ] Complete **App Privacy** = "Data not collected" (revisit if you enable a remote
      product provider — disclose the season/shade query then).

## 8. Archive & upload
- [ ] Xcode → set the run destination to **Any iOS Device (arm64)**.
- [ ] Product → **Archive** → Organizer → **Validate App** → **Distribute App** →
      App Store Connect → Upload.

## 9. TestFlight (recommended)
- [ ] Add the build to TestFlight, test on your own device(s) first, then invite testers.

## 10. Submit for review
- [ ] Attach the build, screenshots, and "What's New".
- [ ] Submit. Typical review is 1–3 days; respond to any reviewer questions.

## Optional — enable real shop data later
- [ ] Choose an affiliate/product provider; implement its request/response adapter
      behind the `ProductService` protocol.
- [ ] Add `PRODUCT_API_BASE_URL` + `PRODUCT_API_KEY` to `Info.plist` (or an xcconfig).
- [ ] Update the App Privacy disclosure and `PRIVACY.md` for the data sent.
