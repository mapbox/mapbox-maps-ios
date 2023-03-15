import XCTest
@testable import MapboxMaps

final class PanPinchBehaviorTests: BasePinchBehaviorTests {
    override func setUp() {
        super.setUp()
        behavior = PanPinchBehavior(
            initialPinchMidpoint: initialPinchMidpoint,
            mapboxMap: mapboxMap)
    }

    func testUpdate() {
        let pinchMidpoint = CGPoint.random()
        let dragCameraOptions = CameraOptions.random()
        mapboxMap.dragCameraOptionsStub.defaultReturnValue = dragCameraOptions

        behavior.update(pinchMidpoint: pinchMidpoint, pinchScale: .random(in: 0..<2))

        // verify camera gets set once
        guard mapboxMap.setCameraStub.invocations.count == 1 else {
            XCTFail("Did not receive the expected number of setCamera invocations.")
            return
        }

        // verify that dragStart is called once with initial midpoint
        XCTAssertEqual(
            mapboxMap.dragStartStub.invocations.map(\.parameters),
            [initialPinchMidpoint])

        // verify that dragCameraOptions is invoked once with expected parameters
        XCTAssertEqual(
            mapboxMap.dragCameraOptionsStub.invocations.map(\.parameters),
            [.init(from: initialPinchMidpoint, to: pinchMidpoint)])

        // verify that setCamera is invoked a second time with the return value
        // from dragCameraOptions
        XCTAssertEqual(
            mapboxMap.setCameraStub.invocations[0].parameters,
            dragCameraOptions)

        // verify drag end is invoked once
        XCTAssertEqual(mapboxMap.dragEndStub.invocations.count, 1)

        // verify that only one camera changed notification was emitted
        XCTAssertEqual(cameraChangedCount, 1)
    }
}
