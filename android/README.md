# FaceColour — Android

Kotlin + Jetpack Compose port of the iOS app. Re-implements the shared color engine
from [`../docs/color-algorithm.md`](../docs/color-algorithm.md) and reuses the season /
shade data; the unit tests mirror the iOS vectors as the cross-platform contract.

## Build

Requires JDK 17 + the Android SDK (Android Studio bundles both).

```sh
cd android
# First time (Android Studio does this on open, or run manually):
gradle wrapper --gradle-version 8.7
./gradlew :app:assembleDebug :app:testDebugUnitTest
```

The Gradle wrapper jar is intentionally not committed; generate it once as above, or
just open `android/` in Android Studio. CI installs Gradle directly.

## Status
- **A0** — scaffolding + CI.
- **A2** — Kotlin color engine + parity tests (`engine/`).
- **A3** — capture & analysis: pick a photo → ML Kit face detection → skin sampling
  → engine → Compose results (skin tone, season palette, Monk shades). Shared
  `seasons.json` / `shades.json` are wired in as Android assets from the iOS
  Resources (single source of truth).

Next: CameraX live capture, history, and the shop.
