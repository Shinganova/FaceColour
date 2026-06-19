import Foundation

/// A persisted shade match (stores hex so the detail view can re-render without
/// re-running the matcher).
struct ShadeMatchRecord: Codable, Equatable {
    let tone: Int
    let hex: String
    let deltaE: Double
}

/// A saved analysis — enough to render the results screen and a history row.
struct AnalysisRecord: Codable, Equatable, Identifiable {
    let id: UUID
    let date: Date
    let representativeHex: String
    let undertone: Undertone
    let fitzpatrick: Fitzpatrick
    let confidence: Confidence
    let season: Season
    let shadeMatches: [ShadeMatchRecord]
    var thumbnailFileName: String?
}

/// Pure share/summary text builder.
enum AnalysisSummary {
    static func text(season: Season,
                     undertone: Undertone,
                     fitzpatrick: Fitzpatrick,
                     closestTone: Int?) -> String {
        var lines = [
            "FaceColour analysis",
            "Season: \(season.displayName)",
            "Undertone: \(undertone.displayName)",
            "Skin type: \(fitzpatrick.displayName) (\(fitzpatrick.depthDescription))",
        ]
        if let closestTone {
            lines.append("Closest shade: Monk tone \(closestTone)")
        }
        return lines.joined(separator: "\n")
    }

    static func text(for record: AnalysisRecord) -> String {
        text(season: record.season,
             undertone: record.undertone,
             fitzpatrick: record.fitzpatrick,
             closestTone: record.shadeMatches.first?.tone)
    }
}
