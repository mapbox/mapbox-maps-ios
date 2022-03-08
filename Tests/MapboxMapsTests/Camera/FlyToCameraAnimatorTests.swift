import XCTest
@testable import MapboxMaps

final class FlyToCameraAnimatorTests: XCTestCase {

    internal let initialCameraState = CameraState(
        MapboxCoreMaps.CameraState(
            center: .init(
                latitude: 42.3601,
                longitude: -71.0589),
            padding: .init(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0),
            zoom: 10,
            bearing: 10,
            pitch: 10))

    let finalCameraOptions = CameraOptions(
        center: CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194),
        padding: .zero,
        zoom: 10,
        bearing: 10,
        pitch: 10)

    let duration: TimeInterval = 10
    var owner: AnimationOwner!
    var mapboxMap: MockMapboxMap!
    var dateProvider: MockDateProvider!
    var flyToCameraAnimator: FlyToCameraAnimator!
    // swiftlint:disable:next weak_delegate
    var delegate: MockCameraAnimatorDelegate!

    override func setUp() {
        super.setUp()
        owner = .random()
        mapboxMap = MockMapboxMap()
        dateProvider = MockDateProvider()
        flyToCameraAnimator = FlyToCameraAnimator(
            initial: initialCameraState,
            final: finalCameraOptions,
            cameraBounds: CameraBounds.default,
            owner: owner,
            duration: duration,
            mapSize: CGSize(width: 500, height: 500),
            mapboxMap: mapboxMap,
            dateProvider: dateProvider)
        delegate = MockCameraAnimatorDelegate()
        flyToCameraAnimator.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        flyToCameraAnimator = nil
        dateProvider = nil
        mapboxMap = nil
        owner = nil
        super.tearDown()
    }

    func testInitializationWithValidOptions() {
        XCTAssertEqual(flyToCameraAnimator.owner, owner)
        XCTAssertEqual(flyToCameraAnimator.duration, duration)
        XCTAssertEqual(flyToCameraAnimator.state, .inactive)
    }

    func testInitializationWithANilDurationSetsDurationToCalculatedValue() {
        let animator = FlyToCameraAnimator(
            initial: initialCameraState,
            final: finalCameraOptions,
            cameraBounds: CameraBounds.default,
            owner: AnimationOwner(rawValue: "fly-to"),
            duration: nil,
            mapSize: CGSize(width: 500, height: 500),
            mapboxMap: mapboxMap,
            dateProvider: dateProvider)
        XCTAssertNotNil(animator.duration)
    }

    func testStartAnimationChangesStateToActiveAndInformsDelegate() {
        flyToCameraAnimator.startAnimation()

        XCTAssertEqual(flyToCameraAnimator.state, .active)
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.invocations.first?.parameters === flyToCameraAnimator)
    }

    func testAnimationCompletion() {
        var animatingPositions = [UIViewAnimatingPosition]()
        flyToCameraAnimator.addCompletion { (position) in
            animatingPositions.append(position)
        }
        flyToCameraAnimator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 20)

        flyToCameraAnimator.update()

        XCTAssertEqual(flyToCameraAnimator.state, .inactive)
        XCTAssertEqual(animatingPositions, [.end])
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.invocations.first?.parameters === flyToCameraAnimator)
    }

    func testStopAnimation() {
        var animatingPositions = [UIViewAnimatingPosition]()
        flyToCameraAnimator.addCompletion { (position) in
            animatingPositions.append(position)
        }
        flyToCameraAnimator.startAnimation()

        flyToCameraAnimator.stopAnimation()

        XCTAssertEqual(animatingPositions, [.current])
        XCTAssertEqual(flyToCameraAnimator.state, .inactive)
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.invocations.first?.parameters === flyToCameraAnimator)
    }

    func testUpdateDoesNotSetCameraIfAnimationIsNotRunning() {
        XCTAssertEqual(flyToCameraAnimator.state, .inactive)

        flyToCameraAnimator.update()

        XCTAssertTrue(mapboxMap.setCameraStub.invocations.isEmpty)
    }

    func testUpdateSetsCameraIfAnimationIsRunning() {
        flyToCameraAnimator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 5)

        flyToCameraAnimator.update()

        XCTAssertFalse(mapboxMap.setCameraStub.invocations.isEmpty)
    }
}
