import XCTest
@testable import MapboxMaps

final class PanZoomPinchBehaviorTests: BasePinchBehaviorTests {
    override func setUp() {
        super.setUp()
        behavior = PanZoomPinchBehavior(
            initialCameraState: initialCameraState,
            initialPinchMidpoint: initialPinchMidpoint,
            mapboxMap: mapboxMap)
    }

    func testUpdate() throws {
        let pinchMidpoint = CGPoint.random()
        let pinchScale = CGFloat.random(in: 0.1..<10)
        let dragCameraOptions = CameraOptions.random()
        mapboxMap.dragCameraOptionsStub.defaultReturnValue = dragCameraOptions

        behavior.update(pinchMidpoint: pinchMidpoint, pinchScale: pinchScale)

        // verify that setCamera is invoked 2 times
        guard mapboxMap.setCameraStub.invocations.count == 2 else {
            XCTFail("Did not receive the expected number of setCamera invocations.")
            return
        }

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
            mapboxMap.setCameraStub.invocations[0].parameters,
            dragCameraOptions)

        // verify that dragEnd is invoked once
        XCTAssertEqual(mapboxMap.dragEndStub.invocations.count, 1)

        // verify that setCamera is invoked a third time with the expected
        // anchor and zoom
        XCTAssertEqual(
            mapboxMap.setCameraStub.invocations[1].parameters.anchor,
            pinchMidpoint)
        let zoom = try XCTUnwrap(mapboxMap.setCameraStub.invocations[1].parameters.zoom)
        XCTAssertEqual(zoom, initialCameraState.zoom + log2(pinchScale))

        // verify that only one camera changed notification was emitted
        XCTAssertEqual(cameraChangedCount, 1)
    }
}
