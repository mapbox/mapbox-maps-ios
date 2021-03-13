import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

internal class FlyToTests: XCTestCase {

    // swiftlint:disable identifier_name

    internal func testFlyToCoordinatesSameLatitude() throws {
        let s0 = CLLocationCoordinate2D(latitude: 10, longitude: 10)
        let s2 = CLLocationCoordinate2D(latitude: 10, longitude: 20)
        privateTestFlyTo(s0: s0, s2: s2)
    }

    // Test across equator
    internal func testFlyToCoordinatesSameLongitudeOppositeLatitudes() throws {
        let s0 = CLLocationCoordinate2D(latitude: 10, longitude: 10)
        let s2 = CLLocationCoordinate2D(latitude: -10, longitude: 10)
        privateTestFlyTo(s0: s0, s2: s2)
    }

    fileprivate func privateTestFlyTo(s0: CLLocationCoordinate2D, s2: CLLocationCoordinate2D) {
        let source = CameraOptions(center: s0,
                                   padding: .zero,
                                   anchor: .zero,
                                   zoom: 10,
                                   bearing: 0,
                                   pitch: 0)

        let dest = CameraOptions(center: s2,
                                 padding: .zero,
                                 anchor: .zero,
                                 zoom: 10,
                                 bearing: 0,
                                 pitch: 0)

        guard let flyTo = FlyToInterpolator(from: source,
                                            to: dest,
                                            size: CGSize(width: 1000.0, height: 1000.0)) else {
            XCTFail("Failed to create interpolator")
            return
        }

        let d0 = flyTo.coordinate(at: 0.0)
        let d1 = flyTo.coordinate(at: 0.5)
        let d2 = flyTo.coordinate(at: 1.0)

        XCTAssertEqual(d0.latitude, s0.latitude, accuracy: 0.00001)
        XCTAssertEqual(d0.longitude, s0.longitude, accuracy: 0.00001)

        XCTAssertEqual(d1.latitude, (s0.latitude+s2.latitude)/2, accuracy: 0.00001)
        XCTAssertEqual(d1.longitude, (s0.longitude+s2.longitude)/2, accuracy: 0.00001)

        XCTAssertEqual(d2.latitude, s2.latitude, accuracy: 0.00001)
        XCTAssertEqual(d2.longitude, s2.longitude, accuracy: 0.00001)
    }
    // swiftlint:enable identifier_name
}
