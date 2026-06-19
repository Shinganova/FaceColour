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
}
