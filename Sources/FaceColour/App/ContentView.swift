import SwiftUI

/// App root. Owns the history store and hosts the capture / analysis flow.
struct ContentView: View {
    @State private var history = HistoryStore()

    var body: some View {
        CaptureView(history: history)
    }
}

#Preview {
    ContentView()
}
