import Foundation

/// Local sample catalog so the shop works with no API key (and in previews/CI).
/// Filtering uses the same pure `ProductMatcher` the real flow relies on.
struct MockProductService: ProductService {
    var catalog: [Product]

    init(catalog: [Product] = MockCatalog.all) {
        self.catalog = catalog
    }

    func products(season: Season?, monkTone: Int?) async throws -> [Product] {
        ProductMatcher.filter(catalog, season: season, monkTone: monkTone)
    }
}

enum MockCatalog {
    static let all: [Product] = [
        Product(id: "m1", title: "Coral Lipstick", brand: "Sample Beauty", price: "$18",
                imageURL: nil, productURL: URL(string: "https://example.com/p/m1")!,
                colorHex: "#FF7F50", category: .makeup, seasons: [.spring], monkTone: nil),
        Product(id: "m2", title: "Warm Turquoise Scarf", brand: "Sample Apparel", price: "$32",
                imageURL: nil, productURL: URL(string: "https://example.com/p/m2")!,
                colorHex: "#2EC4B6", category: .clothing, seasons: [.spring, .winter], monkTone: nil),
        Product(id: "m3", title: "Dusty Rose Blush", brand: "Sample Beauty", price: "$22",
                imageURL: nil, productURL: URL(string: "https://example.com/p/m3")!,
                colorHex: "#D8A1A1", category: .makeup, seasons: [.summer], monkTone: nil),
        Product(id: "m4", title: "Rust Knit Sweater", brand: "Sample Apparel", price: "$54",
                imageURL: nil, productURL: URL(string: "https://example.com/p/m4")!,
                colorHex: "#B7410E", category: .clothing, seasons: [.autumn], monkTone: nil),
        Product(id: "m5", title: "Emerald Silk Top", brand: "Sample Apparel", price: "$48",
                imageURL: nil, productURL: URL(string: "https://example.com/p/m5")!,
                colorHex: "#009B77", category: .clothing, seasons: [.winter], monkTone: nil),
        Product(id: "f1", title: "Foundation — Light Tone 4", brand: "Sample Beauty", price: "$29",
                imageURL: nil, productURL: URL(string: "https://example.com/p/f1")!,
                colorHex: "#eadaba", category: .foundation, seasons: nil, monkTone: 4),
        Product(id: "f2", title: "Foundation — Medium Tone 6", brand: "Sample Beauty", price: "$29",
                imageURL: nil, productURL: URL(string: "https://example.com/p/f2")!,
                colorHex: "#a07e56", category: .foundation, seasons: nil, monkTone: 6),
        Product(id: "f3", title: "Foundation — Deep Tone 9", brand: "Sample Beauty", price: "$29",
                imageURL: nil, productURL: URL(string: "https://example.com/p/f3")!,
                colorHex: "#3a312a", category: .foundation, seasons: nil, monkTone: 9),
    ]
}
