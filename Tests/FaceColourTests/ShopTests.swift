import XCTest
@testable import FaceColour

final class ShopTests: XCTestCase {

    private func product(_ id: String, seasons: [Season]?, monkTone: Int?) -> Product {
        Product(id: id, title: id, brand: nil, price: nil, imageURL: nil,
                productURL: URL(string: "https://example.com/\(id)")!,
                colorHex: nil, category: nil, seasons: seasons, monkTone: monkTone)
    }

    func testSeasonFilterKeepsTaggedAndUntagged() {
        let items = [
            product("autumn", seasons: [.autumn], monkTone: nil),
            product("summer", seasons: [.summer], monkTone: nil),
            product("general", seasons: nil, monkTone: nil),
        ]
        let result = ProductMatcher.filter(items, season: .autumn, monkTone: nil).map(\.id)
        XCTAssertEqual(Set(result), ["autumn", "general"])
        XCTAssertFalse(result.contains("summer"))
    }

    func testToneToleranceFilter() {
        let items = [
            product("t4", seasons: nil, monkTone: 4),
            product("t6", seasons: nil, monkTone: 6),
            product("t9", seasons: nil, monkTone: 9),
            product("notone", seasons: nil, monkTone: nil),
        ]
        // Requesting tone 5 with default tolerance 1 -> keeps 4 and 6 (and untagged).
        let result = Set(ProductMatcher.filter(items, season: nil, monkTone: 5).map(\.id))
        XCTAssertEqual(result, ["t4", "t6", "notone"])
    }

    func testMockServiceFilters() async throws {
        let products = try await MockProductService().products(season: .summer, monkTone: nil)
        XCTAssertFalse(products.isEmpty)
        for p in products {
            if let seasons = p.seasons, !seasons.isEmpty {
                XCTAssertTrue(seasons.contains(.summer))
            }
        }
    }

    func testProductListResponseDecodes() throws {
        let json = """
        { "products": [
            { "id": "x1", "title": "Tee", "productURL": "https://example.com/x1",
              "seasons": ["winter"], "monkTone": null }
        ] }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(ProductListResponse.self, from: json)
        XCTAssertEqual(response.products.count, 1)
        XCTAssertEqual(response.products.first?.seasons, [.winter])
        XCTAssertEqual(response.products.first?.productURL.absoluteString, "https://example.com/x1")
    }

    func testFactoryFallsBackToMockWithoutConfig() {
        // The test bundle has no PRODUCT_API_* keys -> mock service.
        let service = ProductServiceFactory.make(bundle: Bundle(for: Self.self))
        XCTAssertTrue(service is MockProductService)
    }
}
