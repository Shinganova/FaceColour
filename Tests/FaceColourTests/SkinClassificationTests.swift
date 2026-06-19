import XCTest
@testable import FaceColour

/// Locks the undertone / Fitzpatrick bin boundaries so behavior (and the Android
/// port) stays in sync with `docs/color-algorithm.md`.
final class SkinClassificationTests: XCTestCase {

    func testUndertoneBands() {
        XCTAssertEqual(Undertone.classify(hueAngle: 30), .cool)
        XCTAssertEqual(Undertone.classify(hueAngle: 44.9), .cool)
        XCTAssertEqual(Undertone.classify(hueAngle: 50), .neutral)   // between 45 and 57
        XCTAssertEqual(Undertone.classify(hueAngle: 57), .warm)
        XCTAssertEqual(Undertone.classify(hueAngle: 70), .warm)
    }

    func testFitzpatrickBandsByITA() {
        XCTAssertEqual(Fitzpatrick.classify(ita: 60), .typeI)
        XCTAssertEqual(Fitzpatrick.classify(ita: 55), .typeI)    // lower edge of I
        XCTAssertEqual(Fitzpatrick.classify(ita: 50), .typeII)
        XCTAssertEqual(Fitzpatrick.classify(ita: 41), .typeII)   // lower edge of II
        XCTAssertEqual(Fitzpatrick.classify(ita: 35), .typeIII)
        XCTAssertEqual(Fitzpatrick.classify(ita: 20), .typeIV)
        XCTAssertEqual(Fitzpatrick.classify(ita: 0), .typeV)
        XCTAssertEqual(Fitzpatrick.classify(ita: -30), .typeV)   // -30 is included in V ([-30, 10))
        XCTAssertEqual(Fitzpatrick.classify(ita: -40), .typeVI)
    }
}
