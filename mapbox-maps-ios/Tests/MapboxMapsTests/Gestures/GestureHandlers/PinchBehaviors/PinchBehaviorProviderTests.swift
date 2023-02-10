import XCTest
@testable import MapboxMaps

final class PinchBehaviorProviderTests: XCTestCase {
    func testPinchChangedBehaviorType() {
        let provider = PinchBehaviorProvider(mapboxMap: MockMapboxMap())

        XCTAssertTrue(
            provider.makePinchBehavior(
                panEnabled: true,
                zoomEnabled: true,
                initialCameraState: .random(),
                initialPinchMidpoint: .random(),
                focalPoint: .random(.random()))
            is PanZoomPinchBehavior)
        XCTAssertTrue(
            provider.makePinchBehavior(
                panEnabled: true,
                zoomEnabled: false,
                initialCameraState: .random(),
                initialPinchMidpoint: .random(),
                focalPoint: .random(.random()))
            is PanPinchBehavior)
        XCTAssertTrue(
            provider.makePinchBehavior(
                panEnabled: false,
                zoomEnabled: true,
                initialCameraState: .random(),
                initialPinchMidpoint: .random(),
                focalPoint: .random(.random()))
            is ZoomPinchBehavior)
        XCTAssertTrue(
            provider.makePinchBehavior(
                panEnabled: false,
                zoomEnabled: false,
                initialCameraState: .random(),
                initialPinchMidpoint: .random(),
                focalPoint: .random(.random()))
            is EmptyPinchBehavior)
    }
}
