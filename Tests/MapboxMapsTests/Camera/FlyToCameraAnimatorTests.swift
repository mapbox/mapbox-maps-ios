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
    var mainQueue: MockMainQueue!
    var dateProvider: MockDateProvider!
    var flyToCameraAnimator: FlyToCameraAnimator!
    // swiftlint:disable:next weak_delegate
    var delegate: MockCameraAnimatorDelegate!

    override func setUp() {
        super.setUp()
        owner = .random()
        mapboxMap = MockMapboxMap()
        mapboxMap.cameraState = initialCameraState
        mapboxMap.cameraBounds = .default
        mapboxMap.size = CGSize(width: 500, height: 500)
        mainQueue = MockMainQueue()
        dateProvider = MockDateProvider()
        flyToCameraAnimator = FlyToCameraAnimator(
            toCamera: finalCameraOptions,
            owner: owner,
            duration: duration,
            mapboxMap: mapboxMap,
            mainQueue: mainQueue,
            dateProvider: dateProvider)
        delegate = MockCameraAnimatorDelegate()
        flyToCameraAnimator.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        flyToCameraAnimator = nil
        dateProvider = nil
        mainQueue = nil
        mapboxMap = nil
        owner = nil
        super.tearDown()
    }

    func testInitializationWithValidOptions() {
        XCTAssertEqual(flyToCameraAnimator.owner, owner)
        XCTAssertEqual(flyToCameraAnimator.duration, duration)
        XCTAssertEqual(flyToCameraAnimator.state, .inactive)
    }

    func testStartAnimationChangesStateToActiveAndInformsDelegate() {
        flyToCameraAnimator.startAnimation()

        XCTAssertEqual(flyToCameraAnimator.state, .active)
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.invocations.first?.parameters === flyToCameraAnimator)
    }

    func testStartAnimationMoreThanOnceHasNoEffect() {
        flyToCameraAnimator.startAnimation()
        delegate.cameraAnimatorDidStartRunningStub.reset()

        flyToCameraAnimator.startAnimation()

        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 0)
    }

    func testStartAnimationAfterCompletionHasNoEffect() {
        flyToCameraAnimator.stopAnimation()

        flyToCameraAnimator.startAnimation()

        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 0)
    }

    func testAnimationCompletion() {
        let completion = Stub<UIViewAnimatingPosition, Void>()
        flyToCameraAnimator.addCompletion(completion.call(with:))
        flyToCameraAnimator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 20)

        flyToCameraAnimator.update()

        XCTAssertEqual(flyToCameraAnimator.state, .inactive)
        XCTAssertEqual(completion.invocations.map(\.parameters), [.end])
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.invocations.first?.parameters === flyToCameraAnimator)
    }

    func testStopAnimation() {
        let completion = Stub<UIViewAnimatingPosition, Void>()
        flyToCameraAnimator.addCompletion(completion.call(with:))
        flyToCameraAnimator.startAnimation()

        flyToCameraAnimator.stopAnimation()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
        XCTAssertEqual(flyToCameraAnimator.state, .inactive)
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.invocations.first?.parameters === flyToCameraAnimator)
    }

    func testStopAnimationThatHasNotStarted() {
        let completion = Stub<UIViewAnimatingPosition, Void>()
        flyToCameraAnimator.addCompletion(completion.call(with:))

        flyToCameraAnimator.stopAnimation()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
        XCTAssertEqual(flyToCameraAnimator.state, .inactive)
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 0)
    }

    func testStopAnimationThatHasAlreadyCompleted() {
        let completion = Stub<UIViewAnimatingPosition, Void>()
        flyToCameraAnimator.addCompletion(completion.call(with:))
        flyToCameraAnimator.stopAnimation()
        completion.reset()

        flyToCameraAnimator.stopAnimation()

        XCTAssertEqual(completion.invocations.count, 0)
        XCTAssertEqual(flyToCameraAnimator.state, .inactive)
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 0)
    }

    func testAddCompletionToRunningAnimator() {
        flyToCameraAnimator.startAnimation()

        let completion = Stub<UIViewAnimatingPosition, Void>()
        flyToCameraAnimator.addCompletion(completion.call(with:))

        flyToCameraAnimator.stopAnimation()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
    }

    func testAddCompletionToCanceledAnimator() throws {
        flyToCameraAnimator.startAnimation()
        flyToCameraAnimator.stopAnimation()

        let completion = Stub<UIViewAnimatingPosition, Void>()
        flyToCameraAnimator.addCompletion(completion.call(with:))

        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 1)
        let closure = try XCTUnwrap(mainQueue.asyncClosureStub.invocations.first?.parameters.work)

        closure()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
    }

    func testAddCompletionToCompletedAnimator() throws {
        flyToCameraAnimator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 20)
        flyToCameraAnimator.update()

        let completion = Stub<UIViewAnimatingPosition, Void>()
        flyToCameraAnimator.addCompletion(completion.call(with:))

        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 1)
        let closure = try XCTUnwrap(mainQueue.asyncClosureStub.invocations.first?.parameters.work)

        closure()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.end])
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
