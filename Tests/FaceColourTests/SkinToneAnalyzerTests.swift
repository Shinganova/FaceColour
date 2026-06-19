import XCTest
@testable import FaceColour

final class SkinToneAnalyzerTests: XCTestCase {
    private let analyzer = SkinToneAnalyzer()

    func testReturnsNilForTooFewSamples() {
        XCTAssertNil(analyzer.analyze(samples: []))
        XCTAssertNil(analyzer.analyze(samples: [RGBColor(r: 0.8, g: 0.6, b: 0.5)]))
    }

    func testUniformSkinSamplesGiveRepresentativeColorAndHighConfidence() {
        let skin = RGBColor(r: 0.80, g: 0.62, b: 0.50) // plausible: V=0.80, S≈0.375
        let result = analyzer.analyze(samples: Array(repeating: skin, count: 200))

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.sampleCount, 200)
        XCTAssertEqual(result?.representativeRGB.r ?? 0, 0.80, accuracy: 0.01)
        XCTAssertEqual(result?.representativeRGB.g ?? 0, 0.62, accuracy: 0.01)
        XCTAssertEqual(result?.representativeRGB.b ?? 0, 0.50, accuracy: 0.01)
        XCTAssertEqual(result?.confidence, .high) // count>=100 and spread≈0
    }

    func testHighlightsAndShadowsAreFilteredOut() {
        let skin = RGBColor(r: 0.80, g: 0.62, b: 0.50)
        var samples = Array(repeating: skin, count: 200)
        samples += Array(repeating: RGBColor(r: 1, g: 1, b: 1), count: 50)   // specular: V>0.95
        samples += Array(repeating: RGBColor(r: 0.02, g: 0.02, b: 0.02), count: 50) // shadow: V<0.15

        let result = analyzer.analyze(samples: samples)
        // Only the 200 skin samples survive the plausibility filter.
        XCTAssertEqual(result?.sampleCount, 200)
    }

    func testPlausibilityRejectsGrayAndOversaturated() {
        XCTAssertFalse(analyzer.isPlausibleSkin(RGBColor(r: 0.5, g: 0.5, b: 0.5)))  // gray, S=0
        XCTAssertFalse(analyzer.isPlausibleSkin(RGBColor(r: 1.0, g: 0.0, b: 0.0)))  // S=1, too saturated
        XCTAssertTrue(analyzer.isPlausibleSkin(RGBColor(r: 0.80, g: 0.62, b: 0.50)))
    }
}
