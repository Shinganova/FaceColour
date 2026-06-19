import XCTest
@testable import FaceColour

final class SeasonGuideTests: XCTestCase {

    func testRGBColorHexParsing() {
        let c = RGBColor(hex: "#FF7F50")
        XCTAssertNotNil(c)
        XCTAssertEqual(c?.r ?? 0, 1.0, accuracy: 0.001)
        XCTAssertEqual(c?.g ?? 0, 127.0 / 255, accuracy: 0.001)
        XCTAssertEqual(c?.b ?? 0, 80.0 / 255, accuracy: 0.001)

        XCTAssertNotNil(RGBColor(hex: "FFFFFF"))   // no leading #
        XCTAssertNil(RGBColor(hex: "#FFF"))         // wrong length
        XCTAssertNil(RGBColor(hex: "#ZZZZZZ"))      // not hex
    }

    func testDecodeGuideBook() throws {
        let json = """
        {
          "spring": { "title": "Spring", "summary": "s",
            "palette": [{"name":"Coral","hex":"#FF7F50"}], "avoid": [] },
          "summer": { "title": "Summer", "summary": "s", "palette": [], "avoid": [] },
          "autumn": { "title": "Autumn", "summary": "s", "palette": [], "avoid": [] },
          "winter": { "title": "Winter", "summary": "s", "palette": [], "avoid": [] }
        }
        """.data(using: .utf8)!

        let book = try SeasonGuideLoader.decode(json)
        XCTAssertEqual(book.spring.title, "Spring")
        XCTAssertEqual(book[.spring].palette.first?.name, "Coral")
        XCTAssertEqual(book[.winter].title, "Winter")
    }

    /// The bundled palettes load and every season has recommendations.
    /// The resource lives in the app bundle, which may not be loaded in a
    /// host-less unit-test run — skip rather than fail in that case.
    func testBundledSeasonsLoad() throws {
        guard let book = SeasonGuideLoader.loadBundled(bundle: Bundle(for: Self.self))
            ?? SeasonGuideLoader.loadBundled(bundle: .main) else {
            throw XCTSkip("seasons.json not available in this test context")
        }
        for season in Season.allCases {
            XCTAssertFalse(book[season].palette.isEmpty, "\(season) palette is empty")
        }
    }
}
