import XCTest
@testable import MapboxMaps

final class CameraStateTests: XCTestCase {
    var center: CLLocationCoordinate2D!
    var padding: EdgeInsets!
    var anchor: CGPoint!
    var zoom: CGFloat!
    var bearing: CLLocationDirection!
    var pitch: CGFloat!

    override func setUp() {
        super.tearDown()
        center = CLLocationCoordinate2D(
            latitude: .random(in: -80...80),
            longitude: .random(in: -180...180))
        padding = EdgeInsets(
            top: .random(in: 0...100),
            left: .random(in: 0...100),
            bottom: .random(in: 0...100),
            right: .random(in: 0...100))
        anchor = CGPoint(
            x: CGFloat.random(in: 0...100),
            y: CGFloat.random(in: 0...100))
        zoom = .random(in: 0...20)
        bearing = .random(in: 0...360)
        pitch = .random(in: 0...45)
    }

    override func tearDown() {
        pitch = nil
        bearing = nil
        zoom = nil
        anchor = nil
        padding = nil
        center = nil
        super.tearDown()
    }

    func testInitWithObjCValue() {
        let cameraState = CameraState(
            MapboxCoreMaps.CameraState(
                center: center,
                padding: padding,
                zoom: Double(zoom),
                bearing: bearing,
                pitch: Double(pitch)))

        XCTAssertEqual(cameraState.center.latitude, center.latitude)
        XCTAssertEqual(cameraState.center.longitude, center.longitude)
        XCTAssertEqual(cameraState.padding, padding.toUIEdgeInsetsValue())
        XCTAssertEqual(cameraState.zoom, zoom)
        XCTAssertEqual(cameraState.bearing, bearing)
        XCTAssertEqual(cameraState.pitch, pitch)
    }

    func testEquatable() {
        let cameraState = CameraState(
            MapboxCoreMaps.CameraState(
                center: center,
                padding: padding,
                zoom: Double(zoom),
                bearing: bearing,
                pitch: Double(pitch)))

        XCTAssertEqual(cameraState, cameraState)

        var other = CameraState(
            MapboxCoreMaps.CameraState(
                center: CLLocationCoordinate2D(latitude: center.latitude + 1, longitude: center.longitude),
                padding: padding,
                zoom: Double(zoom),
                bearing: bearing,
                pitch: Double(pitch)))
        XCTAssertNotEqual(cameraState, other)

        other = CameraState(
            MapboxCoreMaps.CameraState(
                center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude + 1),
                padding: padding,
                zoom: Double(zoom),
                bearing: bearing,
                pitch: Double(pitch)))
        XCTAssertNotEqual(cameraState, other)

        other = CameraState(
            MapboxCoreMaps.CameraState(
                center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude),
                padding: .init(top: padding.top + 1, left: padding.left, bottom: padding.bottom, right: padding.right),
                zoom: Double(zoom),
                bearing: bearing,
                pitch: Double(pitch)))
        XCTAssertNotEqual(cameraState, other)

        other = CameraState(
            MapboxCoreMaps.CameraState(
                center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude),
                padding: .init(top: padding.top, left: padding.left + 1, bottom: padding.bottom, right: padding.right),
                zoom: Double(zoom),
                bearing: bearing,
                pitch: Double(pitch)))
        XCTAssertNotEqual(cameraState, other)

        other = CameraState(
            MapboxCoreMaps.CameraState(
                center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude),
                padding: .init(top: padding.top, left: padding.left, bottom: padding.bottom + 1, right: padding.right),
                zoom: Double(zoom),
                bearing: bearing,
                pitch: Double(pitch)))
        XCTAssertNotEqual(cameraState, other)

        other = CameraState(
            MapboxCoreMaps.CameraState(
                center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude),
                padding: .init(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right + 1),
                zoom: Double(zoom),
                bearing: bearing,
                pitch: Double(pitch)))
        XCTAssertNotEqual(cameraState, other)

        other = CameraState(
            MapboxCoreMaps.CameraState(
                center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude),
                padding: .init(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right),
                zoom: Double(zoom + 1),
                bearing: bearing,
                pitch: Double(pitch)))
        XCTAssertNotEqual(cameraState, other)

        other = CameraState(
            MapboxCoreMaps.CameraState(
                center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude),
                padding: .init(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right),
                zoom: Double(zoom),
                bearing: bearing + 1,
                pitch: Double(pitch)))
        XCTAssertNotEqual(cameraState, other)

        other = CameraState(
            MapboxCoreMaps.CameraState(
                center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude),
                padding: .init(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right),
                zoom: Double(zoom),
                bearing: bearing,
                pitch: Double(pitch + 1)))
        XCTAssertNotEqual(cameraState, other)
    }

    func testEquatabilityOfObjcCameraState() {

        var cameraStateObjc = MapboxCoreMaps.CameraState(
            center: center,
            padding: padding,
            zoom: Double(zoom),
            bearing: bearing,
            pitch: Double(pitch))

        var otherCameraStateObjc = MapboxCoreMaps.CameraState(
            center: center,
            padding: padding,
            zoom: Double(zoom),
            bearing: bearing,
            pitch: Double(pitch))

        XCTAssertEqual(cameraStateObjc, otherCameraStateObjc)

        cameraStateObjc = MapboxCoreMaps.CameraState(
            center: center,
            padding: padding,
            zoom: Double(zoom),
            bearing: bearing,
            pitch: Double(pitch))

        otherCameraStateObjc = MapboxCoreMaps.CameraState(
            center: center,
            padding: padding,
            zoom: Double(zoom + 1),
            bearing: bearing,
            pitch: Double(pitch))

        XCTAssertNotEqual(cameraStateObjc, otherCameraStateObjc)
    }
}
