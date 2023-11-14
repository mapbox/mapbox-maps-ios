import XCTest
@testable import MapboxMaps

final class CameraStateTests: XCTestCase {
    var center: CLLocationCoordinate2D!
    var padding: UIEdgeInsets!
    var anchor: CGPoint!
    var zoom: CGFloat!
    var bearing: CLLocationDirection!
    var pitch: CGFloat!

    override func setUp() {
        super.tearDown()
        center = .random()
        padding = .random()
        anchor = CGPoint(
            x: .random(in: 0...100),
            y: .random(in: 0...100))
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

    func testMemberwiseInit() {
        let cameraState = CameraState(
            center: center,
            padding: padding,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch)

        XCTAssertEqual(cameraState.center.latitude, center.latitude)
        XCTAssertEqual(cameraState.center.longitude, center.longitude)
        XCTAssertEqual(cameraState.padding, padding)
        XCTAssertEqual(cameraState.zoom, zoom)
        XCTAssertEqual(cameraState.bearing, bearing)
        XCTAssertEqual(cameraState.pitch, pitch)
    }

    func testInitWithObjCValue() {
        let cameraState = CameraState(
            CoreCameraState(
                center: center,
                padding: padding.toMBXEdgeInsetsValue(),
                zoom: Double(zoom),
                bearing: bearing,
                pitch: Double(pitch)))

        XCTAssertEqual(cameraState.center.latitude, center.latitude)
        XCTAssertEqual(cameraState.center.longitude, center.longitude)
        XCTAssertEqual(cameraState.padding, padding)
        XCTAssertEqual(cameraState.zoom, zoom)
        XCTAssertEqual(cameraState.bearing, bearing)
        XCTAssertEqual(cameraState.pitch, pitch)
    }

    func testEquatable() {
        let cameraState = CameraState(
            center: center,
            padding: padding,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch)

        XCTAssertEqual(cameraState, cameraState)

        var other = cameraState
        other.center.latitude += 1
        XCTAssertNotEqual(cameraState, other)

        other = cameraState
        other.center.longitude += 1
        XCTAssertNotEqual(cameraState, other)

        other = cameraState
        other.padding.top += 1
        XCTAssertNotEqual(cameraState, other)

        other = cameraState
        other.padding.left += 1
        XCTAssertNotEqual(cameraState, other)

        other = cameraState
        other.padding.bottom += 1
        XCTAssertNotEqual(cameraState, other)

        other = cameraState
        other.padding.right += 1
        XCTAssertNotEqual(cameraState, other)

        other = cameraState
        other.zoom += 1
        XCTAssertNotEqual(cameraState, other)

        other = cameraState
        other.bearing += 1
        XCTAssertNotEqual(cameraState, other)

        other = cameraState
        other.pitch += 1
        XCTAssertNotEqual(cameraState, other)
    }
}
