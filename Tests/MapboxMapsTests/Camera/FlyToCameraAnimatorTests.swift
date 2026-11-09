import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class FlyToCameraAnimatorTests: XCTestCase {
    let initialCameraState = CameraState(
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
        pitch: 10,
        verticalFov: 10)

    let finalCameraOptions = CameraOptions(
        center: CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194),
        padding: .zero,
        zoom: 10,
        bearing: 10,
        pitch: 10,
    verticalFov: 35)

    let duration: TimeInterval = 10
    var curve = TimingCurve.easeInOut
    var owner: AnimationOwner!
    var mapboxMap: MockMapboxMap!
    var mainQueue: MockMainQueue!
    var dateProvider: MockDateProvider!
    var flyToCameraAnimator: FlyToCameraAnimator!

    var recordedCameraAnimatorStatus: [CameraAnimatorStatus] = []
    var cancelables: Set<AnyCancelable> = []

    override func setUp() {
        super.setUp()
        cancelables.removeAll(keepingCapacity: true)
        owner = .init(rawValue: UUID().uuidString)
        mapboxMap = MockMapboxMap()
        mapboxMap.cameraState = initialCameraState
        mapboxMap.cameraBounds = .default
        mapboxMap.size = CGSize(width: 500, height: 500)
        mainQueue = MockMainQueue()
        dateProvider = MockDateProvider()
        flyToCameraAnimator = FlyToCameraAnimator(
            toCamera: finalCameraOptions,
            duration: duration,
            curve: curve,
            owner: owner,
            mapboxMap: mapboxMap,
            mainQueue: mainQueue,
            dateProvider: dateProvider)
        flyToCameraAnimator.onCameraAnimatorStatusChanged.observe { [unowned self] status in
            self.recordedCameraAnimatorStatus.append(status)
        }.store(in: &cancelables)
    }

    override func tearDown() {
        flyToCameraAnimator = nil
        dateProvider = nil
        mainQueue = nil
        mapboxMap = nil
        owner = nil
        recordedCameraAnimatorStatus = []
        cancelables.removeAll()
        super.tearDown()
    }

    func testInitializationWithValidOptions() {
        XCTAssertEqual(flyToCameraAnimator.owner, owner)
        XCTAssertEqual(flyToCameraAnimator.duration, duration)
        XCTAssertEqual(flyToCameraAnimator.state, .inactive)
    }

    func testStartAnimationChangesStateToActiveAndChangeAnimatorStatus() {
        flyToCameraAnimator.startAnimation()

        XCTAssertEqual(flyToCameraAnimator.state, .active)
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started])
    }

    func testStartAnimationMoreThanOnceHasNoEffect() {
        flyToCameraAnimator.startAnimation()
        flyToCameraAnimator.startAnimation()

        XCTAssertEqual(recordedCameraAnimatorStatus, [.started])
    }

    func testStartAnimationAfterCompletionHasNoEffect() {
        flyToCameraAnimator.stopAnimation()
        flyToCameraAnimator.startAnimation()

        XCTAssertTrue(recordedCameraAnimatorStatus.isEmpty)
    }

    func testAnimationCompletion() {
        let completion = Stub<UIViewAnimatingPosition, Void>()
        flyToCameraAnimator.addCompletion(completion.call(with:))
        flyToCameraAnimator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 20)

        flyToCameraAnimator.update()

        XCTAssertEqual(flyToCameraAnimator.state, .inactive)
        XCTAssertEqual(completion.invocations.map(\.parameters), [.end])
    }

    func testStopAnimation() {
        let completion = Stub<UIViewAnimatingPosition, Void>()
        flyToCameraAnimator.addCompletion(completion.call(with:))
        flyToCameraAnimator.startAnimation()

        flyToCameraAnimator.stopAnimation()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
        XCTAssertEqual(flyToCameraAnimator.state, .inactive)
        XCTAssertEqual(recordedCameraAnimatorStatus, [.started, .stopped(reason: .cancelled)])
    }

    func testStopAnimationThatHasNotStarted() {
        let completion = Stub<UIViewAnimatingPosition, Void>()
        flyToCameraAnimator.addCompletion(completion.call(with:))

        flyToCameraAnimator.stopAnimation()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
        XCTAssertEqual(flyToCameraAnimator.state, .inactive)
        XCTAssertTrue(recordedCameraAnimatorStatus.isEmpty)
    }

    func testStopAnimationThatHasAlreadyCompleted() {
        let completion = Stub<UIViewAnimatingPosition, Void>()
        flyToCameraAnimator.addCompletion(completion.call(with:))
        flyToCameraAnimator.stopAnimation()
        completion.reset()

        flyToCameraAnimator.stopAnimation()

        XCTAssertEqual(completion.invocations.count, 0)
        XCTAssertEqual(flyToCameraAnimator.state, .inactive)
        XCTAssertTrue(recordedCameraAnimatorStatus.isEmpty)
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

    func testUpdateInterpolatesPositionPointAndKeepsItAfterStop() throws {
        makeAnimator(sourcePoint: CameraPositionPoint(x: -1, y: 0), destPoint: CameraPositionPoint(x: 1, y: 0.5))
        flyToCameraAnimator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 5)

        flyToCameraAnimator.update()
        flyToCameraAnimator.stopAnimation()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 1)
        let point = try XCTUnwrap(mapboxMap.setCameraStub.invocations.last?.parameters.positionPoint)
        XCTAssertGreaterThan(point.x, -1)
        XCTAssertLessThan(point.x, 1)
        XCTAssertGreaterThan(point.y, 0)
        XCTAssertLessThan(point.y, 0.5)
    }

    func testUpdateClampsOvershootingPositionPoint() throws {
        // control points beyond 1 make the eased fraction exceed 1 before the animation ends
        curve = TimingCurve(p1: CGPoint(x: 0.2, y: 2), p2: CGPoint(x: 0.8, y: 2))
        makeAnimator(sourcePoint: CameraPositionPoint(x: 0.5, y: -0.5), destPoint: CameraPositionPoint(x: 1, y: -1))
        flyToCameraAnimator.startAnimation()

        for seconds in stride(from: 1.0, to: 10.0, by: 1.0) {
            dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: seconds)
            flyToCameraAnimator.update()
        }

        let points = try mapboxMap.setCameraStub.invocations.map { try XCTUnwrap($0.parameters.positionPoint) }
        XCTAssertFalse(points.isEmpty)
        XCTAssertTrue(points.allSatisfy { (-1...1).contains($0.x) && (-1...1).contains($0.y) })
        XCTAssertTrue(points.contains { $0.x == 1 && $0.y == -1 })
    }

    func testUpdateDoesNotSetPositionPointWithoutDestination() {
        flyToCameraAnimator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 5)

        flyToCameraAnimator.update()

        XCTAssertNil(mapboxMap.setCameraStub.invocations.last?.parameters.positionPoint)
    }

    func testFinalCameraCarriesPositionPoint() {
        makeAnimator(sourcePoint: CameraPositionPoint(x: -1, y: 0), destPoint: CameraPositionPoint(x: 0.5, y: 0.5))
        flyToCameraAnimator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 20)

        flyToCameraAnimator.update()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.last?.parameters.positionPoint, CameraPositionPoint(x: 0.5, y: 0.5))
    }

    func testFinalCameraClampsOutOfRangePositionPoint() {
        makeAnimator(sourcePoint: CameraPositionPoint(x: 0, y: 0), destPoint: CameraPositionPoint(x: 2, y: -3))
        flyToCameraAnimator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 20)

        flyToCameraAnimator.update()

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.last?.parameters.positionPoint, CameraPositionPoint(x: 1, y: -1))
    }

    private func makeAnimator(sourcePoint: CameraPositionPoint, destPoint: CameraPositionPoint) {
        var state = initialCameraState
        state.positionPoint = sourcePoint
        mapboxMap.cameraState = state
        var finalOptions = finalCameraOptions
        finalOptions.positionPoint = destPoint
        flyToCameraAnimator = FlyToCameraAnimator(
            toCamera: finalOptions,
            duration: duration,
            curve: curve,
            owner: owner,
            mapboxMap: mapboxMap,
            mainQueue: mainQueue,
            dateProvider: dateProvider)
    }

    func testOnStarted() {
        var isStarted = false
        flyToCameraAnimator.onStarted.observe {
            isStarted = true
        }.store(in: &cancelables)

        flyToCameraAnimator.startAnimation()
        XCTAssertTrue(isStarted)
    }

    func testOnFinished() {
        var isFinished = false
        flyToCameraAnimator.onFinished.observe {
            isFinished = true
        }.store(in: &cancelables)
        flyToCameraAnimator.onCancelled.observe {
            XCTFail("animator is not cancelled")
        }.store(in: &cancelables)

        flyToCameraAnimator.startAnimation()
        dateProvider.nowStub.defaultReturnValue = Date(timeIntervalSinceReferenceDate: 20)
        flyToCameraAnimator.update()

        XCTAssertTrue(isFinished)
    }

    func testOnCancelled() {
        var isCancelled = false
        flyToCameraAnimator.onFinished.observe {
            XCTFail("animator is not finished")
        }.store(in: &cancelables)
        flyToCameraAnimator.onCancelled.observe {
            isCancelled = true
        }.store(in: &cancelables)

        flyToCameraAnimator.startAnimation()
        flyToCameraAnimator.stopAnimation()

        XCTAssertTrue(isCancelled)
    }
}
