import XCTest
@testable import MapboxMaps

final class PinchBehaviorProviderTests: XCTestCase {
    func testPinchChangedBehaviorType() {
        let provider = PinchBehaviorProvider(mapboxMap: MockMapboxMap())

        XCTAssertTrue(
            provider.makePinchBehavior(
                panEnabled: true,
                zoomEnabled: true,
                rotateEnabled: true,
                initialCameraState: .random(),
                initialPinchMidpoint: .random(),
                initialPinchAngle: .random(in: 0..<2 * .pi))
            is PanZoomRotatePinchBehavior)
        XCTAssertTrue(
            provider.makePinchBehavior(
                panEnabled: true,
                zoomEnabled: true,
                rotateEnabled: false,
                initialCameraState: .random(),
                initialPinchMidpoint: .random(),
                initialPinchAngle: .random(in: 0..<2 * .pi))
            is PanZoomPinchBehavior)
        XCTAssertTrue(
            provider.makePinchBehavior(
                panEnabled: true,
                zoomEnabled: false,
                rotateEnabled: true,
                initialCameraState: .random(),
                initialPinchMidpoint: .random(),
                initialPinchAngle: .random(in: 0..<2 * .pi))
            is PanRotatePinchBehavior)
        XCTAssertTrue(
            provider.makePinchBehavior(
                panEnabled: true,
                zoomEnabled: false,
                rotateEnabled: false,
                initialCameraState: .random(),
                initialPinchMidpoint: .random(),
                initialPinchAngle: .random(in: 0..<2 * .pi))
            is PanPinchBehavior)
        XCTAssertTrue(
            provider.makePinchBehavior(
                panEnabled: false,
                zoomEnabled: true,
                rotateEnabled: true,
                initialCameraState: .random(),
                initialPinchMidpoint: .random(),
                initialPinchAngle: .random(in: 0..<2 * .pi))
            is ZoomRotatePinchBehavior)
        XCTAssertTrue(
            provider.makePinchBehavior(
                panEnabled: false,
                zoomEnabled: true,
                rotateEnabled: false,
                initialCameraState: .random(),
                initialPinchMidpoint: .random(),
                initialPinchAngle: .random(in: 0..<2 * .pi))
            is ZoomPinchBehavior)
        XCTAssertTrue(
            provider.makePinchBehavior(
                panEnabled: false,
                zoomEnabled: false,
                rotateEnabled: true,
                initialCameraState: .random(),
                initialPinchMidpoint: .random(),
                initialPinchAngle: .random(in: 0..<2 * .pi))
            is RotatePinchBehavior)
        XCTAssertTrue(
            provider.makePinchBehavior(
                panEnabled: false,
                zoomEnabled: false,
                rotateEnabled: false,
                initialCameraState: .random(),
                initialPinchMidpoint: .random(),
                initialPinchAngle: .random(in: 0..<2 * .pi))
            is EmptyPinchBehavior)
    }
}
