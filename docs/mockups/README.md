# Feature Mockups

> **These are hand-authored SVG mockups, not real screenshots.** They can't be
> captured from a Windows dev box — running the apps needs a Mac/Simulator (iOS)
> or an emulator/device (Android). They use the real palette/shade hex values so
> they're representative, but the **App Store / Play Store require genuine
> screenshots** captured on-device (see "Capturing real screenshots" below).

| File | Feature |
|---|---|
| `home.svg` | Home / empty state — Take Photo / Choose Photo, History |
| `camera.svg` | Live camera capture (CameraX / `UIImagePickerController`) |
| `results.svg` | Analysis results — skin tone + season palette + Monk shade matches |
| `history.svg` | Saved history list |
| `shop.svg` | "Shop your colors" product list (deep-link out) |

Open the `.svg` files in a browser or image viewer.

## Capturing real screenshots

**iOS (Mac):**
1. `cd FaceColour && xcodegen generate && open FaceColour.xcodeproj`
2. Run on a Simulator (⌘R). Library picker works in the Simulator; the camera needs a device.
3. Simulator → **File ▸ Save Screen** (⌘S), or on a device press Side + Volume Up.

**Android (Windows/Mac/Linux):**
1. Open `android/` in Android Studio (or `cd android && ./gradlew installDebug`).
2. Run on an emulator or device.
3. Emulator toolbar camera icon, or `adb exec-out screencap -p > shot.png`.

Recommended shots: empty home, detected face + skin result, season palette,
shade matches, history, shop. See `docs/release-checklist.md` for required store sizes.
