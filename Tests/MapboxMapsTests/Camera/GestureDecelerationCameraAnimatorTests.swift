import XCTest
@testable import MapboxMaps

final class GestureDecelerationCameraAnimatorTests: XCTestCase {

    var location: CGPoint!
    var velocity: CGPoint!
    var decelerationFactor: CGFloat!
    var locationChangeHandler: MockLocationChangeHandler!
    var dateProvider: MockDateProvider!
    // swiftlint:disable:next weak_delegate
    var delegate: MockCameraAnimatorDelegate!
    var animator: GestureDecelerationCameraAnimator!
    var completion: Stub<Void, Void>!

    override func setUp() {
        super.setUp()
        location = .zero
        velocity = CGPoint(x: 1000, y: -1000)
        decelerationFactor = 0.7
        locationChangeHandler = MockLocationChangeHandler()
        dateProvider = MockDateProvider()
        delegate = MockCameraAnimatorDelegate()
        animator = GestureDecelerationCameraAnimator(
            location: location,
            velocity: velocity,
            decelerationFactor: decelerationFactor,
            locationChangeHandler: locationChangeHandler.call(withFromLocation:toLocation:),
            dateProvider: dateProvider,
            delegate: delegate)
        completion = Stub()
        animator.completion = completion.call
    }

    override func tearDown() {
        completion = nil
        animator = nil
        delegate = nil
        dateProvider = nil
        locationChangeHandler = nil
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
        assertMethodCall(delegate.cameraAnimatorDidStartRunningStub)
        XCTAssertTrue(delegate.cameraAnimatorDidStartRunningStub.parameters.first === animator)
    }

    func testStopAnimation() {
        animator.startAnimation()

        animator.stopAnimation()

        XCTAssertEqual(animator.state, .inactive)
        assertMethodCall(completion)
        assertMethodCall(delegate.cameraAnimatorDidStopRunningStub)
        XCTAssertTrue(delegate.cameraAnimatorDidStopRunningStub.parameters.first === animator)
    }

    func testUpdate() {
        animator.startAnimation()

        // Simulate advancing by 10 ms
        dateProvider.nowStub.defaultReturnValue += 0.01
        animator.update()

        // Expected value is duration * velocity;
        XCTAssertEqual(locationChangeHandler.parameters, [.init(fromLocation: location, toLocation: CGPoint(x: 10, y: -10))])
        // The previous update() should also have reduced the velocity
        // by multiplying it by the decelerationFactor once for each elapsed
        // millisecond. In this simulateion, 10 ms have elapsed.
        let expectedVelocityAdjustmentFactor = pow(decelerationFactor, 10)
        locationChangeHandler.reset()
        // Make sure the animation didn't end yet
        XCTAssertEqual(animator.state, .active)
        assertMethodNotCall(completion)

        // This time, advance by 20 ms to keep it distinct
        // from the first update() call.
        dateProvider.nowStub.defaultReturnValue += 0.02
        animator.update()

        // The expected value this time is the previous location + the reduced
        // velocity (velocity * expectedVelocityAdjustmentFactor) times the elapsed duration
        assertMethodCall(locationChangeHandler)
        XCTAssertEqual(locationChangeHandler.invocations[0].parameters.fromLocation, location)
        XCTAssertEqual(locationChangeHandler.invocations[0].parameters.toLocation.x,
                       (velocity.x * expectedVelocityAdjustmentFactor) * 0.02,
                       accuracy: 0.0000000001)
        XCTAssertEqual(locationChangeHandler.invocations[0].parameters.toLocation.y,
                       (velocity.y * expectedVelocityAdjustmentFactor) * 0.02,
                       accuracy: 0.0000000001)
        locationChangeHandler.reset()
        // After the previous update() call, the velocity should have also been reduced
        // to be sufficiently low (< 20 in both x and y) to end the animation.
        XCTAssertEqual(animator.state, .inactive)
        assertMethodCall(completion)
        assertMethodCall(delegate.cameraAnimatorDidStopRunningStub)
        XCTAssertTrue(delegate.cameraAnimatorDidStopRunningStub.parameters.first === animator)
    }
}
