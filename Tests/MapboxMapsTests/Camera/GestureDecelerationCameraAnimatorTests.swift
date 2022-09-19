import XCTest
@testable import MapboxMaps

final class GestureDecelerationCameraAnimatorTests: XCTestCase {

    var location: CGPoint!
    var velocity: CGPoint!
    var decelerationFactor: CGFloat!
    var owner: AnimationOwner!
    var locationChangeHandler: MockLocationChangeHandler!
    var mainQueue: MockMainQueue!
    var dateProvider: MockDateProvider!
    var animator: GestureDecelerationCameraAnimator!
    // swiftlint:disable:next weak_delegate
    var delegate: MockCameraAnimatorDelegate!
    var completion: Stub<UIViewAnimatingPosition, Void>!

    override func setUp() {
        super.setUp()
        location = .zero
        velocity = CGPoint(x: 2000, y: -2000)
        decelerationFactor = 0.7
        owner = .random()
        locationChangeHandler = MockLocationChangeHandler()
        mainQueue = MockMainQueue()
        dateProvider = MockDateProvider()
        animator = GestureDecelerationCameraAnimator(
            location: location,
            velocity: velocity,
            decelerationFactor: decelerationFactor,
            owner: owner,
            locationChangeHandler: locationChangeHandler.call(withFromLocation:toLocation:),
            mainQueue: mainQueue,
            dateProvider: dateProvider)
        delegate = MockCameraAnimatorDelegate()
        animator.delegate = delegate
        completion = Stub()
        animator.addCompletion(completion.call(with:))
    }

    override func tearDown() {
        completion = nil
        delegate = nil
        animator = nil
        dateProvider = nil
        mainQueue = nil
        locationChangeHandler = nil
        owner = nil
        decelerationFactor = nil
        velocity = nil
        location = nil
        super.tearDown()
    }

    func testStateIsInitiallyInactive() {
        XCTAssertEqual(animator.state, .inactive)
    }

    func testStartAnimation() {
        animator.startAnimation()

        XCTAssertEqual(animator.state, .active)
        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.invocations.first?.parameters === animator)
    }

    func testStartAnimationWhenAlreadyRunning() {
        animator.startAnimation()
        delegate.cameraAnimatorDidStartRunningStub.reset()

        animator.startAnimation()

        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 0)
    }

    func testStartAnimationWhenAlreadyComplete() {
        animator.stopAnimation()

        animator.startAnimation()

        XCTAssertEqual(delegate.cameraAnimatorDidStartRunningStub.invocations.count, 0)
    }

    func testStopAnimation() {
        animator.startAnimation()

        animator.stopAnimation()

        XCTAssertEqual(animator.state, .inactive)
        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStopRunningStub.invocations.first?.parameters === animator)
    }

    func testStopAnimationWithoutStarting() {
        animator.stopAnimation()

        XCTAssertEqual(animator.state, .inactive)
        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 0)
    }

    func testStopAnimationWhenAlreadyComplete() {
        animator.stopAnimation()
        completion.reset()

        animator.stopAnimation()

        XCTAssertEqual(animator.state, .inactive)
        XCTAssertEqual(completion.invocations.count, 0)
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 0)
    }

    func testUpdate() {
        animator.startAnimation()

        // Simulate advancing by 10 ms
        dateProvider.nowStub.defaultReturnValue += 0.01
        animator.update()

        // Expected value is duration * velocity;
        XCTAssertEqual(locationChangeHandler.invocations.map(\.parameters), [.init(fromLocation: location, toLocation: CGPoint(x: 20, y: -20))])
        // The previous update() should also have reduced the velocity
        // by multiplying it by the decelerationFactor once for each elapsed
        // millisecond. In this simulateion, 10 ms have elapsed.
        let expectedVelocityAdjustmentFactor = pow(decelerationFactor, 10)
        locationChangeHandler.reset()
        // Make sure the animation didn't end yet
        XCTAssertEqual(animator.state, .active)
        XCTAssertEqual(completion.invocations.count, 0)

        // This time, advance by 20 ms to keep it distinct
        // from the first update() call.
        dateProvider.nowStub.defaultReturnValue += 0.02
        animator.update()

        // The expected value this time is the previous location + the reduced
        // velocity (velocity * expectedVelocityAdjustmentFactor) times the elapsed duration
        XCTAssertEqual(locationChangeHandler.invocations.count, 1)
        XCTAssertEqual(locationChangeHandler.invocations[0].parameters.fromLocation, location)
        XCTAssertEqual(locationChangeHandler.invocations[0].parameters.toLocation.x,
                       (velocity.x * expectedVelocityAdjustmentFactor) * 0.02,
                       accuracy: 0.0000000001)
        XCTAssertEqual(locationChangeHandler.invocations[0].parameters.toLocation.y,
                       (velocity.y * expectedVelocityAdjustmentFactor) * 0.02,
                       accuracy: 0.0000000001)
        locationChangeHandler.reset()
        // After the previous update() call, the velocity should have also been reduced
        // to be sufficiently low (< 35 in both x and y) to end the animation.
        XCTAssertEqual(animator.state, .inactive)
        XCTAssertEqual(completion.invocations.map(\.parameters), [.end])
        XCTAssertEqual(delegate.cameraAnimatorDidStopRunningStub.invocations.count, 1)
        XCTAssertTrue(delegate.cameraAnimatorDidStopRunningStub.invocations.first?.parameters === animator)
    }

    func testAddCompletionToRunningAnimator() {
        animator.startAnimation()

        let completion = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completion.call(with:))

        animator.stopAnimation()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
    }

    func testAddCompletionToCanceledAnimator() throws {
        animator.startAnimation()
        animator.stopAnimation()

        let completion = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completion.call(with:))

        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 1)
        let closure = try XCTUnwrap(mainQueue.asyncClosureStub.invocations.first?.parameters.work)

        closure()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.current])
    }

    func testAddCompletionToCompletedAnimator() throws {
        animator.startAnimation()
        dateProvider.nowStub.defaultReturnValue += 1
        animator.update()

        let completion = Stub<UIViewAnimatingPosition, Void>()
        animator.addCompletion(completion.call(with:))

        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 1)
        let closure = try XCTUnwrap(mainQueue.asyncClosureStub.invocations.first?.parameters.work)

        closure()

        XCTAssertEqual(completion.invocations.map(\.parameters), [.end])
    }
}
