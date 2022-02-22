import XCTest
@testable import MapboxMaps

final class ZoomRotatePinchBehaviorTests: BasePinchBehaviorTests {
    override func setUp() {
        super.setUp()
        behavior = ZoomRotatePinchBehavior(
            initialCameraState: initialCameraState,
            initialPinchMidpoint: initialPinchMidpoint,
            initialPinchAngle: initialPinchAngle,
            mapboxMap: mapboxMap)
    }

    func testUpdate() throws {
        let pinchScale = CGFloat.random(in: 0.1..<10)

        behavior.update(
            pinchMidpoint: .random(),
            pinchScale: pinchScale,
            pinchAngle: initialPinchAngle + (.pi/4))

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)

        let invocation = try XCTUnwrap(mapboxMap.setCameraStub.invocations.first)
        XCTAssertEqual(invocation.parameters.anchor, initialPinchMidpoint)
        XCTAssertEqual(invocation.parameters.zoom, initialCameraState.zoom + log2(pinchScale))
        let bearing = try XCTUnwrap(invocation.parameters.bearing)
        XCTAssertEqual(bearing, initialCameraState.bearing - 45, accuracy: 1e-10)

        // verify that only one camera changed notification was emitted
        XCTAssertEqual(cameraChangedCount, 1)
    }
}
