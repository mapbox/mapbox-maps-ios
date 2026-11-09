import XCTest
@testable @_spi(Experimental) @_spi(Marshalling) import MapboxMaps

final class CameraStateTests: XCTestCase {
    var center: CLLocationCoordinate2D!
    var padding: UIEdgeInsets!
    var anchor: CGPoint!
    var zoom: CGFloat!
    var bearing: CLLocationDirection!
    var pitch: CGFloat!
    var verticalFov: CGFloat!

    override func setUp() {
        super.tearDown()
        center = .testConstantValue()
        padding = .testConstantValue()
        anchor = CGPoint(
            x: 23,
            y: 0)
        zoom = 12.3
        bearing = 360
        pitch = 45
        verticalFov = 48
    }

    override func tearDown() {
        pitch = nil
        bearing = nil
        zoom = nil
        anchor = nil
        padding = nil
        center = nil
        verticalFov = nil
        super.tearDown()
    }

    func testMemberwiseInit() {
        let cameraState = CameraState(
            center: center,
            padding: padding,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch,
            verticalFov: verticalFov)

        XCTAssertEqual(cameraState.center.latitude, center.latitude)
        XCTAssertEqual(cameraState.center.longitude, center.longitude)
        XCTAssertEqual(cameraState.padding, padding)
        XCTAssertEqual(cameraState.zoom, zoom)
        XCTAssertEqual(cameraState.bearing, bearing)
        XCTAssertEqual(cameraState.pitch, pitch)
        XCTAssertEqual(cameraState.verticalFov, verticalFov)
    }

    func testVerticalFovDefaultValue() {
        let cameraState = CameraState(
            center: center,
            padding: padding,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch)
        XCTAssertEqual(cameraState.verticalFov, 36.87)
    }

    func testInitWithObjCValue() {
        let cameraState = CameraState.Marshaller.toSwift(
            CoreCameraState(
                center: center,
                padding: padding.toMBXEdgeInsetsValue(),
                zoom: Double(zoom),
                bearing: bearing,
                pitch: Double(pitch),
                verticalFov: verticalFov,
                positionPoint: CoreCameraPositionPoint(x: 0.25, y: -0.5)))

        XCTAssertEqual(cameraState.center.latitude, center.latitude)
        XCTAssertEqual(cameraState.center.longitude, center.longitude)
        XCTAssertEqual(cameraState.padding, padding)
        XCTAssertEqual(cameraState.zoom, zoom)
        XCTAssertEqual(cameraState.bearing, bearing)
        XCTAssertEqual(cameraState.pitch, pitch)
        XCTAssertEqual(cameraState.verticalFov, verticalFov)
        XCTAssertEqual(cameraState.positionPoint, CameraPositionPoint(x: 0.25, y: -0.5))
    }

    func testPositionPointDefaultValue() {
        let cameraState = CameraState(
            center: center,
            padding: padding,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch,
            verticalFov: verticalFov)
        XCTAssertEqual(cameraState.positionPoint, CameraPositionPoint(x: 0, y: 0))
    }

    func testPositionPointObjCRoundTrip() {
        let cameraState = makeCameraStateWithPositionPoint()

        let objcCameraState: CoreCameraState = CameraState.Marshaller.toObjc(cameraState)
        XCTAssertEqual(objcCameraState.positionPoint.x, -0.75)
        XCTAssertEqual(objcCameraState.positionPoint.y, 0.5)
        XCTAssertEqual(CameraState.Marshaller.toSwift(objcCameraState), cameraState)
    }

    func testCodableRoundTrip() throws {
        let cameraState = makeCameraStateWithPositionPoint()

        let data = try JSONEncoder().encode(cameraState)
        XCTAssertEqual(try JSONDecoder().decode(CameraState.self, from: data), cameraState)
    }

    func testDecodingWithoutPositionPoint() throws {
        let data = try JSONEncoder().encode(makeCameraStateWithPositionPoint())
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        json.removeValue(forKey: "positionPointCodable")

        let decoded = try JSONDecoder().decode(
            CameraState.self, from: JSONSerialization.data(withJSONObject: json))
        XCTAssertEqual(decoded.positionPoint, CameraPositionPoint(x: 0, y: 0))
        XCTAssertEqual(decoded.zoom, zoom)
    }

    private func makeCameraStateWithPositionPoint() -> CameraState {
        CameraState(
            center: center,
            padding: padding,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch,
            verticalFov: verticalFov,
            positionPoint: CameraPositionPoint(x: -0.75, y: 0.5))
    }

    func testEquatable() {
        let cameraState = CameraState(
            center: center,
            padding: padding,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch,
            verticalFov: verticalFov)

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

        other = cameraState
        other.verticalFov += 1
        XCTAssertNotEqual(cameraState, other)

        other = cameraState
        other.positionPoint.x += 0.5
        XCTAssertNotEqual(cameraState, other)

    }
}
