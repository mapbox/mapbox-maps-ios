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
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
    }

    func testUpdateWithAnimationsDisabled() {
        cameraAnimationsManager.animationsEnabled = false
        let animator = cameraAnimationsManager.makeAnimator(duration: 1, curve: .linear) { _ in }
        animator.startAnimation()

        cameraAnimationsManager.update()

        XCTAssertEqual(animator.state, .inactive)
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
    }

    func testCameraAnimatorDelegate() {
        let animator1 = MockCameraAnimator()
        let animator2 = MockCameraAnimator()

        // stopping before starting should have no effect
        cameraAnimationsManager.cameraAnimatorDidStopRunning(animator1)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 0)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 0)

        // start once
        cameraAnimationsManager.cameraAnimatorDidStartRunning(animator1)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 0)

        // start twice
        cameraAnimationsManager.cameraAnimatorDidStartRunning(animator1)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 0)

        // start a second
        cameraAnimationsManager.cameraAnimatorDidStartRunning(animator2)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 2)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 0)

        // end the first
        cameraAnimationsManager.cameraAnimatorDidStopRunning(animator1)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 2)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 1)

        // end the first again
        cameraAnimationsManager.cameraAnimatorDidStopRunning(animator1)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 2)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 1)

        // end the second
        cameraAnimationsManager.cameraAnimatorDidStopRunning(animator2)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 2)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 2)
    }
}
