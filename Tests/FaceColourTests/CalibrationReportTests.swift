import XCTest
@testable import FaceColour

final class CalibrationReportTests: XCTestCase {
    func testReportContainsKeyMetrics() {
        let skin = SkinToneResult(
            representativeRGB: RGBColor(hex: "#CC9E80")!,
            lab: LabColor(L: 68, a: 12, b: 22),
            hueAngle: 61.4,
            ita: 33.2,
            undertone: .warm,
            fitzpatrick: .typeIII,
            confidence: .high,
            sampleCount: 240
        )
        let closest = ShadeMatch(tone: MonkTone(tone: 6, hex: "#a07e56"), deltaE: 3.1)
        let text = CalibrationReport.text(skin: skin, season: .autumn, closest: closest)

        XCTAssertTrue(text.contains("hex=#CC9E80"))
        XCTAssertTrue(text.contains("hue=61.4"))
        XCTAssertTrue(text.contains("ITA=33.2"))
        XCTAssertTrue(text.contains("undertone=warm"))
        XCTAssertTrue(text.contains("season=autumn"))
        XCTAssertTrue(text.contains("shade=Monk6"))
    }
}
