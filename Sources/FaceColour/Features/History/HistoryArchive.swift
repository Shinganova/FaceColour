import Foundation

/// Pure file persistence for analysis records (JSON on disk). No UI/actor
/// dependencies, so it's directly unit-testable with a temp directory.
struct HistoryArchive {
    let directory: URL

    var fileURL: URL { directory.appendingPathComponent("records.json") }

    func load() -> [AnalysisRecord] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([AnalysisRecord].self, from: data)) ?? []
    }

    func save(_ records: [AnalysisRecord]) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(records)
        try data.write(to: fileURL, options: .atomic)
    }

    static var defaultDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("history", isDirectory: true)
    }
}
