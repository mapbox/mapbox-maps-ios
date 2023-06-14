import XCTest
@testable import MapboxMaps

final class TileRegionLoadOptions_MapboxMapsTests: XCTestCase {

    var coordinate: CLLocationCoordinate2D!

    override func setUp() {
        super.setUp()
        coordinate = .random()
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
        let geometry: Geometry? = .random(Point(.random()).geometry)
        let descriptors: [TilesetDescriptor]? = .random([])
        let metadata: [Int]? = .random(Array.random(withLength: 5, generator: { Int.random(in: 0...9) }))
        let acceptExpired = Bool.random()
        let networkRestriction: NetworkRestriction = [.none, .disallowAll, .disallowExpensive].randomElement()!
        let averageBytesPerSecond: Int? = .random(Int.random(in: 1...10_000))
        let extraOptions: [Int]? = .random(Array.random(withLength: 5, generator: { Int.random(in: 0...9) }))

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
