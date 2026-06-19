import Foundation

/// 4-season color type (MVP). Designed to extend to a 12-season model later.
enum Season: String, Codable, Equatable, CaseIterable {
    case spring, summer, autumn, winter

    var displayName: String { rawValue.capitalized }

    /// Classify from undertone + depth (Phase 3 MVP — contrast not yet used).
    ///
    /// - Warm + light → Spring, Warm + deep → Autumn
    /// - Cool + light → Summer, Cool + deep → Winter
    /// - Neutral leans warm/cool by the Lab hue angle.
    static func classify(undertone: Undertone, depth: Fitzpatrick, hueAngle: Double) -> Season {
        let warmLeaning: Bool
        switch undertone {
        case .warm: warmLeaning = true
        case .cool: warmLeaning = false
        case .neutral: warmLeaning = hueAngle >= SeasonThresholds.neutralWarmHue
        }

        let deep = SeasonThresholds.deepDepths.contains(depth)
        switch (warmLeaning, deep) {
        case (true, false): return .spring
        case (true, true): return .autumn
        case (false, false): return .summer
        case (false, true): return .winter
        }
    }
}

enum SeasonThresholds {
    /// Neutral undertones with a hue angle at/above this lean warm.
    static let neutralWarmHue = 51.0
    /// Fitzpatrick phototypes considered "deep" for the season split (IV–VI).
    static let deepDepths: Set<Fitzpatrick> = [.typeIV, .typeV, .typeVI]
}
