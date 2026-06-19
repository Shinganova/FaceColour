import SwiftUI

/// Compact summary of a detected skin tone: swatch + undertone / type / confidence.
struct SkinToneResultCard: View {
    let representativeRGB: RGBColor
    let undertone: Undertone
    let fitzpatrick: Fitzpatrick
    let confidence: Confidence

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(representativeRGB))
                .frame(width: 64, height: 64)
                .overlay {
                    RoundedRectangle(cornerRadius: 12).stroke(.quaternary, lineWidth: 1)
                }
                .accessibilityLabel("Detected skin color")

            VStack(alignment: .leading, spacing: 4) {
                Text("Undertone: \(undertone.displayName)")
                    .font(.headline)
                Text("Skin type: \(fitzpatrick.displayName) (\(fitzpatrick.depthDescription))")
                    .foregroundStyle(.secondary)
                Label("Confidence: \(confidence.displayName)",
                      systemImage: confidence == .low ? "exclamationmark.triangle" : "checkmark.seal")
                    .font(.subheadline)
                    .foregroundStyle(confidence == .low ? .orange : .secondary)
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    SkinToneResultCard(representativeRGB: RGBColor(r: 0.80, g: 0.62, b: 0.50),
                       undertone: .warm, fitzpatrick: .typeIII, confidence: .high)
        .padding()
}
