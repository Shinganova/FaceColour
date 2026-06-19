import Foundation

/// An sRGB color, components in 0...1.
struct RGBColor: Equatable {
    var r: Double
    var g: Double
    var b: Double

    init(r: Double, g: Double, b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    /// From 8-bit channels (0...255).
    init(r8: UInt8, g8: UInt8, b8: UInt8) {
        self.init(r: Double(r8) / 255, g: Double(g8) / 255, b: Double(b8) / 255)
    }
}

/// A CIELAB color (D65 white point).
struct LabColor: Equatable {
    var L: Double
    var a: Double
    var b: Double
}

/// An HSV color: h in 0..<360 degrees, s and v in 0...1.
struct HSVColor: Equatable {
    var h: Double
    var s: Double
    var v: Double
}
