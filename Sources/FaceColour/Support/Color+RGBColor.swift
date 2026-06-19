import SwiftUI

extension Color {
    /// Bridges the engine's sRGB `RGBColor` to a SwiftUI `Color`.
    init(_ rgb: RGBColor) {
        self.init(.sRGB, red: rgb.r, green: rgb.g, blue: rgb.b, opacity: 1)
    }
}
