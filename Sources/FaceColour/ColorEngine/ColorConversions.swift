import Foundation

/// Pure color-space conversions. Mirrors `docs/color-algorithm.md` §3 exactly so
/// the future Android port produces identical numbers.
enum ColorConversions {

    // MARK: sRGB companding

    /// sRGB gamma-encoded component (0...1) -> linear-light component.
    static func linearize(_ c: Double) -> Double {
        c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
    }

    // MARK: sRGB -> CIELAB (D65)

    static func toLab(_ rgb: RGBColor) -> LabColor {
        let r = linearize(rgb.r)
        let g = linearize(rgb.g)
        let b = linearize(rgb.b)

        // Linear sRGB -> XYZ (D65).
        let x = 0.4124 * r + 0.3576 * g + 0.1805 * b
        let y = 0.2126 * r + 0.7152 * g + 0.0722 * b
        let z = 0.0193 * r + 0.1192 * g + 0.9505 * b

        // D65 reference white.
        let xn = 0.95047, yn = 1.0, zn = 1.08883

        let fx = labF(x / xn)
        let fy = labF(y / yn)
        let fz = labF(z / zn)

        return LabColor(L: 116 * fy - 16,
                        a: 500 * (fx - fy),
                        b: 200 * (fy - fz))
    }

    private static func labF(_ t: Double) -> Double {
        let d: Double = 6.0 / 29.0
        return t > pow(d, 3) ? cbrt(t) : (t / (3 * d * d) + 4.0 / 29.0)
    }

    // MARK: sRGB -> HSV

    static func toHSV(_ c: RGBColor) -> HSVColor {
        let maxV = max(c.r, c.g, c.b)
        let minV = min(c.r, c.g, c.b)
        let delta = maxV - minV

        var h = 0.0
        if delta > 0 {
            if maxV == c.r {
                h = 60 * (((c.g - c.b) / delta).truncatingRemainder(dividingBy: 6))
            } else if maxV == c.g {
                h = 60 * ((c.b - c.r) / delta + 2)
            } else {
                h = 60 * ((c.r - c.g) / delta + 4)
            }
        }
        if h < 0 { h += 360 }

        let s = maxV == 0 ? 0 : delta / maxV
        return HSVColor(h: h, s: s, v: maxV)
    }

    // MARK: Distance

    /// CIE76 color difference (Euclidean in Lab). Adequate for outlier rejection;
    /// shade matching (Phase 4) will use CIEDE2000.
    static func deltaE76(_ x: LabColor, _ y: LabColor) -> Double {
        let dL = x.L - y.L, da = x.a - y.a, db = x.b - y.b
        return (dL * dL + da * da + db * db).squareRoot()
    }
}
