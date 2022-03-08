import XCTest
@testable import MapboxMaps

final class PanRotatePinchBehaviorTests: BasePinchBehaviorTests {
    override func setUp() {
        super.setUp()
        behavior = PanRotatePinchBehavior(
            initialCameraState: initialCameraState,
            initialPinchMidpoint: initialPinchMidpoint,
            initialPinchAngle: initialPinchAngle,
            mapboxMap: mapboxMap)
    }

    func testUpdate() throws {
        let pinchMidpoint = CGPoint.random()
        let dragCameraOptions = CameraOptions.random()
        mapboxMap.dragCameraOptionsStub.defaultReturnValue = dragCameraOptions

        behavior.update(
            pinchMidpoint: pinchMidpoint,
            pinchScale: .random(in: 0..<2),
            pinchAngle: initialPinchAngle + (.pi/4))

        // verify that setCamera is invoked 3 times
        guard mapboxMap.setCameraStub.invocations.count == 3 else {
            XCTFail("Did not receive the expected number of setCamera invocations.")
            return
        }

        // verify that the first setCamera invocation resets center and bearing
        XCTAssertEqual(
            mapboxMap.setCameraStub.invocations[0].parameters,
            CameraOptions(
                center: initialCameraState.center,
                bearing: initialCameraState.bearing))

        // verify that dragStart is invoked once with the initial pinch midpoint
        XCTAssertEqual(
            mapboxMap.dragStartStub.invocations.map(\.parameters),
            [initialPinchMidpoint])

        // verify that dragCameraOptions is invoked once with the expected
        // parameters
        XCTAssertEqual(
            mapboxMap.dragCameraOptionsStub.invocations.map(\.parameters),
            [.init(from: initialPinchMidpoint, to: pinchMidpoint)])

        // verify that setCamera is invoked a second time with the return value
        // from dragCameraOptions
        XCTAssertEqual(
            mapboxMap.setCameraStub.invocations[1].parameters,
            dragCameraOptions)

        // verify that dragEnd is invoked once
        XCTAssertEqual(mapboxMap.dragEndStub.invocations.count, 1)

        // verify that setCamera is invoked a third time with the expected
        // anchor and bearing
        XCTAssertEqual(
            mapboxMap.setCameraStub.invocations[2].parameters.anchor,
            pinchMidpoint)
        let bearing = try XCTUnwrap(mapboxMap.setCameraStub.invocations[2].parameters.bearing)
        XCTAssertEqual(bearing, initialCameraState.bearing - 45, accuracy: 1e-10)

        // verify that only one camera changed notification was emitted
        XCTAssertEqual(cameraChangedCount, 1)
    }
}
