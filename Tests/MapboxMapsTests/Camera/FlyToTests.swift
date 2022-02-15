import XCTest
@testable import MapboxMaps

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

        let source = CameraState(
            MapboxCoreMaps.CameraState(
                center: s0,
                padding: .init(
                    top: 0,
                    left: 0,
                    bottom: 0,
                    right: 0),
                zoom: 10,
                bearing: 0,
                pitch: 0))

        let dest = CameraOptions(
            center: s2,
            padding: .zero,
            anchor: .zero,
            zoom: 10,
            bearing: 0,
            pitch: 0)

        let flyTo = FlyToInterpolator(
            from: source,
            to: dest,
            cameraBounds: CameraBounds.default,
            size: CGSize(width: 1000.0, height: 1000.0))

        let d0 = flyTo.coordinate(at: 0.0)
        let d1 = flyTo.coordinate(at: 0.5)
        let d2 = flyTo.coordinate(at: 1.0)

        let epsilon = 0.0001
        XCTAssertEqual(d0.latitude, s0.latitude, accuracy: epsilon)
        XCTAssertEqual(d0.longitude, s0.longitude, accuracy: epsilon)

        XCTAssertEqual(d1.latitude, (s0.latitude+s2.latitude)/2, accuracy: epsilon)
        XCTAssertEqual(d1.longitude, (s0.longitude+s2.longitude)/2, accuracy: epsilon)

        XCTAssertEqual(d2.latitude, s2.latitude, accuracy: epsilon)
        XCTAssertEqual(d2.longitude, s2.longitude, accuracy: epsilon)
    }
    // swiftlint:enable identifier_name

    func testForValidValues() {

        let epsilon: CLLocationDegrees = 0.0001

        for _ in 0..<10 {

            // Longitude increases easterly for this test.
            let sourceCoord = CLLocationCoordinate2D(
                latitude: CLLocationDegrees.random(in: -85..<85),
                longitude: CLLocationDegrees.random(in: 0..<180)
            )

            let destCoord = CLLocationCoordinate2D(
                latitude: CLLocationDegrees.random(in: -85..<85),
                longitude: CLLocationDegrees.random(in: 180..<360)
            )

            let source = CameraState(
                MapboxCoreMaps.CameraState(
                    center: sourceCoord,
                    padding: .init(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        right: 0),
                    zoom: 14,
                    bearing: 0,
                    pitch: 0))

            let dest = CameraOptions(center: destCoord,
                                     zoom: 18,
                                     bearing: 90,
                                     pitch: 45)

            let flyTo = FlyToInterpolator(from: source, to: dest, cameraBounds: CameraBounds.default, size: CGSize(width: 500.0, height: 500.0))
            guard var boundingBox = BoundingBox(from: [sourceCoord, destCoord]) else {
                XCTFail("Failed to create interpolator")
                continue
            }

            boundingBox.southWest.latitude -= epsilon
            boundingBox.southWest.longitude -= epsilon
            boundingBox.northEast.latitude += epsilon
            boundingBox.northEast.longitude += epsilon

            let duration = flyTo.duration()
            XCTAssert(duration > 0)

            for t: Double in stride(from: 0, to: 1, by: 0.01) {

                let coordinate = flyTo.coordinate(at: t)

                XCTAssert(boundingBox.contains(coordinate, ignoreBoundary: false), "t=\(t) coordinate=\(coordinate) boundingBox=\(boundingBox)")

                // Zoom doesn't go below start or end
                let zoom = CGFloat(flyTo.zoom(at: t))
                XCTAssert(zoom <= max(source.zoom, dest.zoom!), "t=\(t) zoom=\(zoom)")

                let bearing = CLLocationDirection(flyTo.bearing(at: t))
                XCTAssert(bearing >= source.bearing, "t=\(t) bearing=\(bearing)")
                XCTAssert(bearing <= dest.bearing!, "t=\(t) bearing=\(bearing)")

                let pitch = CGFloat(flyTo.pitch(at: t))
                XCTAssert(pitch >= source.pitch, "t=\(t) pitch=\(pitch)")
                XCTAssert(pitch <= dest.pitch!, "t=\(t) pitch=\(pitch)")
            }
        }
    }
}
