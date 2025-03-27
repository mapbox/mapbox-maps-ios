import XCTest
@testable import MapboxMaps

final class TileRegionLoadOptions_MapboxMapsTests: XCTestCase {

    var coordinate: CLLocationCoordinate2D!

    override func setUp() {
        super.setUp()
        coordinate = .testConstantValue()
    }

    override func tearDown() {
        coordinate = nil
        super.tearDown()
    }

    func testInitializationWithNonJSONMetadata() {
        let tileRegionLoadOptions = TileRegionLoadOptions(
            geometry: nil,
            descriptors: [],
            metadata: UIView(),
            acceptExpired: false,
            networkRestriction: .none,
            averageBytesPerSecond: nil)

        XCTAssertNil(tileRegionLoadOptions)
    }

    func testInitialization() throws {
        let geometry: Geometry? = Point(.testConstantValue()).geometry
        let descriptors: [TilesetDescriptor]? = .some([])
        let metadata: [Int] = [42, 54, 23, 43, 32]
        let acceptExpired = Bool.testConstantValue()
        let networkRestriction: NetworkRestriction = .disallowExpensive
        let averageBytesPerSecond: Int? = 8903
        let extraOptions: [Int]? = [5, 3, 2, 1, 3]

        let tileRegionLoadOptions = try XCTUnwrap(TileRegionLoadOptions(
            geometry: geometry,
            descriptors: descriptors,
            metadata: metadata,
            acceptExpired: acceptExpired,
            networkRestriction: networkRestriction,
            averageBytesPerSecond: averageBytesPerSecond,
            extraOptions: extraOptions))

        XCTAssertEqual(tileRegionLoadOptions.geometry, geometry)
        XCTAssertEqual(tileRegionLoadOptions.metadata as? [Int], metadata)
        XCTAssertEqual(tileRegionLoadOptions.acceptExpired, acceptExpired)
        XCTAssertEqual(tileRegionLoadOptions.networkRestriction, networkRestriction)
        XCTAssertEqual(tileRegionLoadOptions.averageBytesPerSecond, averageBytesPerSecond)
        XCTAssertEqual(tileRegionLoadOptions.extraOptions as? [Int], extraOptions)
    }

    func testInitializationDefaultValues() throws {
        let tileRegionLoadOptions = try XCTUnwrap(TileRegionLoadOptions(geometry: nil))

        XCTAssertNil(tileRegionLoadOptions.descriptors)
        XCTAssertNil(tileRegionLoadOptions.metadata)
        XCTAssertFalse(tileRegionLoadOptions.acceptExpired)
        XCTAssertEqual(tileRegionLoadOptions.networkRestriction, .none)
        XCTAssertNil(tileRegionLoadOptions.averageBytesPerSecond)
        XCTAssertNil(tileRegionLoadOptions.__startLocation)
        XCTAssertNil(tileRegionLoadOptions.extraOptions)
    }

    func testInitializationWithInvalidExtraOptions() throws {
        let tileRegionLoadOptions = try XCTUnwrap(TileRegionLoadOptions(geometry: nil, extraOptions: "not a valid JSON"))
        XCTAssertNil(tileRegionLoadOptions.extraOptions)
    }
}
