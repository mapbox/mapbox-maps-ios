import XCTest
@testable import MapboxMaps

final class ProjectionTests: XCTestCase {

    func testMetersPerPoint() {
        let metersPerPointN = Projection.metersPerPoint(for: 40.0, zoom: 16)
        let metersPerPointS = Projection.metersPerPoint(for: -40.0, zoom: 16)

        XCTAssertEqual(metersPerPointN, metersPerPointS)
        XCTAssertEqual(metersPerPointN, 0.91388626079034951, accuracy: 0.000001)
    }

    func testProjectedMeters() {
        let coords = [
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: 0, longitude: 180),
            CLLocationCoordinate2D(latitude: 0, longitude: -180),
            CLLocationCoordinate2D(latitude: 45, longitude: 90),
            CLLocationCoordinate2D(latitude: -45, longitude: -90),
        ]

        let projectedMeters: [ProjectedMeters] = coords.map {
            let meters = Projection.projectedMeters(for: $0)

            // Test round trip
            let coordinate = Projection.coordinate(for: meters)
            XCTAssertEqual(coordinate.latitude, $0.latitude, accuracy: 0.000001)
            XCTAssertEqual(coordinate.longitude, $0.longitude, accuracy: 0.000001)
            return meters
        }

        XCTAssertEqual(projectedMeters[1].easting, -projectedMeters[2].easting, accuracy: 0.000001)
        XCTAssertEqual(projectedMeters[3].easting, -projectedMeters[4].easting, accuracy: 0.000001)
        XCTAssertEqual(projectedMeters[3].northing, -projectedMeters[4].northing, accuracy: 0.000001)
    }

    func testProject() {

        let lat45 = 2946.8675024093595
        let minusLat45 = 5245.132497590641
        let coords = [
            // swiftlint:disable comma
            (CLLocationCoordinate2D(latitude: 45, longitude: -180),  MercatorCoordinate(x: 0,    y: lat45)),        // top left
            (CLLocationCoordinate2D(latitude: 45, longitude: 180),   MercatorCoordinate(x: 8192, y: lat45)),        // top right
            (CLLocationCoordinate2D(latitude: -45, longitude: -180), MercatorCoordinate(x: 0,    y: minusLat45)),   // bot left
            (CLLocationCoordinate2D(latitude: -45, longitude: 180),  MercatorCoordinate(x: 8192, y: minusLat45)),   // bot right
            (CLLocationCoordinate2D(latitude: 0, longitude: 0),      MercatorCoordinate(x: 4096, y: 4096)),         // middle
            // swiftlint:enable comma
        ]

        let zoom: CGFloat = 4
        let zoomScale = pow(2, zoom)

        for coord in coords {
            let mercator = Projection.project(coord.0, zoomScale: zoomScale)
            XCTAssertEqual(mercator.x, coord.1.x, accuracy: 0.0000001)
            XCTAssertEqual(mercator.y, coord.1.y, accuracy: 0.0000001)

            // Test round trip
            let coordinate = Projection.unproject(mercator, zoomScale: zoomScale)
            XCTAssertEqual(coordinate.latitude, coord.0.latitude, accuracy: 0.0000001)
            XCTAssertEqual(coordinate.longitude, coord.0.longitude, accuracy: 0.0000001)
        }
    }

    func testMercatorMinMaxProject() {
        let northPole = CLLocationCoordinate2D(latitude: 90, longitude: 0)
        let southPole = CLLocationCoordinate2D(latitude: -90, longitude: 0)

        let zoom: CGFloat = 0
        let zoomScale = pow(2, zoom)

        let northMercator = Projection.project(northPole, zoomScale: zoomScale)
        let northPole2 = Projection.unproject(northMercator, zoomScale: zoomScale)
        XCTAssertNotEqual(northPole2.latitude, northPole.latitude)
        XCTAssertEqual(northPole2.latitude, 85.051, accuracy: 0.001)

        let southMercator = Projection.project(southPole, zoomScale: zoomScale)
        let southPole2 = Projection.unproject(southMercator, zoomScale: zoomScale)
        XCTAssertNotEqual(southPole2.latitude, southPole.latitude)
        XCTAssertEqual(southPole2.latitude, -85.051, accuracy: 0.001)

        // Check clamping
        let northMax = CLLocationCoordinate2D(latitude: Projection.latitudeMax, longitude: 0)
        let northMaxMercator = Projection.project(northMax, zoomScale: zoomScale)
        XCTAssertEqual(northMercator.y, northMaxMercator.y, accuracy: 0.000001)

        let southMin = CLLocationCoordinate2D(latitude: Projection.latitudeMin, longitude: 0)
        let southMinMercator = Projection.project(southMin, zoomScale: zoomScale)
        XCTAssertEqual(southMercator.y, southMinMercator.y, accuracy: 0.000001)
    }
}
