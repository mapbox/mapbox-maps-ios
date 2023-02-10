@testable import MapboxMaps
import XCTest

final class DefaultViewportTransitionAnimationSpecTests: XCTestCase {

    func testTotal() {
        let spec = DefaultViewportTransitionAnimationSpec(
            duration: .random(in: 0...100),
            delay: .random(in: 0...100),
            cameraOptionsComponent: MockCameraOptionsComponent())

        XCTAssertEqual(spec.total, spec.duration + spec.delay)
    }

    func testScaledBy() {
        let scaleFactor = Double.random(in: 0...10)

        let spec = DefaultViewportTransitionAnimationSpec(
            duration: .random(in: 0...100),
            delay: .random(in: 0...100),
            cameraOptionsComponent: MockCameraOptionsComponent())

        let scaledSpec = spec.scaled(by: scaleFactor)

        XCTAssertEqual(scaledSpec.duration, spec.duration * scaleFactor)
        XCTAssertEqual(scaledSpec.delay, spec.delay * scaleFactor)
    }
}
