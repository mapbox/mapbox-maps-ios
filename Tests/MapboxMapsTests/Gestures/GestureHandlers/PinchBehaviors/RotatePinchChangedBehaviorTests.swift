import XCTest
@testable import MapboxMaps

final class RotatePinchChangedBehaviorTests: BasePinchChangedBehaviorTests {
    override func setUp() {
        super.setUp()
        behavior = RotatePinchBehavior(
            initialCameraState: initialCameraState,
            initialPinchMidpoint: initialPinchMidpoint,
            initialPinchAngle: initialPinchAngle,
            mapboxMap: mapboxMap)
    }

    func testUpdate() throws {
        behavior.update(
            pinchMidpoint: .random(),
            pinchScale: .random(in: 0..<2),
            pinchAngle: initialPinchAngle + (.pi/4))

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
        let invocation = try XCTUnwrap(mapboxMap.setCameraStub.invocations.first)
        XCTAssertEqual(invocation.parameters.anchor, initialPinchMidpoint)
        let bearing = try XCTUnwrap(invocation.parameters.bearing)
        XCTAssertEqual(bearing, initialCameraState.bearing - 45, accuracy: 1e-10)
    }
}
