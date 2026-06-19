import SwiftUI

/// Read-only detail for a saved analysis. Rebuilds the results UI from the record.
struct HistoryDetailView: View {
    let store: HistoryStore
    let record: AnalysisRecord

    private var shadeMatches: [ShadeMatch] {
        record.shadeMatches.map {
            ShadeMatch(tone: MonkTone(tone: $0.tone, hex: $0.hex), deltaE: $0.deltaE)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let thumb = store.thumbnail(for: record) {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                ResultsView(
                    representativeRGB: RGBColor(hex: record.representativeHex) ?? RGBColor(r: 0.8, g: 0.6, b: 0.5),
                    undertone: record.undertone,
                    fitzpatrick: record.fitzpatrick,
                    confidence: record.confidence,
                    season: record.season,
                    guide: SeasonGuideLoader.loadBundled()?[record.season],
                    shadeMatches: shadeMatches
                )

                ShareLink(item: AnalysisSummary.text(for: record)) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding()
        }
        .navigationTitle(record.season.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
