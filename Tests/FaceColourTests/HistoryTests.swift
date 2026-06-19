import XCTest
@testable import FaceColour

final class HistoryTests: XCTestCase {

    private func makeRecord(id: UUID = UUID()) -> AnalysisRecord {
        AnalysisRecord(
            id: id,
            date: Date(timeIntervalSince1970: 1_700_000_000),
            representativeHex: "#CC9E80",
            undertone: .warm,
            fitzpatrick: .typeIII,
            confidence: .high,
            season: .autumn,
            shadeMatches: [ShadeMatchRecord(tone: 6, hex: "#a07e56", deltaE: 2.3)],
            thumbnailFileName: nil
        )
    }

    func testArchiveRoundTrip() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("fc-test-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let archive = HistoryArchive(directory: dir)
        XCTAssertTrue(archive.load().isEmpty)

        let records = [makeRecord(), makeRecord()]
        try archive.save(records)

        let reloaded = HistoryArchive(directory: dir).load()
        XCTAssertEqual(reloaded, records)
    }

    func testSummaryText() {
        let text = AnalysisSummary.text(season: .autumn,
                                        undertone: .warm,
                                        fitzpatrick: .typeIII,
                                        closestTone: 6)
        XCTAssertTrue(text.contains("Season: Autumn"))
        XCTAssertTrue(text.contains("Undertone: Warm"))
        XCTAssertTrue(text.contains("Type III"))
        XCTAssertTrue(text.contains("Monk tone 6"))
    }

    func testSummaryTextOmitsToneWhenNil() {
        let text = AnalysisSummary.text(season: .spring,
                                        undertone: .cool,
                                        fitzpatrick: .typeI,
                                        closestTone: nil)
        XCTAssertFalse(text.contains("Monk tone"))
    }

    func testRGBHexStringRoundTrip() {
        let hex = "#3A7BD5"
        let rgb = RGBColor(hex: hex)
        XCTAssertEqual(rgb?.hexString, hex)
    }
}
