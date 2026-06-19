import SwiftUI

/// Compact summary of a detected skin tone: swatch + undertone / depth / confidence.
struct SkinToneResultCard: View {
    let result: SkinToneResult

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(result.representativeRGB))
                .frame(width: 64, height: 64)
                .overlay {
                    RoundedRectangle(cornerRadius: 12).stroke(.quaternary, lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text("Undertone: \(result.undertone.displayName)")
                    .font(.headline)
                Text("Skin type: \(result.fitzpatrick.displayName) (\(result.fitzpatrick.depthDescription))")
                    .foregroundStyle(.secondary)
                Label("Confidence: \(result.confidence.displayName)",
                      systemImage: result.confidence == .low ? "exclamationmark.triangle" : "checkmark.seal")
                    .font(.subheadline)
                    .foregroundStyle(result.confidence == .low ? .orange : .secondary)
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    SkinToneResultCard(result: SkinToneResult(
        representativeRGB: RGBColor(r: 0.80, g: 0.62, b: 0.50),
        lab: LabColor(L: 68, a: 12, b: 22),
        hueAngle: 61, ita: 33,
        undertone: .warm, fitzpatrick: .typeIII, confidence: .high, sampleCount: 240
    ))
    .padding()
}
