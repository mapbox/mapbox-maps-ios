import XCTest
@testable import MapboxMaps

final class GestureDecelerationCameraAnimatorTests: XCTestCase {

    var location: CGPoint!
    var velocity: CGPoint!
    var decelerationFactor: CGFloat!
    var locationChangeHandler: Stub<CGPoint, Void>!
    var dateProvider: MockDateProvider!
    var completion: Stub<Void, Void>!
    var animator: GestureDecelerationCameraAnimator!

    override func setUp() {
        super.setUp()
        location = .zero
        velocity = CGPoint(x: 1000, y: -1000)
        decelerationFactor = 0.7
        locationChangeHandler = Stub()
        dateProvider = MockDateProvider()
        completion = Stub()
        animator = GestureDecelerationCameraAnimator(
            location: location,
            velocity: velocity,
            decelerationFactor: decelerationFactor,
            locationChangeHandler: locationChangeHandler.call(with:),
            dateProvider: dateProvider)
        animator.completion = completion.call
    }

    override func tearDown() {
        animator = nil
        completion = nil
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
    }

    func testStopAnimation() {
        animator.startAnimation()

        animator.stopAnimation()

        XCTAssertEqual(animator.state, .inactive)
        XCTAssertEqual(completion.invocations.count, 1)
    }

    func testUpdate() {
        animator.startAnimation()

        // Simulate advancing by 10 ms
        dateProvider.nowStub.defaultReturnValue += 0.01
        animator.update()

        // Expected value is duration * velocity;
        XCTAssertEqual(locationChangeHandler.parameters, [CGPoint(x: 10, y: -10)])
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
        XCTAssertEqual(
            locationChangeHandler.parameters, [
                CGPoint(
                    x: 10 + (velocity.x * expectedVelocityAdjustmentFactor) * 0.02,
                    y: -10 + (velocity.y * expectedVelocityAdjustmentFactor) * 0.02)])
        locationChangeHandler.reset()
        // After the previous update() call, the velocity should have also been reduced
        // to be sufficiently low (< 1 in both x and y) to end the animation.
        XCTAssertEqual(animator.state, .inactive)
        XCTAssertEqual(completion.invocations.count, 1)
    }
}
