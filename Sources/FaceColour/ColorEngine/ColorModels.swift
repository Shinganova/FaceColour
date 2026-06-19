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

    /// From a `#RRGGBB` (or `RRGGBB`) hex string. Returns nil if malformed.
    init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = Int(s, radix: 16) else { return nil }
        self.init(r8: UInt8((v >> 16) & 0xFF),
                  g8: UInt8((v >> 8) & 0xFF),
                  b8: UInt8(v & 0xFF))
    }

    /// `#RRGGBB` (uppercase) representation, clamped to 0...255.
    var hexString: String {
        func channel(_ value: Double) -> Int { max(0, min(255, Int((value * 255).rounded()))) }
        return String(format: "#%02X%02X%02X", channel(r), channel(g), channel(b))
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
