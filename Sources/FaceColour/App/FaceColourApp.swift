import SwiftUI

/// App entry point.
///
/// FaceColour analyzes a selfie to (1) determine the user's seasonal color type
/// with recommended palettes, and (2) match skin tone to product shades.
/// See `PLAN.md` and `docs/color-algorithm.md`.
@main
struct FaceColourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
