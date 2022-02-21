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

        behavior.update(
            pinchMidpoint: .random(),
            pinchScale: pinchScale,
            pinchAngle: .random(in: 0..<2 * .pi))

        XCTAssertEqual(
            mapboxMap.setCameraStub.invocations.map(\.parameters),
            [CameraOptions(
                anchor: initialPinchMidpoint,
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

        behavior.update(pinchMidpoint: .random(),
                        pinchScale: .random(in: 1...10),
                        pinchAngle: .random(in: 0..<2 * .pi))

        XCTAssertEqual(mapboxMap.setCameraStub.invocations[0].parameters.anchor, focalPoint)
    }
}
