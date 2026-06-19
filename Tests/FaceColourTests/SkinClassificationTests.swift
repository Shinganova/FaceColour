import XCTest
@testable import FaceColour

/// Locks the undertone / depth bin boundaries so behavior (and the Android port)
/// stays in sync with `docs/color-algorithm.md`.
final class SkinClassificationTests: XCTestCase {

    func testUndertoneBands() {
        XCTAssertEqual(Undertone.classify(hueAngle: 30), .cool)
        XCTAssertEqual(Undertone.classify(hueAngle: 44.9), .cool)
        XCTAssertEqual(Undertone.classify(hueAngle: 50), .neutral)   // between 45 and 57
        XCTAssertEqual(Undertone.classify(hueAngle: 57), .warm)
        XCTAssertEqual(Undertone.classify(hueAngle: 70), .warm)
    }

    func testDepthBandsByITA() {
        XCTAssertEqual(Depth.classify(ita: 60), .veryLight)
        XCTAssertEqual(Depth.classify(ita: 50), .light)
        XCTAssertEqual(Depth.classify(ita: 35), .intermediate)
        XCTAssertEqual(Depth.classify(ita: 20), .tan)
        XCTAssertEqual(Depth.classify(ita: 0), .brown)
        XCTAssertEqual(Depth.classify(ita: -40), .dark)
    }
}
