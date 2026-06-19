import SwiftUI

/// Sheet listing saved analyses, with delete and a detail view.
struct HistoryListView: View {
    let store: HistoryStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if store.records.isEmpty {
                    ContentUnavailableView(
                        "No saved analyses",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Tap Save on a result to keep it here.")
                    )
                } else {
                    List {
                        ForEach(store.records) { record in
                            NavigationLink {
                                HistoryDetailView(store: store, record: record)
                            } label: {
                                HistoryRow(store: store, record: record)
                            }
                        }
                        .onDelete { offsets in
                            offsets.map { store.records[$0] }.forEach(store.delete)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct HistoryRow: View {
    let store: HistoryStore
    let record: AnalysisRecord

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let thumb = store.thumbnail(for: record) {
                    Image(uiImage: thumb).resizable().scaledToFill()
                } else {
                    (Color(hex: record.representativeHex) ?? .gray)
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(record.season.displayName).font(.headline)
                Text("\(record.undertone.displayName) · \(record.fitzpatrick.displayName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(record.date, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
