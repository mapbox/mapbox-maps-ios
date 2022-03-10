import XCTest
@testable import MapboxMaps

final class BasicCameraAnimatorImplIntegrationTests: XCTestCase {

    var window: UIWindow!
    var cameraView: CameraView!
    var mapboxMap: MockMapboxMap!
    var animator: BasicCameraAnimatorImpl!
    // swiftlint:disable:next weak_delegate
    var delegate: MockBasicCameraAnimatorDelegate!

    override func setUp() {
        super.setUp()
        window = UIWindow()
        cameraView = CameraView()
        window.addSubview(cameraView)
        window.makeKeyAndVisible()
        mapboxMap = MockMapboxMap()
        animator = BasicCameraAnimatorImpl(
            propertyAnimator: UIViewPropertyAnimator(),
            owner: .unspecified,
            mapboxMap: mapboxMap,
            cameraView: cameraView)
        delegate = MockBasicCameraAnimatorDelegate()
        animator.delegate = delegate
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
        delegate = nil
        animator = nil
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

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.map(\.parameters), [cameraView.presentationCameraOptions])
    }
}
