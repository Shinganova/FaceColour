import Foundation

enum ProductCategory: String, Codable, Equatable {
    case makeup, foundation, clothing, accessory, other
}

/// A shoppable product. `productURL` is the retailer deep-link (no in-app checkout).
/// `seasons` / `monkTone` are optional relevance tags used for filtering.
struct Product: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    let brand: String?
    let price: String?
    let imageURL: URL?
    let productURL: URL
    let colorHex: String?
    let category: ProductCategory?
    let seasons: [Season]?
    let monkTone: Int?
}

/// Pure relevance filtering — shared with the Android port.
enum ProductMatcher {
    /// Keep products that suit the season (untagged = general) and, for
    /// shade-specific products, are within `toneTolerance` of the matched tone.
    static func filter(_ products: [Product],
                       season: Season?,
                       monkTone: Int?,
                       toneTolerance: Int = 1) -> [Product] {
        products.filter { product in
            let seasonOK: Bool
            if let season, let tags = product.seasons, !tags.isEmpty {
                seasonOK = tags.contains(season)
            } else {
                seasonOK = true
            }

            let toneOK: Bool
            if let monkTone, let tone = product.monkTone {
                toneOK = abs(tone - monkTone) <= toneTolerance
            } else {
                toneOK = true
            }

            return seasonOK && toneOK
        }
    }
}
