import XCTest
@testable import MapboxMaps

final class RotatePinchBehaviorTests: BasePinchBehaviorTests {
    override func setUp() {
        super.setUp()
        behavior = RotatePinchBehavior(
            initialCameraState: initialCameraState,
            initialPinchMidpoint: initialPinchMidpoint,
            initialPinchAngle: initialPinchAngle,
            focalPoint: nil,
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

        // verify that only one camera changed notification was emitted
        XCTAssertEqual(cameraChangedCount, 1)
    }

    func testFocalPoint() {
        let focalPoint: CGPoint = .random()
        behavior = RotatePinchBehavior(
            initialCameraState: initialCameraState,
            initialPinchMidpoint: initialPinchMidpoint,
            initialPinchAngle: initialPinchAngle,
            focalPoint: focalPoint,
            mapboxMap: mapboxMap)

        behavior.update(pinchMidpoint: .random(),
                        pinchScale: .random(in: 1...10),
                        pinchAngle: .random(in: 0..<2 * .pi))

        XCTAssertEqual(mapboxMap.setCameraStub.invocations[0].parameters.anchor, focalPoint)
    }
}
