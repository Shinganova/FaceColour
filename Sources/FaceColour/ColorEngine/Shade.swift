import Foundation

/// One reference tone on the Monk Skin Tone scale (1 = lightest … 10 = deepest).
struct MonkTone: Codable, Equatable {
    let tone: Int
    let hex: String
}

/// The reference shade set (decoded from `shades.json`).
struct ShadeReference: Codable, Equatable {
    let tones: [MonkTone]
}

/// A reference tone scored against a skin color.
struct ShadeMatch: Equatable {
    let tone: MonkTone
    let deltaE: Double
}

/// Matches a skin color to reference tones by CIEDE2000 distance. Pure — part of
/// the cross-platform engine (`docs/color-algorithm.md` §8).
struct ShadeMatcher {
    func match(_ skin: LabColor, against tones: [MonkTone], topN: Int = 3) -> [ShadeMatch] {
        let scored = tones.compactMap { tone -> ShadeMatch? in
            guard let rgb = RGBColor(hex: tone.hex) else { return nil }
            let lab = ColorConversions.toLab(rgb)
            return ShadeMatch(tone: tone, deltaE: ColorConversions.deltaE2000(skin, lab))
        }
        return Array(scored.sorted { $0.deltaE < $1.deltaE }.prefix(topN))
    }
}
