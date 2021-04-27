import XCTest
@testable import MapboxMaps

final class FlyToAnimatorTests: XCTestCase {

    let initalCameraOptions = CameraOptions(
        center: CLLocationCoordinate2D(
            latitude: 42.3601,
            longitude: -71.0589),
        padding: .zero,
        zoom: 10,
        bearing: 10,
        pitch: 10)

    let finalCameraOptions = CameraOptions(
        center: CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194),
        padding: .zero,
        zoom: 10,
        bearing: 10,
        pitch: 10)

    let animationOwner = AnimationOwner.custom(id: "")
    let duration: TimeInterval = 10

    var flyToAnimator: FlyToCameraAnimator!
    weak var cameraAnimatorDelegate: CameraAnimatorDelegateMock!

    override func setUp() {
        super.setUp()
        cameraAnimatorDelegate = CameraAnimatorDelegateMock()
        flyToAnimator = FlyToCameraAnimator(
            inital: initalCameraOptions,
            final: finalCameraOptions,
            owner: .custom(id: ""),
            duration: duration,
            mapSize: CGSize(width: 500, height: 500),
            delegate: cameraAnimatorDelegate)
    }

    override func tearDown() {
        cameraAnimatorDelegate = nil
        flyToAnimator = nil
        super.tearDown()
    }

    func testInitializationWithValidOptions() {
        XCTAssertTrue(flyToAnimator.delegate === cameraAnimatorDelegate)
        XCTAssertEqual(flyToAnimator.owner, animationOwner)
        XCTAssertEqual(flyToAnimator.duration, duration)
        XCTAssertEqual(flyToAnimator.state, .inactive)
    }

    func testInitializationWithANegativeDurationReturnsNil() {
    }

    func testInitializationWithANilDurationSetsDurationToCalculatedValue() {
    }

    func testInitializationWithInvalidCameraOptionsReturnsNil() {
    }

    func testStartAnimationChangesStateToActive() {
        flyToAnimator.startAnimation()

        XCTAssertEqual(flyToAnimator.state, .active)
    }

    func testAnimationBlocksAreScheduledWhenAnimationIsComplete() {
    }

    func testAnimationBlocksAreScheduledWhenStopAnimationIsInvoked() {
    }

    func testStopAnimationChangesStateToStopped() {
    }

    func testCurrentCameraOptionsReturnsNilIfAnimationIsNotRunning() {
    }

    func testCurrentCameraOptionsReturnsInterpolatedValueIfAnimationIsRunning() {
    }

    func testCurrentCameraOptionsReturnsFinalCameraOptionsIfAnimationIsComplete() {
    }
}
