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

    /// CIE76 color difference (Euclidean in Lab). Adequate for outlier rejection.
    static func deltaE76(_ x: LabColor, _ y: LabColor) -> Double {
        let dL = x.L - y.L, da = x.a - y.a, db = x.b - y.b
        return (dL * dL + da * da + db * db).squareRoot()
    }

    /// CIEDE2000 color difference (kL=kC=kH=1). Perceptually accurate — used for
    /// shade matching. Follows Sharma, Wu & Dalal (2005); validated against their
    /// reference pairs in tests.
    static func deltaE2000(_ x: LabColor, _ y: LabColor) -> Double {
        let kL = 1.0, kC = 1.0, kH = 1.0
        let deg = Double.pi / 180

        let c1 = (x.a * x.a + x.b * x.b).squareRoot()
        let c2 = (y.a * y.a + y.b * y.b).squareRoot()
        let cBar = (c1 + c2) / 2
        let cBar7 = pow(cBar, 7)
        let g = 0.5 * (1 - (cBar7 / (cBar7 + pow(25.0, 7))).squareRoot())

        let a1p = (1 + g) * x.a
        let a2p = (1 + g) * y.a
        let c1p = (a1p * a1p + x.b * x.b).squareRoot()
        let c2p = (a2p * a2p + y.b * y.b).squareRoot()

        func hue(_ b: Double, _ ap: Double) -> Double {
            if ap == 0 && b == 0 { return 0 }
            var h = atan2(b, ap) / deg
            if h < 0 { h += 360 }
            return h
        }
        let h1p = hue(x.b, a1p)
        let h2p = hue(y.b, a2p)

        let dLp = y.L - x.L
        let dCp = c2p - c1p

        var dhp = 0.0
        if c1p * c2p != 0 {
            let diff = h2p - h1p
            if abs(diff) <= 180 { dhp = diff }
            else if diff > 180 { dhp = diff - 360 }
            else { dhp = diff + 360 }
        }
        let dHp = 2 * (c1p * c2p).squareRoot() * sin((dhp / 2) * deg)

        let lBarp = (x.L + y.L) / 2
        let cBarp = (c1p + c2p) / 2

        var hBarp = h1p + h2p
        if c1p * c2p != 0 {
            if abs(h1p - h2p) <= 180 {
                hBarp = (h1p + h2p) / 2
            } else if (h1p + h2p) < 360 {
                hBarp = (h1p + h2p + 360) / 2
            } else {
                hBarp = (h1p + h2p - 360) / 2
            }
        }

        let t = 1
            - 0.17 * cos((hBarp - 30) * deg)
            + 0.24 * cos((2 * hBarp) * deg)
            + 0.32 * cos((3 * hBarp + 6) * deg)
            - 0.20 * cos((4 * hBarp - 63) * deg)

        let dTheta = 30 * exp(-pow((hBarp - 275) / 25, 2))
        let cBarp7 = pow(cBarp, 7)
        let rc = 2 * (cBarp7 / (cBarp7 + pow(25.0, 7))).squareRoot()
        let sl = 1 + (0.015 * pow(lBarp - 50, 2)) / (20 + pow(lBarp - 50, 2)).squareRoot()
        let sc = 1 + 0.045 * cBarp
        let sh = 1 + 0.015 * cBarp * t
        let rt = -sin(2 * dTheta * deg) * rc

        let termL = dLp / (kL * sl)
        let termC = dCp / (kC * sc)
        let termH = dHp / (kH * sh)
        return (termL * termL + termC * termC + termH * termH + rt * termC * termH).squareRoot()
    }
}
