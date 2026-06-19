import Foundation

/// Loads the bundled Monk reference tones (`shades.json`).
enum ShadeLoader {
    static func loadBundled(bundle: Bundle = .main) -> ShadeReference? {
        guard let url = bundle.url(forResource: "shades", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? decode(data)
    }

    /// Pure decode — used by tests with inline JSON.
    static func decode(_ data: Data) throws -> ShadeReference {
        try JSONDecoder().decode(ShadeReference.self, from: data)
    }
}
