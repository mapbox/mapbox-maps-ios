import XCTest
@testable import MapboxMaps

final class CameraOptionsTests: XCTestCase {
    var center: CLLocationCoordinate2D!
    var padding: UIEdgeInsets!
    var anchor: CGPoint!
    var zoom: CGFloat!
    var bearing: CLLocationDirection!
    var pitch: CGFloat!

    override func setUp() {
        super.tearDown()
        center = CLLocationCoordinate2D(
            latitude: .random(in: -80...80),
            longitude: .random(in: -180...180))
        padding = UIEdgeInsets(
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

    func testMemberwiseInitDefaults() {
        let cameraOptions = CameraOptions()

        XCTAssertNil(cameraOptions.center)
        XCTAssertNil(cameraOptions.padding)
        XCTAssertNil(cameraOptions.anchor)
        XCTAssertNil(cameraOptions.zoom)
        XCTAssertNil(cameraOptions.bearing)
        XCTAssertNil(cameraOptions.pitch)
    }

    func testMemberwiseInit() {
        let cameraOptions = CameraOptions(
            center: center,
            padding: padding,
            anchor: anchor,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch)

        XCTAssertEqual(cameraOptions.center?.latitude, center.latitude)
        XCTAssertEqual(cameraOptions.center?.longitude, center.longitude)
        XCTAssertEqual(cameraOptions.padding, padding)
        XCTAssertEqual(cameraOptions.anchor, anchor)
        XCTAssertEqual(cameraOptions.zoom, zoom)
        XCTAssertEqual(cameraOptions.bearing, bearing)
        XCTAssertEqual(cameraOptions.pitch, pitch)
    }

    func testInitWithObjCValue() {
        let objcCameraOptions = CoreCameraOptions(
            __center: Coordinate2D(value: center),
            padding: padding.toMBXEdgeInsetsValue(),
            anchor: anchor.screenCoordinate,
            zoom: zoom.NSNumber,
            bearing: bearing.NSNumber,
            pitch: pitch.NSNumber)

        let cameraOptions = CameraOptions(objcCameraOptions)

        XCTAssertEqual(cameraOptions.center?.latitude, center.latitude)
        XCTAssertEqual(cameraOptions.center?.longitude, center.longitude)
        XCTAssertEqual(cameraOptions.padding, padding)
        XCTAssertEqual(cameraOptions.anchor, anchor)
        XCTAssertEqual(cameraOptions.zoom, zoom)
        XCTAssertEqual(cameraOptions.bearing, bearing)
        XCTAssertEqual(cameraOptions.pitch, pitch)
    }

    func testInitWithObjCValueWithNils() {
        let objcCameraOptions = CoreCameraOptions(
            __center: nil,
            padding: nil,
            anchor: nil,
            zoom: nil,
            bearing: nil,
            pitch: nil)

        let cameraOptions = CameraOptions(objcCameraOptions)

        XCTAssertNil(cameraOptions.center)
        XCTAssertNil(cameraOptions.padding)
        XCTAssertNil(cameraOptions.anchor)
        XCTAssertNil(cameraOptions.zoom)
        XCTAssertNil(cameraOptions.bearing)
        XCTAssertNil(cameraOptions.pitch)
    }

    func testEquatable() {
        let cameraOptions = CameraOptions(
            center: center,
            padding: padding,
            anchor: anchor,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch)

        XCTAssertEqual(cameraOptions, cameraOptions)
        XCTAssertEqual(CameraOptions(), CameraOptions())

        var other = cameraOptions
        other.center?.latitude += 1
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.center?.longitude += 1
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.padding?.top += 1
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.padding?.left += 1
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.padding?.bottom += 1
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.padding?.right += 1
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.anchor?.x += 1
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.anchor?.y += 1
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.zoom? += 1
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.bearing? += 1
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.pitch? += 1
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.center = nil
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.padding = nil
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.anchor = nil
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.zoom = nil
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.bearing = nil
        XCTAssertNotEqual(cameraOptions, other)

        other = cameraOptions
        other.pitch = nil
        XCTAssertNotEqual(cameraOptions, other)
    }

    func testConversionToMapboxCoreMapsCameraOptions() {
        let cameraOptions = CameraOptions(
            center: center,
            padding: padding,
            anchor: anchor,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch)

        let objcCameraOptions = CoreCameraOptions(cameraOptions)

        XCTAssertEqual(objcCameraOptions.__center?.value.latitude, center.latitude)
        XCTAssertEqual(objcCameraOptions.__center?.value.longitude, center.longitude)
        XCTAssertEqual(objcCameraOptions.__padding, padding.toMBXEdgeInsetsValue())
        XCTAssertEqual(objcCameraOptions.__anchor, anchor.screenCoordinate)
        XCTAssertEqual(objcCameraOptions.__zoom, zoom.NSNumber)
        XCTAssertEqual(objcCameraOptions.__bearing, bearing.NSNumber)
        XCTAssertEqual(objcCameraOptions.__pitch, pitch.NSNumber)
    }

    func testConversionToMapboxCoreMapsCameraOptionsWithNils() {
        let cameraOptions = CameraOptions()

        let objcCameraOptions = CoreCameraOptions(cameraOptions)

        XCTAssertNil(objcCameraOptions.__center)
        XCTAssertNil(objcCameraOptions.__center)
        XCTAssertNil(objcCameraOptions.__padding)
        XCTAssertNil(objcCameraOptions.__anchor)
        XCTAssertNil(objcCameraOptions.__zoom)
        XCTAssertNil(objcCameraOptions.__bearing)
        XCTAssertNil(objcCameraOptions.__pitch)
    }
}
