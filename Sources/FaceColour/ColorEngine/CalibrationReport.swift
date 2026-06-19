import Foundation

/// Compact, copy-pasteable dump of the raw analysis metrics — used by the
/// "Analysis details" panel so real-world results can be reported back and the
/// `SkinThresholds` / `SeasonThresholds` calibrated. See `docs/calibration.md`.
enum CalibrationReport {
    static func text(skin: SkinToneResult, season: Season, closest: ShadeMatch?) -> String {
        var lines = [
            "hex=\(skin.representativeRGB.hexString)",
            String(format: "L=%.1f a=%.1f b=%.1f", skin.lab.L, skin.lab.a, skin.lab.b),
            String(format: "hue=%.1f ITA=%.1f", skin.hueAngle, skin.ita),
            "undertone=\(skin.undertone.rawValue) fitz=\(skin.fitzpatrick.rawValue) season=\(season.rawValue)",
            "samples=\(skin.sampleCount) confidence=\(skin.confidence.rawValue)",
        ]
        if let closest {
            lines.append(String(format: "shade=Monk%d dE=%.1f", closest.tone.tone, closest.deltaE))
        }
        return lines.joined(separator: "\n")
    }
}
