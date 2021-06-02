import XCTest
@testable import MapboxMaps

final class FlyToAnimatorTests: XCTestCase {

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

    let animationOwner = AnimationOwner(rawValue: "fly-to")
    let duration: TimeInterval = 10

    var flyToAnimator: FlyToCameraAnimator!

    // swiftlint:disable weak_delegate
    var cameraAnimatorDelegate: CameraAnimatorDelegateMock!

    fileprivate var dateProvider: MockDateProvider!

    override func setUp() {
        super.setUp()
        cameraAnimatorDelegate = CameraAnimatorDelegateMock()
        dateProvider = MockDateProvider()
        flyToAnimator = FlyToCameraAnimator(
            initial: initialCameraState,
            final: finalCameraOptions,
            cameraBounds: CameraBounds.default,
            owner: AnimationOwner(rawValue: "fly-to"),
            duration: duration,
            mapSize: CGSize(width: 500, height: 500),
            delegate: cameraAnimatorDelegate,
            dateProvider: dateProvider)
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
        XCTAssertNil(
            FlyToCameraAnimator(
                initial: initialCameraState,
                final: finalCameraOptions,
                cameraBounds: CameraBounds.default,
                owner: AnimationOwner(rawValue: "fly-to"),
                duration: -1,
                mapSize: CGSize(width: 500, height: 500),
                delegate: cameraAnimatorDelegate)
        )
    }

    func testInitializationWithANilDurationSetsDurationToCalculatedValue() {
        let animator = FlyToCameraAnimator(
            initial: initialCameraState,
            final: finalCameraOptions,
            cameraBounds: CameraBounds.default,
            owner: AnimationOwner(rawValue: "fly-to"),
            duration: nil,
            mapSize: CGSize(width: 500, height: 500),
            delegate: cameraAnimatorDelegate)
        XCTAssertNotNil(animator?.duration)
    }

    func testStartAnimationChangesStateToActive() {
        flyToAnimator.startAnimation()
        XCTAssertEqual(flyToAnimator.state, .active)
    }

    func testAnimationBlocksAreScheduledWhenAnimationIsComplete() {
        flyToAnimator.addCompletion({ (_) in
            () // no-op
        })

        flyToAnimator.startAnimation()
        dateProvider.mockValue = Date(timeIntervalSinceReferenceDate: 20)

        let currentCameraOptions = flyToAnimator.currentCameraOptions
        XCTAssertEqual(currentCameraOptions, finalCameraOptions)
        XCTAssertEqual(flyToAnimator.state, .stopped)
        XCTAssertEqual(cameraAnimatorDelegate.schedulePendingCompletionStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimatorDelegate.schedulePendingCompletionStub.invocations.first?.parameters.animatingPosition, .end)

    }

    func testAnimationBlocksAreScheduledWhenStopAnimationIsInvoked() {

        flyToAnimator.addCompletion({ (_) in
            () // no-op
        })

        flyToAnimator.startAnimation()
        flyToAnimator.stopAnimation()

        XCTAssertEqual(cameraAnimatorDelegate.schedulePendingCompletionStub.invocations.count, 1)
        XCTAssertEqual(cameraAnimatorDelegate.schedulePendingCompletionStub.invocations.first?.parameters.animatingPosition, .current)

    }

    func testStopAnimationChangesStateToStopped() {
        flyToAnimator.startAnimation()
        flyToAnimator.stopAnimation()

        XCTAssertEqual(flyToAnimator.state, .stopped)
    }

    func testCurrentCameraOptionsReturnsNilIfAnimationIsNotRunning() {
        XCTAssertEqual(flyToAnimator.state, .inactive)
        XCTAssertNil(flyToAnimator.currentCameraOptions)
    }

    func testCurrentCameraOptionsReturnsInterpolatedValueIfAnimationIsRunning() {

        flyToAnimator.startAnimation()
        dateProvider.mockValue = Date(timeIntervalSinceReferenceDate: 5)

        let interpolatedCamera = flyToAnimator.currentCameraOptions
        XCTAssertNotNil(interpolatedCamera)
    }
}

private class MockDateProvider: DateProvider {

    var mockValue: Date

    var now: Date {
        return mockValue
    }

    init(mockValue: Date = Date(timeIntervalSinceReferenceDate: 0)) {
        self.mockValue = mockValue
    }
}
