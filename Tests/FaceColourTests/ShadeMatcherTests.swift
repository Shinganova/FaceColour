import XCTest
@testable import FaceColour

final class ShadeMatcherTests: XCTestCase {
    private let matcher = ShadeMatcher()

    private let tones = [
        MonkTone(tone: 1, hex: "#f6ede4"),
        MonkTone(tone: 5, hex: "#d7bd96"),
        MonkTone(tone: 10, hex: "#292420"),
    ]

    func testNearestToneRanksFirst() {
        // A near-lightest skin color should match tone 1.
        let light = ColorConversions.toLab(RGBColor(hex: "#f5ecdf")!)
        XCTAssertEqual(matcher.match(light, against: tones).first?.tone.tone, 1)

        // A very deep color should match tone 10.
        let deep = ColorConversions.toLab(RGBColor(hex: "#2a2521")!)
        XCTAssertEqual(matcher.match(deep, against: tones).first?.tone.tone, 10)
    }

    func testExactToneHasZeroDeltaE() {
        let lab = ColorConversions.toLab(RGBColor(hex: "#d7bd96")!)
        let best = matcher.match(lab, against: tones).first
        XCTAssertEqual(best?.tone.tone, 5)
        XCTAssertEqual(best?.deltaE ?? 99, 0, accuracy: 1e-6)
    }

    func testTopNLimitsAndSorts() {
        let lab = ColorConversions.toLab(RGBColor(hex: "#c9b48f")!)
        let matches = matcher.match(lab, against: tones, topN: 2)
        XCTAssertEqual(matches.count, 2)
        XCTAssertLessThanOrEqual(matches[0].deltaE, matches[1].deltaE)
    }

    func testDecodeAndBundledTones() throws {
        let json = #"{ "tones": [ { "tone": 1, "hex": "#f6ede4" }, { "tone": 10, "hex": "#292420" } ] }"#
            .data(using: .utf8)!
        XCTAssertEqual(try ShadeLoader.decode(json).tones.count, 2)

        // Bundled resource (skip if not loaded in a host-less test run).
        guard let ref = ShadeLoader.loadBundled(bundle: Bundle(for: Self.self))
            ?? ShadeLoader.loadBundled(bundle: .main) else {
            throw XCTSkip("shades.json not available in this test context")
        }
        XCTAssertEqual(ref.tones.count, 10)
    }
}
