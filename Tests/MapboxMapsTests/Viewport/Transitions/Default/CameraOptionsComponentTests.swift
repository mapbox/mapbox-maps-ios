@testable import MapboxMaps
import XCTest

final class CameraOptionsComponentTests: XCTestCase {
    func testCameraOptionsForCenter() {
        let value = CLLocationCoordinate2D.testConstantValue()
        let component = CameraOptionsComponent(keyPath: \.center, value: value)

        XCTAssertEqual(component.cameraOptions, CameraOptions(center: value))
    }

    func testCameraOptionsForPadding() {
        let value = UIEdgeInsets.testConstantValue()
        let component = CameraOptionsComponent(keyPath: \.padding, value: value)

        XCTAssertEqual(component.cameraOptions, CameraOptions(padding: value))
    }

    func testCameraOptionsForAnchor() {
        let value = CGPoint.testConstantValue()
        let component = CameraOptionsComponent(keyPath: \.anchor, value: value)

        XCTAssertEqual(component.cameraOptions, CameraOptions(anchor: value))
    }

    func testCameraOptionsForZoom() {
        let value = 12.4
        let component = CameraOptionsComponent(keyPath: \.zoom, value: value)

        XCTAssertEqual(component.cameraOptions, CameraOptions(zoom: value))
    }

    func testCameraOptionsForBearing() {
        let value = 178.3
        let component = CameraOptionsComponent(keyPath: \.bearing, value: value)

        XCTAssertEqual(component.cameraOptions, CameraOptions(bearing: value))
    }

    func testCameraOptionsForPitch() {
        let value = 78.3
        let component = CameraOptionsComponent(keyPath: \.pitch, value: value)

        XCTAssertEqual(component.cameraOptions, CameraOptions(pitch: value))
    }

    func testUpdatedForCenterNonNil() throws {
        let component = CameraOptionsComponent(keyPath: \.center, value: .testConstantValue())
        let cameraOptions = CameraOptions.testConstantValue()

        let updatedComponent = try XCTUnwrap(
            component.updated(with: cameraOptions) as? CameraOptionsComponent<CLLocationCoordinate2D>)

        XCTAssertEqual(updatedComponent.keyPath, component.keyPath)
        XCTAssertEqual(updatedComponent.value, cameraOptions.center)
    }

    func testUpdatedForCenterNil() {
        let component = CameraOptionsComponent(keyPath: \.center, value: .testConstantValue())
        var cameraOptions = CameraOptions.testConstantValue()
        cameraOptions.center = nil

        XCTAssertNil(component.updated(with: cameraOptions))
    }

    func testUpdatedForPaddingNonNil() throws {
        let component = CameraOptionsComponent(keyPath: \.padding, value: .testConstantValue())
        let cameraOptions = CameraOptions.testConstantValue()

        let updatedComponent = try XCTUnwrap(
            component.updated(with: cameraOptions) as? CameraOptionsComponent<UIEdgeInsets>)

        XCTAssertEqual(updatedComponent.keyPath, component.keyPath)
        XCTAssertEqual(updatedComponent.value, cameraOptions.padding)
    }

    func testUpdatedForPaddingNil() {
        let component = CameraOptionsComponent(keyPath: \.padding, value: .testConstantValue())
        var cameraOptions = CameraOptions.testConstantValue()
        cameraOptions.padding = nil

        XCTAssertNil(component.updated(with: cameraOptions))
    }

    func testUpdatedForAnchorNonNil() throws {
        let component = CameraOptionsComponent(keyPath: \.anchor, value: .testConstantValue())
        let cameraOptions = CameraOptions.testConstantValue()

        let updatedComponent = try XCTUnwrap(
            component.updated(with: cameraOptions) as? CameraOptionsComponent<CGPoint>)

        XCTAssertEqual(updatedComponent.keyPath, component.keyPath)
        XCTAssertEqual(updatedComponent.value, cameraOptions.anchor)
    }

    func testUpdatedForAnchorNil() {
        let component = CameraOptionsComponent(keyPath: \.anchor, value: .testConstantValue())
        var cameraOptions = CameraOptions.testConstantValue()
        cameraOptions.anchor = nil

        XCTAssertNil(component.updated(with: cameraOptions))
    }

    func testUpdatedForZoomNonNil() throws {
        let component = CameraOptionsComponent(keyPath: \.zoom, value: 12.3)
        let cameraOptions = CameraOptions.testConstantValue()

        let updatedComponent = try XCTUnwrap(
            component.updated(with: cameraOptions) as? CameraOptionsComponent<CGFloat>)

        XCTAssertEqual(updatedComponent.keyPath, component.keyPath)
        XCTAssertEqual(updatedComponent.value, cameraOptions.zoom)
    }

    func testUpdatedForZoomNil() {
        let component = CameraOptionsComponent(keyPath: \.zoom, value: 1.2)
        var cameraOptions = CameraOptions.testConstantValue()
        cameraOptions.zoom = nil

        XCTAssertNil(component.updated(with: cameraOptions))
    }

    func testUpdatedForBearingNonNil() throws {
        let component = CameraOptionsComponent(keyPath: \.bearing, value: 0)
        let cameraOptions = CameraOptions.testConstantValue()

        let updatedComponent = try XCTUnwrap(
            component.updated(with: cameraOptions) as? CameraOptionsComponent<CLLocationDirection>)

        XCTAssertEqual(updatedComponent.keyPath, component.keyPath)
        XCTAssertEqual(updatedComponent.value, cameraOptions.bearing)
    }

    func testUpdatedForBearingNil() {
        let component = CameraOptionsComponent(keyPath: \.bearing, value: 143)
        var cameraOptions = CameraOptions.testConstantValue()
        cameraOptions.bearing = nil

        XCTAssertNil(component.updated(with: cameraOptions))
    }

    func testUpdatedForPitchNonNil() throws {
        let component = CameraOptionsComponent(keyPath: \.pitch, value: 56.4)
        let cameraOptions = CameraOptions.testConstantValue()

        let updatedComponent = try XCTUnwrap(
            component.updated(with: cameraOptions) as? CameraOptionsComponent<CGFloat>)

        XCTAssertEqual(updatedComponent.keyPath, component.keyPath)
        XCTAssertEqual(updatedComponent.value, cameraOptions.pitch)
    }

    func testUpdatedForPitchNil() {
        let component = CameraOptionsComponent(keyPath: \.pitch, value: 23.4)
        var cameraOptions = CameraOptions.testConstantValue()
        cameraOptions.pitch = nil

        XCTAssertNil(component.updated(with: cameraOptions))
    }
}
