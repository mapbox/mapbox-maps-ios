import XCTest
@testable import MapboxMaps

final class BasicCameraAnimatorIntegrationTests: XCTestCase {

    var window: UIWindow!
    var cameraView: CameraView!
    var mapboxMap: MockMapboxMap!
    // swiftlint:disable:next weak_delegate
    var delegate: MockCameraAnimatorDelegate!
    var animator: BasicCameraAnimator!

    override func setUp() {
        super.setUp()
        window = UIWindow()
        cameraView = CameraView()
        window.addSubview(cameraView)
        window.makeKeyAndVisible()
        mapboxMap = MockMapboxMap()
        delegate = MockCameraAnimatorDelegate()
        animator = BasicCameraAnimator(
            propertyAnimator: UIViewPropertyAnimator(),
            owner: .unspecified,
            mapboxMap: mapboxMap,
            cameraView: cameraView,
            delegate: delegate)
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
            transition.center.toValue = cameraOptionsTestValue.center!
            transition.bearing.toValue = cameraOptionsTestValue.bearing!
            transition.anchor.toValue = cameraOptionsTestValue.anchor!
            transition.pitch.toValue = cameraOptionsTestValue.pitch!
            transition.padding.toValue = cameraOptionsTestValue.padding!
        }
    }

    override func tearDown() {
        animator = nil
        delegate = nil
        mapboxMap = nil
        cameraView = nil
        window = nil
        super.tearDown()
    }

    func testUpdateBeforeAnimationsAreFlushed() {
        animator.startAnimation()

        animator.update()

        XCTAssertEqual(mapboxMap.setCameraStub.parameters, [])
    }

    func testUpdateAfterAnimationsAreFlushed() {
        animator.startAnimation()
        CATransaction.flush()

        animator.update()

        XCTAssertEqual(mapboxMap.setCameraStub.parameters, [cameraView.presentationCameraOptions])
    }
}
