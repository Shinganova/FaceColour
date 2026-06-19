import Foundation

/// Skin undertone classification.
enum Undertone: String, Equatable {
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

/// Skin depth (lightness), binned by the Individual Typology Angle (ITA),
/// a dermatology-standard measure. Maps cleanly onto the Monk scale in Phase 4.
enum Depth: String, Equatable {
    case veryLight, light, intermediate, tan, brown, dark

    /// Classify from ITA (degrees): `atan2(L* - 50, b*)`.
    static func classify(ita: Double) -> Depth {
        switch ita {
        case 55...: return .veryLight
        case 41 ..< 55: return .light
        case 28 ..< 41: return .intermediate
        case 10 ..< 28: return .tan
        case -30 ..< 10: return .brown
        default: return .dark
        }
    }

    var displayName: String {
        switch self {
        case .veryLight: "Very light"
        case .light: "Light"
        case .intermediate: "Intermediate"
        case .tan: "Tan"
        case .brown: "Brown"
        case .dark: "Dark"
        }
    }
}

/// How much to trust a result, from sample count and spread.
enum Confidence: String, Equatable {
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
    let depth: Depth
    let confidence: Confidence
    let sampleCount: Int
}
