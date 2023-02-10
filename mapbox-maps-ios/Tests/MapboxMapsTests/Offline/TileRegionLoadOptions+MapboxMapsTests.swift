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

    func testInitializationDefaultValues() throws {
        let tileRegionLoadOptions = try XCTUnwrap(TileRegionLoadOptions(
            geometry: nil,
            descriptors: []))

        XCTAssertNil(tileRegionLoadOptions.metadata)
        XCTAssertFalse(tileRegionLoadOptions.isAcceptExpired)
        XCTAssertEqual(tileRegionLoadOptions.networkRestriction, .none)
        XCTAssertNil(tileRegionLoadOptions.averageBytesPerSecond)
        XCTAssertNil(tileRegionLoadOptions.__startLocation)
        XCTAssertNil(tileRegionLoadOptions.extraOptions)
    }

    func testInitializationWithNilAndEmptyValues() throws {
        let tileRegionLoadOptions = try XCTUnwrap(TileRegionLoadOptions(
            geometry: nil,
            descriptors: [],
            metadata: nil,
            acceptExpired: false,
            networkRestriction: .none,
            averageBytesPerSecond: nil))

        XCTAssertNil(tileRegionLoadOptions.__geometry)
        XCTAssertNil(tileRegionLoadOptions.descriptors)
        XCTAssertFalse(tileRegionLoadOptions.isAcceptExpired)
        XCTAssertEqual(tileRegionLoadOptions.networkRestriction, .none)
        XCTAssertNil(tileRegionLoadOptions.averageBytesPerSecond)
    }

    func testInitializationWithNonNilAndNonEmptyValues() throws {
        let metadata = Array.random(withLength: .random(in: 1..<5)) {
            Int.random(in: -100...100)
        }
        let acceptExpired = Bool.random()
        let allNetworkRestrictions: [NetworkRestriction] = [.none, .disallowAll, .disallowExpensive]
        let networkRestriction = allNetworkRestrictions.randomElement()!
        let averageBytesPerSecond = Int.random(in: 1..<100000)

        let tileRegionLoadOptions = try XCTUnwrap(TileRegionLoadOptions(
            geometry: .point(Point(coordinate)),
            descriptors: [], // Skip this for now — need a way to instantiate TilesetDescriptor
            metadata: metadata,
            acceptExpired: acceptExpired,
            networkRestriction: networkRestriction,
            averageBytesPerSecond: averageBytesPerSecond))

        XCTAssertEqual(tileRegionLoadOptions.__geometry?.geometryType, GeometryType_Point)
        XCTAssertEqual(tileRegionLoadOptions.metadata as? [Int], metadata)
        XCTAssertEqual(tileRegionLoadOptions.isAcceptExpired, acceptExpired)
        XCTAssertEqual(tileRegionLoadOptions.networkRestriction, networkRestriction)
        XCTAssertEqual(tileRegionLoadOptions.__averageBytesPerSecond?.intValue, averageBytesPerSecond)
    }

    func testNonNilAverageBytesPerSecond() {
        let tileRegionLoadOptions = TileRegionLoadOptions(__geometry: nil,
                                                          descriptors: nil,
                                                          metadata: nil,
                                                          acceptExpired: false,
                                                          networkRestriction: .none,
                                                          start: nil,
                                                          averageBytesPerSecond: NSNumber(12),
                                                          extraOptions: nil)

        XCTAssertEqual(tileRegionLoadOptions.averageBytesPerSecond, 12)
    }

    func testNilAverageBytesPerSecond() {
        let tileRegionLoadOptions = TileRegionLoadOptions(__geometry: nil,
                                                          descriptors: nil,
                                                          metadata: nil,
                                                          acceptExpired: false,
                                                          networkRestriction: .none,
                                                          start: nil,
                                                          averageBytesPerSecond: nil,
                                                          extraOptions: nil)

        XCTAssertNil(tileRegionLoadOptions.averageBytesPerSecond)
    }

    func testNonNilGeometry() {
        let tileRegionLoadOptions = TileRegionLoadOptions(__geometry: MapboxCommon.Geometry(Point(coordinate)),
                                                          descriptors: nil,
                                                          metadata: nil,
                                                          acceptExpired: false,
                                                          networkRestriction: .none,
                                                          start: nil,
                                                          averageBytesPerSecond: nil,
                                                          extraOptions: nil)

        XCTAssertEqual(tileRegionLoadOptions.geometry, .point(.init(coordinate)))
    }

    func testNilGeometry() {
        let tileRegionLoadOptions = TileRegionLoadOptions(__geometry: nil,
                                                          descriptors: nil,
                                                          metadata: nil,
                                                          acceptExpired: false,
                                                          networkRestriction: .none,
                                                          start: nil,
                                                          averageBytesPerSecond: nil,
                                                          extraOptions: nil)

        XCTAssertNil(tileRegionLoadOptions.geometry)
    }
}
