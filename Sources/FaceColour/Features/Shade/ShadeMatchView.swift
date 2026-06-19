import SwiftUI

/// Shows the closest Monk skin-tone matches for the detected skin color.
struct ShadeMatchView: View {
    let matches: [ShadeMatch]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Closest skin-tone shades")
                .font(.headline)

            if let best = matches.first {
                HStack(spacing: 12) {
                    swatch(best.tone.hex, size: 56)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Monk tone \(best.tone.tone)")
                            .font(.headline)
                        Text("Closest match (ΔE \(formatted(best.deltaE)))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            HStack(spacing: 12) {
                ForEach(Array(matches.enumerated()), id: \.offset) { _, match in
                    VStack(spacing: 4) {
                        swatch(match.tone.hex, size: 40)
                        Text("\(match.tone.tone)").font(.caption2)
                        Text("ΔE \(formatted(match.deltaE))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func formatted(_ d: Double) -> String { String(format: "%.1f", d) }

    @ViewBuilder
    private func swatch(_ hex: String, size: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: hex) ?? .gray)
            .frame(width: size, height: size)
            .overlay {
                RoundedRectangle(cornerRadius: 8).stroke(.quaternary, lineWidth: 1)
            }
    }
}

#Preview {
    ShadeMatchView(matches: [
        ShadeMatch(tone: MonkTone(tone: 5, hex: "#d7bd96"), deltaE: 1.8),
        ShadeMatch(tone: MonkTone(tone: 4, hex: "#eadaba"), deltaE: 4.2),
        ShadeMatch(tone: MonkTone(tone: 6, hex: "#a07e56"), deltaE: 6.9),
    ])
    .padding()
}
