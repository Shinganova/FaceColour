import SwiftUI

extension Color {
    /// Bridges the engine's sRGB `RGBColor` to a SwiftUI `Color`.
    init(_ rgb: RGBColor) {
        self.init(.sRGB, red: rgb.r, green: rgb.g, blue: rgb.b, opacity: 1)
    }

    /// From a `#RRGGBB` hex string; nil if malformed.
    init?(hex: String) {
        guard let rgb = RGBColor(hex: hex) else { return nil }
        self.init(rgb)
    }
}
