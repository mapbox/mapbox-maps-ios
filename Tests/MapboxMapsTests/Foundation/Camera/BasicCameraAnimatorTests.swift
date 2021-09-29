import XCTest
@testable import MapboxMaps

let cameraOptionsTestValue = CameraOptions(
    center: CLLocationCoordinate2D(latitude: 10, longitude: 10),
    padding: .init(top: 10, left: 10, bottom: 10, right: 10),
    anchor: .init(x: 10.0, y: 10.0),
    zoom: 10,
    bearing: 10,
    pitch: 10)

let cameraStateTestValue = CameraState(
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

final class BasicCameraAnimatorTests: XCTestCase {

    var propertyAnimator: MockPropertyAnimator!
    var cameraView: CameraViewMock!
    var mapboxMap: MockMapboxMap!
    var animator: BasicCameraAnimator!

    override func setUp() {
        super.setUp()
        propertyAnimator = MockPropertyAnimator()
        cameraView = CameraViewMock()
        mapboxMap = MockMapboxMap()
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

    func testDeinit() {
        animator = nil
        XCTAssertEqual(cameraView.removeFromSuperviewStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.stopAnimationStub.parameters, [true])
        XCTAssertTrue(propertyAnimator.finishAnimationStub.invocations.isEmpty)
    }

    func testIsReversed() {
        animator.isReversed = true

        XCTAssertEqual(propertyAnimator.setIsReversedStub.parameters, [true])

        animator.isReversed = false

        XCTAssertEqual(propertyAnimator.setIsReversedStub.parameters, [true, false])
    }

    func testStartAndStopAnimation() {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }

        animator.startAnimation()

        XCTAssertEqual(propertyAnimator.startAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.addAnimationsStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.addCompletionStub.invocations.count, 1)
        XCTAssertNotNil(animator?.transition)
        XCTAssertEqual(animator?.transition?.toCameraOptions.zoom, 10)

        animator.stopAnimation()
        XCTAssertEqual(propertyAnimator.stopAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.finishAnimationStub.invocations.count, 1)
        XCTAssertEqual(propertyAnimator.finishAnimationStub.invocations.first?.parameters, .current)
    }

    func testAnimatorCompletionUpdatesCameraIfAnimationCompletedAtEnd() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.parameters.first)

        completion(.end)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
    }

    func testAnimatorCompletionUpdatesCameraIfAnimationCompletedAtStart() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.parameters.first)

        completion(.start)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
    }

    func testAnimatorCompletionDoesNotUpdateCameraIfAnimationCompletedAtCurrent() throws {
        animator.addAnimations { (transition) in
            transition.zoom.toValue = cameraOptionsTestValue.zoom!
        }
        animator.startAnimation()
        let completion = try XCTUnwrap(propertyAnimator.addCompletionStub.parameters.first)

        completion(.current)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
    }
}
