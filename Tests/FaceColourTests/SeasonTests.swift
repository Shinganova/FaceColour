import XCTest
@testable import FaceColour

final class SeasonTests: XCTestCase {

    func testWarmCoolDepthMapping() {
        XCTAssertEqual(Season.classify(undertone: .warm, depth: .typeII, hueAngle: 60), .spring)
        XCTAssertEqual(Season.classify(undertone: .warm, depth: .typeVI, hueAngle: 60), .autumn)
        XCTAssertEqual(Season.classify(undertone: .cool, depth: .typeII, hueAngle: 40), .summer)
        XCTAssertEqual(Season.classify(undertone: .cool, depth: .typeVI, hueAngle: 40), .winter)
    }

    func testIntermediateTypeCountsAsLight() {
        // Type III (intermediate) sits below the deep cutoff.
        XCTAssertEqual(Season.classify(undertone: .warm, depth: .typeIII, hueAngle: 60), .spring)
        XCTAssertEqual(Season.classify(undertone: .cool, depth: .typeIII, hueAngle: 40), .summer)
    }

    func testTypeIVCountsAsDeep() {
        // Type IV (tan) is the first "deep" phototype.
        XCTAssertEqual(Season.classify(undertone: .warm, depth: .typeIV, hueAngle: 60), .autumn)
        XCTAssertEqual(Season.classify(undertone: .cool, depth: .typeIV, hueAngle: 40), .winter)
    }

    func testNeutralLeansByHueAngle() {
        // >= 51 leans warm.
        XCTAssertEqual(Season.classify(undertone: .neutral, depth: .typeII, hueAngle: 55), .spring)
        XCTAssertEqual(Season.classify(undertone: .neutral, depth: .typeVI, hueAngle: 55), .autumn)
        // < 51 leans cool.
        XCTAssertEqual(Season.classify(undertone: .neutral, depth: .typeII, hueAngle: 48), .summer)
        XCTAssertEqual(Season.classify(undertone: .neutral, depth: .typeVI, hueAngle: 48), .winter)
    }
}
