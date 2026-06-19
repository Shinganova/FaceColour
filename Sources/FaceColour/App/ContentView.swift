import SwiftUI

/// Placeholder root view for Phase 0.
/// Phase 1 replaces this with the capture / face-detection flow.
struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "face.smiling")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("FaceColour")
                .font(.largeTitle.bold())
            Text("Find your colors.")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
