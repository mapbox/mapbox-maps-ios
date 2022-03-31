@testable import MapboxMaps
import XCTest

final class CameraOptionsComponentTests: XCTestCase {
    func testCameraOptionsForCenter() {
        let value = CLLocationCoordinate2D.random()
        let component = CameraOptionsComponent(keyPath: \.center, value: value)

        XCTAssertEqual(component.cameraOptions, CameraOptions(center: value))
    }

    func testCameraOptionsForPadding() {
        let value = UIEdgeInsets.random()
        let component = CameraOptionsComponent(keyPath: \.padding, value: value)

        XCTAssertEqual(component.cameraOptions, CameraOptions(padding: value))
    }

    func testCameraOptionsForAnchor() {
        let value = CGPoint.random()
        let component = CameraOptionsComponent(keyPath: \.anchor, value: value)

        XCTAssertEqual(component.cameraOptions, CameraOptions(anchor: value))
    }

    func testCameraOptionsForZoom() {
        let value = CGFloat.random(in: 0...20)
        let component = CameraOptionsComponent(keyPath: \.zoom, value: value)

        XCTAssertEqual(component.cameraOptions, CameraOptions(zoom: value))
    }

    func testCameraOptionsForBearing() {
        let value = CLLocationDirection.random(in: 0..<360)
        let component = CameraOptionsComponent(keyPath: \.bearing, value: value)

        XCTAssertEqual(component.cameraOptions, CameraOptions(bearing: value))
    }

    func testCameraOptionsForPitch() {
        let value = CGFloat.random(in: 0...80)
        let component = CameraOptionsComponent(keyPath: \.pitch, value: value)

        XCTAssertEqual(component.cameraOptions, CameraOptions(pitch: value))
    }

    func testUpdatedForCenterNonNil() throws {
        let component = CameraOptionsComponent(keyPath: \.center, value: .random())
        let cameraOptions = CameraOptions.random()

        let updatedComponent = try XCTUnwrap(
            component.updated(with: cameraOptions) as? CameraOptionsComponent<CLLocationCoordinate2D>)

        XCTAssertEqual(updatedComponent.keyPath, component.keyPath)
        XCTAssertEqual(updatedComponent.value, cameraOptions.center)
    }

    func testUpdatedForCenterNil() {
        let component = CameraOptionsComponent(keyPath: \.center, value: .random())
        var cameraOptions = CameraOptions.random()
        cameraOptions.center = nil

        XCTAssertNil(component.updated(with: cameraOptions))
    }

    func testUpdatedForPaddingNonNil() throws {
        let component = CameraOptionsComponent(keyPath: \.padding, value: .random())
        let cameraOptions = CameraOptions.random()

        let updatedComponent = try XCTUnwrap(
            component.updated(with: cameraOptions) as? CameraOptionsComponent<UIEdgeInsets>)

        XCTAssertEqual(updatedComponent.keyPath, component.keyPath)
        XCTAssertEqual(updatedComponent.value, cameraOptions.padding)
    }

    func testUpdatedForPaddingNil() {
        let component = CameraOptionsComponent(keyPath: \.padding, value: .random())
        var cameraOptions = CameraOptions.random()
        cameraOptions.padding = nil

        XCTAssertNil(component.updated(with: cameraOptions))
    }

    func testUpdatedForAnchorNonNil() throws {
        let component = CameraOptionsComponent(keyPath: \.anchor, value: .random())
        let cameraOptions = CameraOptions.random()

        let updatedComponent = try XCTUnwrap(
            component.updated(with: cameraOptions) as? CameraOptionsComponent<CGPoint>)

        XCTAssertEqual(updatedComponent.keyPath, component.keyPath)
        XCTAssertEqual(updatedComponent.value, cameraOptions.anchor)
    }

    func testUpdatedForAnchorNil() {
        let component = CameraOptionsComponent(keyPath: \.anchor, value: .random())
        var cameraOptions = CameraOptions.random()
        cameraOptions.anchor = nil

        XCTAssertNil(component.updated(with: cameraOptions))
    }

    func testUpdatedForZoomNonNil() throws {
        let component = CameraOptionsComponent(keyPath: \.zoom, value: .random(in: 0...20))
        let cameraOptions = CameraOptions.random()

        let updatedComponent = try XCTUnwrap(
            component.updated(with: cameraOptions) as? CameraOptionsComponent<CGFloat>)

        XCTAssertEqual(updatedComponent.keyPath, component.keyPath)
        XCTAssertEqual(updatedComponent.value, cameraOptions.zoom)
    }

    func testUpdatedForZoomNil() {
        let component = CameraOptionsComponent(keyPath: \.zoom, value: .random(in: 0...20))
        var cameraOptions = CameraOptions.random()
        cameraOptions.zoom = nil

        XCTAssertNil(component.updated(with: cameraOptions))
    }

    func testUpdatedForBearingNonNil() throws {
        let component = CameraOptionsComponent(keyPath: \.bearing, value: .random(in: 0..<360))
        let cameraOptions = CameraOptions.random()

        let updatedComponent = try XCTUnwrap(
            component.updated(with: cameraOptions) as? CameraOptionsComponent<CLLocationDirection>)

        XCTAssertEqual(updatedComponent.keyPath, component.keyPath)
        XCTAssertEqual(updatedComponent.value, cameraOptions.bearing)
    }

    func testUpdatedForBearingNil() {
        let component = CameraOptionsComponent(keyPath: \.bearing, value: .random(in: 0..<360))
        var cameraOptions = CameraOptions.random()
        cameraOptions.bearing = nil

        XCTAssertNil(component.updated(with: cameraOptions))
    }

    func testUpdatedForPitchNonNil() throws {
        let component = CameraOptionsComponent(keyPath: \.pitch, value: .random(in: 0...80))
        let cameraOptions = CameraOptions.random()

        let updatedComponent = try XCTUnwrap(
            component.updated(with: cameraOptions) as? CameraOptionsComponent<CGFloat>)

        XCTAssertEqual(updatedComponent.keyPath, component.keyPath)
        XCTAssertEqual(updatedComponent.value, cameraOptions.pitch)
    }

    func testUpdatedForPitchNil() {
        let component = CameraOptionsComponent(keyPath: \.pitch, value: .random(in: 0...80))
        var cameraOptions = CameraOptions.random()
        cameraOptions.pitch = nil

        XCTAssertNil(component.updated(with: cameraOptions))
    }
}
