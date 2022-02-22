import XCTest
@testable import MapboxMaps

final class ZoomRotatePinchChangedBehaviorTests: BasePinchChangedBehaviorTests {
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

        assertMethodCall(mapboxMap.setCameraStub)

        let invocation = try XCTUnwrap(mapboxMap.setCameraStub.invocations.first)
        XCTAssertEqual(invocation.parameters.anchor, initialPinchMidpoint)
        XCTAssertEqual(invocation.parameters.zoom, initialCameraState.zoom + log2(pinchScale))
        let bearing = try XCTUnwrap(invocation.parameters.bearing)
        XCTAssertEqual(bearing, initialCameraState.bearing - 45, accuracy: 1e-10)
    }
}
