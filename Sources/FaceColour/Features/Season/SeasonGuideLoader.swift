import Foundation

/// Loads the bundled season palettes (`seasons.json`).
enum SeasonGuideLoader {
    /// Decodes the guide book from the app bundle. Returns nil if missing/invalid.
    static func loadBundled(bundle: Bundle = .main) -> SeasonGuideBook? {
        guard let url = bundle.url(forResource: "seasons", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? decode(data)
    }

    /// Pure decode — used by tests with inline JSON.
    static func decode(_ data: Data) throws -> SeasonGuideBook {
        try JSONDecoder().decode(SeasonGuideBook.self, from: data)
    }
}
