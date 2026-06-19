import Foundation

/// Skin undertone classification.
enum Undertone: String, Codable, Equatable {
    case warm, neutral, cool

    /// Classify from the CIELAB hue angle (degrees, `atan2(b*, a*)`).
    /// Higher angle = more yellow/golden (warm); lower = more red/pink (cool).
    static func classify(hueAngle h: Double) -> Undertone {
        switch h {
        case ..<SkinThresholds.coolMaxHue: return .cool
        case SkinThresholds.warmMinHue...: return .warm
        default: return .neutral
        }
    }

    var displayName: String { rawValue.capitalized }
}

/// Skin depth expressed as a **Fitzpatrick phototype (Types I–VI)**.
///
/// True Fitzpatrick typing is a sun-reaction questionnaire; from a single photo we
/// can only *estimate* the phototype from skin lightness. We do this via the
/// Individual Typology Angle (ITA), using the established ITA→Fitzpatrick
/// correspondence (Del Bino et al.). This is an approximation, not a clinical
/// classification. ITA bin boundaries are unchanged from the prior depth scale.
enum Fitzpatrick: String, Codable, Equatable, CaseIterable {
    case typeI = "I"
    case typeII = "II"
    case typeIII = "III"
    case typeIV = "IV"
    case typeV = "V"
    case typeVI = "VI"

    /// Estimate the Fitzpatrick phototype from ITA (degrees): `atan2(L* - 50, b*)`.
    static func classify(ita: Double) -> Fitzpatrick {
        switch ita {
        case 55...: return .typeI
        case 41 ..< 55: return .typeII
        case 28 ..< 41: return .typeIII
        case 10 ..< 28: return .typeIV
        case -30 ..< 10: return .typeV
        default: return .typeVI
        }
    }

    /// e.g. "Type III".
    var displayName: String { "Type \(rawValue)" }

    /// Short human-readable depth label for the phototype.
    var depthDescription: String {
        switch self {
        case .typeI: "Very light"
        case .typeII: "Light"
        case .typeIII: "Intermediate"
        case .typeIV: "Tan"
        case .typeV: "Brown"
        case .typeVI: "Deep"
        }
    }
}

/// How much to trust a result, from sample count and spread.
enum Confidence: String, Codable, Equatable {
    case high, medium, low
    var displayName: String { rawValue.capitalized }
}

/// Tunable constants for the skin pipeline. Centralized so the spec, the iOS
/// code, and the future Android code share one source of truth.
enum SkinThresholds {
    // Undertone hue-angle bands (degrees).
    static let coolMaxHue = 45.0
    static let warmMinHue = 57.0

    // Per-sample plausibility (HSV) — drop specular highlights, shadows, non-skin.
    static let minValue = 0.15
    static let maxValue = 0.95
    static let minSaturation = 0.05
    static let maxSaturation = 0.75

    // Outlier rejection: drop samples this far (CIE76) from the median.
    static let outlierDeltaE = 12.0

    // Minimum inliers to report anything at all.
    static let minInliers = 5

    // Confidence bands.
    static let highMinSamples = 100
    static let lowMaxSamples = 30
    static let highMaxSpread = 6.0
    static let lowMinSpread = 14.0
}

/// Result of analyzing skin samples.
struct SkinToneResult: Equatable {
    let representativeRGB: RGBColor
    let lab: LabColor
    let hueAngle: Double
    let ita: Double
    let undertone: Undertone
    let fitzpatrick: Fitzpatrick
    let confidence: Confidence
    let sampleCount: Int
}
