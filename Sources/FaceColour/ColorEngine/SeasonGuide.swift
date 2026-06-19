import Foundation

/// A named palette color, e.g. `{ "name": "Coral", "hex": "#FF7F50" }`.
struct PaletteColor: Codable, Equatable {
    let name: String
    let hex: String
}

/// Recommendations for one season.
struct SeasonGuide: Codable, Equatable {
    let title: String
    let summary: String
    let palette: [PaletteColor]
    let avoid: [PaletteColor]
}

/// The full set of season guides (decoded from `seasons.json`).
struct SeasonGuideBook: Codable, Equatable {
    let spring: SeasonGuide
    let summer: SeasonGuide
    let autumn: SeasonGuide
    let winter: SeasonGuide

    subscript(_ season: Season) -> SeasonGuide {
        switch season {
        case .spring: spring
        case .summer: summer
        case .autumn: autumn
        case .winter: winter
        }
    }
}
