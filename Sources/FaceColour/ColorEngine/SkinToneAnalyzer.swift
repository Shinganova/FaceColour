import Foundation

/// Pure analysis: a bag of skin pixel samples -> one representative skin tone
/// with undertone, depth, and confidence. No platform dependencies — this is the
/// heart of the cross-platform color engine (`docs/color-algorithm.md` §2,4,5,6).
struct SkinToneAnalyzer {

    func analyze(samples: [RGBColor]) -> SkinToneResult? {
        // 1. Per-sample plausibility filter (drop highlights/shadows/non-skin).
        let plausible = samples.filter(isPlausibleSkin)
        guard plausible.count >= SkinThresholds.minInliers else { return nil }

        // 2. To Lab.
        let labs = plausible.map(ColorConversions.toLab)

        // 3. Robust center: per-channel median.
        let median = LabColor(L: Self.median(labs.map(\.L)),
                              a: Self.median(labs.map(\.a)),
                              b: Self.median(labs.map(\.b)))

        // 4. Drop outliers far from the median (hair, lips, background bleed).
        let inliers = zip(plausible, labs).filter {
            ColorConversions.deltaE76($0.1, median) <= SkinThresholds.outlierDeltaE
        }
        guard inliers.count >= SkinThresholds.minInliers else { return nil }

        // 5. Representative = mean of inliers, in both Lab and RGB.
        let inLabs = inliers.map { $0.1 }
        let rep = LabColor(L: Self.mean(inLabs.map(\.L)),
                           a: Self.mean(inLabs.map(\.a)),
                           b: Self.mean(inLabs.map(\.b)))
        let repRGB = RGBColor(r: Self.mean(inliers.map { $0.0.r }),
                              g: Self.mean(inliers.map { $0.0.g }),
                              b: Self.mean(inliers.map { $0.0.b }))

        // 6. Metrics + classification.
        let hue = Self.hueAngle(rep)
        let ita = Self.ita(rep)
        let spread = Self.mean(inLabs.map { ColorConversions.deltaE76($0, rep) })

        return SkinToneResult(
            representativeRGB: repRGB,
            lab: rep,
            hueAngle: hue,
            ita: ita,
            undertone: .classify(hueAngle: hue),
            depth: .classify(ita: ita),
            confidence: Self.confidence(count: inliers.count, spread: spread),
            sampleCount: inliers.count
        )
    }

    func isPlausibleSkin(_ c: RGBColor) -> Bool {
        let hsv = ColorConversions.toHSV(c)
        return hsv.v >= SkinThresholds.minValue && hsv.v <= SkinThresholds.maxValue
            && hsv.s >= SkinThresholds.minSaturation && hsv.s <= SkinThresholds.maxSaturation
    }

    // MARK: - Metrics

    /// CIELAB hue angle in degrees, normalized to 0..<360.
    static func hueAngle(_ lab: LabColor) -> Double {
        let deg = atan2(lab.b, lab.a) * 180 / .pi
        return deg < 0 ? deg + 360 : deg
    }

    /// Individual Typology Angle in degrees.
    static func ita(_ lab: LabColor) -> Double {
        atan2(lab.L - 50, lab.b) * 180 / .pi
    }

    static func confidence(count: Int, spread: Double) -> Confidence {
        if count >= SkinThresholds.highMinSamples && spread < SkinThresholds.highMaxSpread {
            return .high
        }
        if count < SkinThresholds.lowMaxSamples || spread > SkinThresholds.lowMinSpread {
            return .low
        }
        return .medium
    }

    // MARK: - Stats helpers

    static func mean(_ xs: [Double]) -> Double {
        xs.isEmpty ? 0 : xs.reduce(0, +) / Double(xs.count)
    }

    static func median(_ xs: [Double]) -> Double {
        guard !xs.isEmpty else { return 0 }
        let s = xs.sorted()
        let m = s.count / 2
        return s.count % 2 == 0 ? (s[m - 1] + s[m]) / 2 : s[m]
    }
}
