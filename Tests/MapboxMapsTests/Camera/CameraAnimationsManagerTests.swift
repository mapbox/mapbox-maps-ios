import XCTest
@testable import MapboxMaps

final class CameraAnimationsManagerTests: XCTestCase {

    var window: UIWindow!
    var view: UIView!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: CameraAnimationsManager!

    override func setUp() {
        super.setUp()
        window = UIWindow()
        view = UIView()
        window.addSubview(view)
        window.makeKeyAndVisible()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = CameraAnimationsManager(
            cameraViewContainerView: view,
            mapboxMap: mapboxMap)
    }

    override func tearDown() {
        cameraAnimationsManager = nil
        mapboxMap = nil
        view = nil
        window.resignKey()
        window = nil
        super.tearDown()
    }

    func testUpdateWithAnimationsEnabled() {
        cameraAnimationsManager.animationsEnabled = true
        let animator = cameraAnimationsManager.makeAnimator(duration: 1, curve: .linear) { (transition) in
            transition.bearing.toValue = 180
        }
        animator.startAnimation()
        // flush animations to populate the underlying camera view's
        // presentation layer so that update() will run
        // also requires view to be in a window.
        CATransaction.flush()

        cameraAnimationsManager.update()

        XCTAssertEqual(animator.state, .active)
        assertMethodCall(mapboxMap.setCameraStub)
    }

    func testUpdateWithAnimationsDisabled() {
        cameraAnimationsManager.animationsEnabled = false
        let animator = cameraAnimationsManager.makeAnimator(duration: 1, curve: .linear) { _ in }
        animator.startAnimation()

        cameraAnimationsManager.update()

        XCTAssertEqual(animator.state, .inactive)
        assertMethodNotCall(mapboxMap.setCameraStub)
    }

    func testCameraAnimatorDelegate() {
        let animator1 = MockCameraAnimator()
        let animator2 = MockCameraAnimator()

        // stopping before starting should have no effect
        cameraAnimationsManager.cameraAnimatorDidStopRunning(animator1)
        assertMethodNotCall(mapboxMap.beginAnimationStub)
        assertMethodNotCall(mapboxMap.endAnimationStub)

        // start once
        cameraAnimationsManager.cameraAnimatorDidStartRunning(animator1)
        assertMethodCall(mapboxMap.beginAnimationStub)
        assertMethodNotCall(mapboxMap.endAnimationStub)

        // start twice
        cameraAnimationsManager.cameraAnimatorDidStartRunning(animator1)
        assertMethodCall(mapboxMap.beginAnimationStub)
        assertMethodNotCall(mapboxMap.endAnimationStub)

        // start a second
        cameraAnimationsManager.cameraAnimatorDidStartRunning(animator2)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 2)
        assertMethodNotCall(mapboxMap.endAnimationStub)

        // end the first
        cameraAnimationsManager.cameraAnimatorDidStopRunning(animator1)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 2)
        assertMethodCall(mapboxMap.endAnimationStub)

        // end the first again
        cameraAnimationsManager.cameraAnimatorDidStopRunning(animator1)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 2)
        assertMethodCall(mapboxMap.endAnimationStub)

        // end the second
        cameraAnimationsManager.cameraAnimatorDidStopRunning(animator2)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 2)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 2)
    }
}
