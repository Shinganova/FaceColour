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
**A0 — scaffolding.** Buildable empty Compose app + CI. Later phases add capture
(CameraX + ML Kit), the color engine, season/shade, results/history, and the shop.
