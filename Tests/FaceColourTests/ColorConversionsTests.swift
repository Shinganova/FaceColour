import XCTest
@testable import FaceColour

/// Canonical sRGB->Lab/HSV vectors. These are the cross-platform contract:
/// the future Android implementation must reproduce them.
final class ColorConversionsTests: XCTestCase {

    func testLabWhite() {
        let lab = ColorConversions.toLab(RGBColor(r: 1, g: 1, b: 1))
        XCTAssertEqual(lab.L, 100, accuracy: 0.1)
        XCTAssertEqual(lab.a, 0, accuracy: 0.1)
        XCTAssertEqual(lab.b, 0, accuracy: 0.1)
    }

    func testLabBlack() {
        let lab = ColorConversions.toLab(RGBColor(r: 0, g: 0, b: 0))
        XCTAssertEqual(lab.L, 0, accuracy: 0.1)
    }

    func testLabMidGray() {
        // sRGB 0.5 gray -> L*≈53.4, neutral a/b.
        let lab = ColorConversions.toLab(RGBColor(r: 0.5, g: 0.5, b: 0.5))
        XCTAssertEqual(lab.L, 53.4, accuracy: 0.5)
        XCTAssertEqual(lab.a, 0, accuracy: 0.2)
        XCTAssertEqual(lab.b, 0, accuracy: 0.2)
    }

    func testLabRed() {
        // Well-known sRGB red -> Lab ≈ (53.24, 80.09, 67.20).
        let lab = ColorConversions.toLab(RGBColor(r: 1, g: 0, b: 0))
        XCTAssertEqual(lab.L, 53.24, accuracy: 0.5)
        XCTAssertEqual(lab.a, 80.09, accuracy: 0.5)
        XCTAssertEqual(lab.b, 67.20, accuracy: 0.5)
    }

    func testHSVRed() {
        let hsv = ColorConversions.toHSV(RGBColor(r: 1, g: 0, b: 0))
        XCTAssertEqual(hsv.h, 0, accuracy: 0.001)
        XCTAssertEqual(hsv.s, 1, accuracy: 0.001)
        XCTAssertEqual(hsv.v, 1, accuracy: 0.001)
    }

    func testHSVGrayHasZeroSaturation() {
        let hsv = ColorConversions.toHSV(RGBColor(r: 0.4, g: 0.4, b: 0.4))
        XCTAssertEqual(hsv.s, 0, accuracy: 0.001)
        XCTAssertEqual(hsv.v, 0.4, accuracy: 0.001)
    }

    func testDeltaEIdentityIsZero() {
        let c = LabColor(L: 50, a: 10, b: 20)
        XCTAssertEqual(ColorConversions.deltaE76(c, c), 0, accuracy: 1e-9)
    }

    // MARK: CIEDE2000 — Sharma, Wu & Dalal reference pairs.

    func testDeltaE2000ReferencePairs() {
        let p1a = LabColor(L: 50, a: 2.6772, b: -79.7751)
        let p1b = LabColor(L: 50, a: 0, b: -82.7485)
        XCTAssertEqual(ColorConversions.deltaE2000(p1a, p1b), 2.0425, accuracy: 0.001)

        let p2a = LabColor(L: 50, a: 0, b: 0)
        let p2b = LabColor(L: 50, a: -1, b: 2)
        XCTAssertEqual(ColorConversions.deltaE2000(p2a, p2b), 2.3669, accuracy: 0.001)

        let p3a = LabColor(L: 50, a: 2.49, b: -0.001)
        let p3b = LabColor(L: 50, a: -2.49, b: 0.0009)
        XCTAssertEqual(ColorConversions.deltaE2000(p3a, p3b), 7.1792, accuracy: 0.001)
    }

    func testDeltaE2000IdentityIsZero() {
        let c = LabColor(L: 68, a: 12, b: 22)
        XCTAssertEqual(ColorConversions.deltaE2000(c, c), 0, accuracy: 1e-6)
    }
}
