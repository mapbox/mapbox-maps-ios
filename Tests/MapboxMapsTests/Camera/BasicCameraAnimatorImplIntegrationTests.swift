import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class BasicCameraAnimatorImplIntegrationTests: XCTestCase {

    var window: UIWindow!
    var cameraView: CameraView!
    var mapboxMap: MockMapboxMap!
    var mainQueue: MockMainQueue!
    var animator: BasicCameraAnimatorImpl!

    override func setUp() {
        super.setUp()
        window = UIWindow.makeForTests()
        cameraView = CameraView()
        window.addSubview(cameraView)
        window.makeKeyAndVisible()
        mapboxMap = MockMapboxMap()
        mainQueue = MockMainQueue()
        animator = BasicCameraAnimatorImpl(
            propertyAnimator: UIViewPropertyAnimator(),
            owner: .unspecified,
            mapboxMap: mapboxMap,
            mainQueue: mainQueue,
            cameraView: cameraView) { (transition) in
                transition.zoom.toValue = cameraOptionsTestValue.zoom!
                transition.center.toValue = cameraOptionsTestValue.center!
                transition.bearing.toValue = cameraOptionsTestValue.bearing!
                transition.anchor.toValue = cameraOptionsTestValue.anchor!
                transition.pitch.toValue = cameraOptionsTestValue.pitch!
                transition.padding.toValue = cameraOptionsTestValue.padding!
                transition.verticalFov.toValue = cameraOptionsTestValue.verticalFov!
                transition.positionPoint.toValue = CGPoint(x: 0.5, y: -0.5)
            }
    }

    override func tearDown() {
        animator = nil
        mainQueue = nil
        mapboxMap = nil
        cameraView = nil
        window = nil
        super.tearDown()
    }

    func testUpdateBeforeAnimationsAreFlushed() {
        animator.startAnimation()

        animator.update()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
    }

    func testUpdateAfterAnimationsAreFlushed() {
        animator.startAnimation()
        CATransaction.flush()

        animator.update()

        // The view point is not part of this transition, so the animator must not write it.
        var expected = cameraView.presentationCameraOptions
        expected?.viewPoint = nil
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.map(\.parameters), [expected])
    }

    func testViewPointIsInterpolatedInPresentationLayer() throws {
        var state = cameraStateTestValue
        state.viewPoint = .viewPoint(CameraViewPoint(x: -0.5, y: 0.5))
        mapboxMap.cameraState = state
        mapboxMap.size = CGSize(width: 200, height: 200)
        let propertyAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear)
        animator = BasicCameraAnimatorImpl(
            propertyAnimator: propertyAnimator,
            owner: .unspecified,
            mapboxMap: mapboxMap,
            mainQueue: mainQueue,
            cameraView: cameraView) { (transition) in
                transition.viewPoint.toValue = .viewPoint(CameraViewPoint(x: 0.5, y: -0.5))
            }

        animator.pauseAnimation()
        propertyAnimator.fractionComplete = 0.5
        CATransaction.flush()

        guard case .viewPoint(let point) = try XCTUnwrap(cameraView.presentationCameraOptions?.viewPoint) else {
            return XCTFail("Expected a pinned view point")
        }
        XCTAssertEqual(point.x, 0, accuracy: 0.01)
        XCTAssertEqual(point.y, 0, accuracy: 0.01)
        propertyAnimator.stopAnimation(true)
    }
}
