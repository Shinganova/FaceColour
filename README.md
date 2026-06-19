# FaceColour

A mobile app that analyzes a selfie to:
1. **Color season analysis** — determine your seasonal color type and recommend flattering clothing / makeup / hair colors.
2. **Skin-tone shade matching** — detect your skin tone and match it to product shades.

**Platform:** iOS first (native, Swift + SwiftUI), Android later. See [`PLAN.md`](PLAN.md).

## Project layout

```
project.yml                  # XcodeGen project definition (source of truth, not the .xcodeproj)
docs/color-algorithm.md      # Platform-agnostic color-science spec (shared by iOS & future Android)
Sources/FaceColour/          # App source
  App/                       #   entry point + root view
  Resources/                 #   asset catalog, bundled JSON (added in later phases)
Tests/FaceColourTests/       # Unit tests
```

## Build (requires macOS + Xcode)

This repo intentionally does **not** commit a `.xcodeproj`. Generate it with
[XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
brew install xcodegen
xcodegen generate
open FaceColour.xcodeproj
```

Then build/run the `FaceColour` scheme on an iOS 17+ simulator.

## Status

**Phase 0 — project setup.** Buildable SwiftUI skeleton. See `PLAN.md` for the phased roadmap.
