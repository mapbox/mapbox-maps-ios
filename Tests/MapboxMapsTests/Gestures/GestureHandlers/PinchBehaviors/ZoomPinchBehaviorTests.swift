import XCTest
@testable import MapboxMaps

final class ZoomPinchBehaviorTests: BasePinchBehaviorTests {
    override func setUp() {
        super.setUp()
        behavior = ZoomPinchBehavior(
            initialCameraState: initialCameraState,
            initialPinchMidpoint: initialPinchMidpoint,
            focalPoint: nil,
            mapboxMap: mapboxMap)
    }

    func testUpdate() {
        let pinchScale = CGFloat.random(in: 0.1..<10)
        let pinchMidpoint = CGPoint.random()
        behavior.update(pinchMidpoint: pinchMidpoint, pinchScale: pinchScale)

        XCTAssertEqual(
            mapboxMap.setCameraStub.invocations.map(\.parameters),
            [CameraOptions(
                anchor: pinchMidpoint,
                zoom: initialCameraState.zoom + log2(pinchScale))])

        // verify that only one camera changed notification was emitted
        XCTAssertEqual(cameraChangedCount, 1)
    }

    func testFocalPoint() {
        let focalPoint: CGPoint = .random()
        behavior = ZoomPinchBehavior(
            initialCameraState: initialCameraState,
            initialPinchMidpoint: initialPinchMidpoint,
            focalPoint: focalPoint,
            mapboxMap: mapboxMap)

        behavior.update(pinchMidpoint: .random(), pinchScale: .random(in: 1...10))

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.first?.parameters.anchor, focalPoint)
    }
}
