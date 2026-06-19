import SwiftUI

/// Shows the determined season, a short description, and the recommended palette.
struct SeasonResultView: View {
    let season: Season
    let guide: SeasonGuide

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Season: \(guide.title)")
                .font(.title3.bold())
            Text(guide.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Your palette")
                .font(.headline)
                .padding(.top, 4)
            swatches(guide.palette)

            Text("Colors to avoid")
                .font(.headline)
                .padding(.top, 4)
            swatches(guide.avoid)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func swatches(_ colors: [PaletteColor]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: color.hex) ?? .gray)
                            .frame(width: 44, height: 44)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8).stroke(.quaternary, lineWidth: 1)
                            }
                        Text(color.name)
                            .font(.caption2)
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 60)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

#Preview {
    SeasonResultView(
        season: .autumn,
        guide: SeasonGuide(
            title: "Autumn",
            summary: "Warm, deep, and muted — rich, earthy tones suit you best.",
            palette: [
                PaletteColor(name: "Rust", hex: "#B7410E"),
                PaletteColor(name: "Olive", hex: "#808000"),
                PaletteColor(name: "Teal", hex: "#357A8C"),
            ],
            avoid: [PaletteColor(name: "Icy Pink", hex: "#F4C2D7")]
        )
    )
    .padding()
}
