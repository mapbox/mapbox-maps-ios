import XCTest
@testable import MapboxMaps

class TileRegionEstimateOptionsTests: XCTestCase {

    func testInitilization() throws {
        let extraOptions: [Int]? = .random(Array.random(withLength: 5, generator: { Int.random(in: 0...9) }))

        let tileRegionEstimateOptions = try XCTUnwrap(TileRegionEstimateOptions(
            errorMargin: 0.1,
            preciseEstimationTimeout: 1000,
            timeout: 10,
            extraOptions: extraOptions))

        XCTAssertEqual(tileRegionEstimateOptions.errorMargin, 0.1)
        XCTAssertEqual(tileRegionEstimateOptions.preciseEstimationTimeout, 1000)
        XCTAssertEqual(tileRegionEstimateOptions.timeout, 10)
        XCTAssertEqual(tileRegionEstimateOptions.extraOptions as? [Int], extraOptions)
    }

    func testInitializationDefaultValues() throws {
        let tileRegionEstimateOptions = try XCTUnwrap(TileRegionEstimateOptions(extraOptions: nil))

        XCTAssertEqual(tileRegionEstimateOptions.errorMargin, 0.05)
        XCTAssertEqual(tileRegionEstimateOptions.preciseEstimationTimeout, 5)
        XCTAssertEqual(tileRegionEstimateOptions.timeout, 0)
        XCTAssertNil(tileRegionEstimateOptions.extraOptions)
    }
}
