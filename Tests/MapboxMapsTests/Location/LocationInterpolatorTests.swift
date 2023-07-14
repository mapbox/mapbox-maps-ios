import XCTest
@testable import MapboxMaps

final class LocationInterpolatorTests: XCTestCase {
    var me: LocationInterpolator!
    override func setUp() {
        me = .init()
    }

    override func tearDown() {
        me = nil
    }

    func testEdgeCases() {
        var result = me.interpolate(from: [], to: [], fraction: 1)
        XCTAssertEqual(result, [])

        let l1 = Location.random()
        result = me.interpolate(from: [l1], to: [], fraction: 1)
        XCTAssertEqual(result, [])

        result = me.interpolate(from: [], to: [l1], fraction: 0.5)
        XCTAssertEqual(result, [l1])

        result = me.interpolate(from: [], to: [l1], fraction: 1)
        XCTAssertEqual(result, [l1])

        result = me.interpolate(from: [], to: [l1], fraction: 2)
        XCTAssertEqual(result, [l1])
    }

    func testInterpolation() throws {
        let from = Location(
            coordinate: .init(latitude: 0, longitude: 0),
            timestamp: Date.init(timeIntervalSince1970: 0),
            altitude: 0,
            horizontalAccuracy: 0,
            verticalAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
            bearing: 0,
            bearingAccuracy: 0,
            floor: 0,
            source: "s1",
            extra: "foo"
        )

        let to = Location(
            coordinate: .init(latitude: -90, longitude: 200),
            timestamp: Date.init(timeIntervalSince1970: 100),
            altitude: 300,
            horizontalAccuracy: 400,
            verticalAccuracy: 500,
            speed: 600,
            speedAccuracy: 700,
            bearing: 800,
            bearingAccuracy: 900,
            floor: 1000,
            source: "s2",
            extra: "bar"
        )

        let f = 0.5
        let result = try XCTUnwrap(me.interpolate(from: [from], to: [to], fraction: f).last)

        var coord = CLLocationCoordinate2D(latitude: -90, longitude: 200).wrap()
        coord.latitude *= f
        coord.longitude *= f

        let expected = Location(
            coordinate: coord,
            timestamp: Date.init(timeIntervalSince1970: 100),
            altitude: 300 * f,
            horizontalAccuracy: 400 * f,
            verticalAccuracy: 500,
            speed: 600,
            speedAccuracy: 700,
            bearing: 800.wrapped(to: 0..<360) * f,
            bearingAccuracy: 900,
            floor: 1000,
            source: "s2",
            extra: "bar"
        )
        XCTAssertEqual(result, expected)
    }

    func testInterpolationOptionals() throws {
        let from = Location(
            coordinate: .init(latitude: 0, longitude: 0),
            timestamp: Date.init(timeIntervalSince1970: 0),
            altitude: nil,
            horizontalAccuracy: nil,
            verticalAccuracy: nil,
            speed: nil,
            speedAccuracy: nil,
            bearing: nil,
            bearingAccuracy: nil,
            floor: nil,
            source: nil,
            extra: nil
        )

        let to = Location(
            coordinate: .init(latitude: 100, longitude: 100),
            timestamp: Date.init(timeIntervalSince1970: 100),
            altitude: 100,
            horizontalAccuracy: 100,
            verticalAccuracy: nil,
            speed: nil,
            speedAccuracy: nil,
            bearing: 100,
            bearingAccuracy: nil,
            floor: nil,
            source: "foo",
            extra: nil
        )

        let f = 0.5
        let result = try XCTUnwrap(me.interpolate(from: [from], to: [to], fraction: f).last)

        let expected = Location(
            coordinate: .init(latitude: 100 * f, longitude: 100 * f),
            timestamp: Date.init(timeIntervalSince1970: 100),
            altitude: 100,
            horizontalAccuracy: 100,
            verticalAccuracy: nil,
            speed: nil,
            speedAccuracy: nil,
            bearing: 100,
            bearingAccuracy: nil,
            floor: nil,
            source: "foo", // TODO: Fix Location.isEqual
            extra: nil
        )
        XCTAssertEqual(result, expected)
    }
}
