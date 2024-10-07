@testable import MapboxMaps
import XCTest

final class DefaultViewportTransitionAnimationSpecTests: XCTestCase {

    func testTotal() {
        let spec = DefaultViewportTransitionAnimationSpec(
            duration: 100,
            delay: 100,
            cameraOptionsComponent: MockCameraOptionsComponent())

        XCTAssertEqual(spec.total, spec.duration + spec.delay)
    }

    func testScaledBy() {
        let scaleFactor = Double.testConstantValue()

        let spec = DefaultViewportTransitionAnimationSpec(
            duration: 23,
            delay: 0,
            cameraOptionsComponent: MockCameraOptionsComponent())

        let scaledSpec = spec.scaled(by: scaleFactor)

        XCTAssertEqual(scaledSpec.duration, spec.duration * scaleFactor)
        XCTAssertEqual(scaledSpec.delay, spec.delay * scaleFactor)
    }
}
