import SwiftUI

/// The unified results section: skin tone + season palette + shade matches.
/// Reused by the live capture flow and by history detail.
struct ResultsView: View {
    let representativeRGB: RGBColor
    let undertone: Undertone
    let fitzpatrick: Fitzpatrick
    let confidence: Confidence
    let season: Season
    let guide: SeasonGuide?
    let shadeMatches: [ShadeMatch]

    var body: some View {
        VStack(spacing: 20) {
            SkinToneResultCard(representativeRGB: representativeRGB,
                               undertone: undertone,
                               fitzpatrick: fitzpatrick,
                               confidence: confidence)
            if let guide {
                SeasonResultView(season: season, guide: guide)
            }
            if !shadeMatches.isEmpty {
                ShadeMatchView(matches: shadeMatches)
            }
        }
    }
}
