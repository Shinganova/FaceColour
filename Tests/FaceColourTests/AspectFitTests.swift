import XCTest
@testable import FaceColour

final class AspectFitTests: XCTestCase {

    func testLandscapeContentLetterboxesVertically() {
        // 200x100 content into a 100x100 square -> full width, centered vertically.
        let rect = AspectFit.rect(content: CGSize(width: 200, height: 100),
                                  in: CGSize(width: 100, height: 100))
        XCTAssertEqual(rect.width, 100, accuracy: 0.001)
        XCTAssertEqual(rect.height, 50, accuracy: 0.001)
        XCTAssertEqual(rect.minX, 0, accuracy: 0.001)
        XCTAssertEqual(rect.minY, 25, accuracy: 0.001)
    }

    func testPortraitContentPillarboxesHorizontally() {
        // 100x200 content into a 100x100 square -> full height, centered horizontally.
        let rect = AspectFit.rect(content: CGSize(width: 100, height: 200),
                                  in: CGSize(width: 100, height: 100))
        XCTAssertEqual(rect.width, 50, accuracy: 0.001)
        XCTAssertEqual(rect.height, 100, accuracy: 0.001)
        XCTAssertEqual(rect.minX, 25, accuracy: 0.001)
        XCTAssertEqual(rect.minY, 0, accuracy: 0.001)
    }

    func testZeroSizeIsSafe() {
        XCTAssertEqual(AspectFit.rect(content: .zero, in: CGSize(width: 100, height: 100)), .zero)
        XCTAssertEqual(AspectFit.rect(content: CGSize(width: 100, height: 100), in: .zero), .zero)
    }
}
