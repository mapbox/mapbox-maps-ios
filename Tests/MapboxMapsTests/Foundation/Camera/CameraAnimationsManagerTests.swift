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
}
