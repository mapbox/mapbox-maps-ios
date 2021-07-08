import XCTest
@testable import MapboxMaps

internal let cameraOptionsTestValue = CameraOptions(
    center: CLLocationCoordinate2D(latitude: 10, longitude: 10),
    padding: .init(top: 10, left: 10, bottom: 10, right: 10),
    anchor: .init(x: 10.0, y: 10.0),
    zoom: 10,
    bearing: 10,
    pitch: 10)

internal let cameraStateTestValue = CameraState(
    MapboxCoreMaps.CameraState(
        center: .init(
            latitude: 10,
            longitude: 10),
        padding: .init(
            top: 10,
            left: 10,
            bottom: 10,
            right: 10),
        zoom: 10,
        bearing: 10,
        pitch: 10))

internal class BasicCameraAnimatorTests: XCTestCase {

    var propertyAnimator: UIViewPropertyAnimatorMock!
    var cameraView: CameraViewMock!
    var mapboxMap: MockBasicCameraAnimatorMapboxMap!
    var animator: BasicCameraAnimator!

    override func setUp() {
        super.setUp()
        propertyAnimator = UIViewPropertyAnimatorMock()
        cameraView = CameraViewMock()
        mapboxMap = MockBasicCameraAnimatorMapboxMap()
        animator = BasicCameraAnimator(
            propertyAnimator: propertyAnimator,
            owner: .unspecified,
            mapboxMap: mapboxMap,
            cameraView: cameraView)
    }

    override func tearDown() {
        animator = nil
        mapboxMap = nil
        cameraView = nil
        propertyAnimator = nil
        super.tearDown()
    }

    func testMarksCameraViewAsInUse() {
        XCTAssertTrue(cameraView.inUse)
    }

    func testDeinit() {
        animator = nil
        XCTAssertFalse(cameraView.inUse)
        XCTAssertEqual(propertyAnimator.stopAnimationStub.invocations.count, 0)
        XCTAssertEqual(propertyAnimator.finishAnimationStub.invocations.count, 0)
    }

    func testStartAndStopAnimation() {
        animator?.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }

        animator?.startAnimation()

        XCTAssertEqual(propertyAnimator.startAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.addAnimationsStub.invocations.count, 1)
        XCTAssertNotNil(animator?.transition)
        XCTAssertEqual(animator?.transition?.toCameraOptions.zoom, 10)

        animator?.stopAnimation()
        XCTAssertEqual(propertyAnimator.stopAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.finishAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.finishAnimationStub.invocations.first?.parameters.finalPosition, .current)

    }

    func testUpdate() {
        animator?.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
            transition.center.toValue = cameraOptionsTestValue.center!
            transition.bearing.toValue = cameraOptionsTestValue.bearing!
            transition.anchor.toValue = cameraOptionsTestValue.anchor!
            transition.pitch.toValue = cameraOptionsTestValue.pitch!
            transition.padding.toValue = cameraOptionsTestValue.padding!
        }
        animator?.startAnimation()
        propertyAnimator.shouldReturnState = .active

        animator.update()

        XCTAssertEqual(mapboxMap.setCameraStub.parameters, [cameraView.localCamera])
    }
}
