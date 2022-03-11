import XCTest
@testable import MapboxMaps

final class CameraAnimatorsRunnerTests: XCTestCase {
    var mapboxMap: MockMapboxMap!
    var cameraAnimatorsRunner: CameraAnimatorsRunner!

    override func setUp() {
        super.setUp()
        mapboxMap = MockMapboxMap()
        cameraAnimatorsRunner = CameraAnimatorsRunner(
            mapboxMap: mapboxMap)
    }

    override func tearDown() {
        cameraAnimatorsRunner = nil
        mapboxMap = nil
        super.tearDown()
    }

    func testCameraAnimators() {
        let animators = [MockCameraAnimator].random(
            withLength: 10,
            generator: MockCameraAnimator.init)

        for animator in animators {
            cameraAnimatorsRunner.add(animator)
        }

        XCTAssertEqual(
            Set(cameraAnimatorsRunner.cameraAnimators.map(ObjectIdentifier.init(_:))),
            Set(animators.map(ObjectIdentifier.init(_:))))
    }

    func testKeepsWeakRefToAnimatorsThatAreNotRunning() {
        // held strongly
        let animator1 = MockCameraAnimator()
        weak var weakAnimator2: MockCameraAnimator?
        do {
            cameraAnimatorsRunner.add(animator1)

            // held weakly, but running
            let animator2 = MockCameraAnimator()
            weakAnimator2 = animator2
            cameraAnimatorsRunner.add(animator2)
            cameraAnimatorsRunner.cameraAnimatorDidStartRunning(animator2)

            // held weakly, not running
            let animator3 = MockCameraAnimator()
            cameraAnimatorsRunner.add(animator3)
        }

        if let animator2 = weakAnimator2 {
            autoreleasepool {
                XCTAssertEqual(cameraAnimatorsRunner.cameraAnimators.count, 2)
                XCTAssertTrue(cameraAnimatorsRunner.cameraAnimators.contains { $0 === animator1 })
                XCTAssertTrue(cameraAnimatorsRunner.cameraAnimators.contains { $0 === animator2 })
            }
            cameraAnimatorsRunner.cameraAnimatorDidStopRunning(animator2)
        }

        XCTAssertEqual(
            Set(cameraAnimatorsRunner.cameraAnimators.map(ObjectIdentifier.init(_:))),
            Set([animator1].map(ObjectIdentifier.init(_:))))
    }

    func testUpdateWithAnimationsEnabled() {
        cameraAnimatorsRunner.animationsEnabled = true
        let animator = MockCameraAnimator()
        cameraAnimatorsRunner.add(animator)
        cameraAnimatorsRunner.cameraAnimatorDidStartRunning(animator)

        cameraAnimatorsRunner.update()

        XCTAssertEqual(animator.stopAnimationStub.invocations.count, 0)
        XCTAssertEqual(animator.cancelStub.invocations.count, 0)
        XCTAssertEqual(animator.updateStub.invocations.count, 1)
    }

    func testUpdateWithAnimationsDisabled() {
        cameraAnimatorsRunner.animationsEnabled = false
        let animator = MockCameraAnimator()
        cameraAnimatorsRunner.add(animator)
        cameraAnimatorsRunner.cameraAnimatorDidStartRunning(animator)

        cameraAnimatorsRunner.update()

        XCTAssertEqual(animator.stopAnimationStub.invocations.count, 1)
        XCTAssertEqual(animator.cancelStub.invocations.count, 0)
        XCTAssertEqual(animator.updateStub.invocations.count, 0)
    }

    func testCancelAnimations() {
        let animator = MockCameraAnimator()
        animator.state = .random()
        animator.owner = .random()
        cameraAnimatorsRunner.add(animator)

        cameraAnimatorsRunner.cancelAnimations()

        XCTAssertEqual(animator.stopAnimationStub.invocations.count, 1)
        XCTAssertEqual(animator.cancelStub.invocations.count, 0)
    }

    func testCancelAnimationsWithEmptyOwnersArray() {
        let animators = [MockCameraAnimator].random(withLength: 10) {
            let animator = MockCameraAnimator()
            animator.state = .random()
            animator.owner = .random()
            return animator
        }

        for animator in animators {
            cameraAnimatorsRunner.add(animator)
        }

        cameraAnimatorsRunner.cancelAnimations(withOwners: [])

        for animator in animators {
            XCTAssertEqual(animator.stopAnimationStub.invocations.count, 0)
            XCTAssertEqual(animator.cancelStub.invocations.count, 0)
        }
    }

    func testCancelAnimationsWithSingleOwner() {
        let owner = AnimationOwner.random()

        let animators = [MockCameraAnimator].random(withLength: 10) {
            let animator = MockCameraAnimator()
            animator.state = .random()
            animator.owner = owner
            return animator
        }

        animators[9].owner = AnimationOwner(rawValue: owner.rawValue + "-other")

        for animator in animators {
            cameraAnimatorsRunner.add(animator)
        }

        cameraAnimatorsRunner.cancelAnimations(withOwners: [owner])

        for animator in animators[0..<9] {
            XCTAssertEqual(animator.stopAnimationStub.invocations.count, 1)
            XCTAssertEqual(animator.cancelStub.invocations.count, 0)
        }

        XCTAssertEqual(animators[9].stopAnimationStub.invocations.count, 0)
        XCTAssertEqual(animators[9].cancelStub.invocations.count, 0)
    }

    func testCancelAnimationsWithSingleMultipleOwners() {
        let owner1 = AnimationOwner.random()
        let owner2 = AnimationOwner.random()

        let animators: [MockCameraAnimator] = .random(withLength: 5) {
            let animator = MockCameraAnimator()
            animator.state = .random()
            animator.owner = owner1
            return animator
        } + .random(withLength: 6) {
            let animator = MockCameraAnimator()
            animator.state = .random()
            animator.owner = owner2
            return animator
        }

        animators[10].owner = AnimationOwner(rawValue: owner1.rawValue + owner2.rawValue)

        for animator in animators {
            cameraAnimatorsRunner.add(animator)
        }

        cameraAnimatorsRunner.cancelAnimations(withOwners: [owner1, owner2])

        for animator in animators[0..<10] {
            XCTAssertEqual(animator.stopAnimationStub.invocations.count, 1)
            XCTAssertEqual(animator.cancelStub.invocations.count, 0)
        }

        XCTAssertEqual(animators[10].stopAnimationStub.invocations.count, 0)
        XCTAssertEqual(animators[10].cancelStub.invocations.count, 0)
    }

    func testCameraAnimatorDelegate() {
        let animator1 = MockCameraAnimator()
        let animator2 = MockCameraAnimator()

        // stopping before starting should have no effect
        cameraAnimatorsRunner.cameraAnimatorDidStopRunning(animator1)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 0)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 0)

        // start once
        cameraAnimatorsRunner.cameraAnimatorDidStartRunning(animator1)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 0)

        // start twice
        cameraAnimatorsRunner.cameraAnimatorDidStartRunning(animator1)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 0)

        // start a second
        cameraAnimatorsRunner.cameraAnimatorDidStartRunning(animator2)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 2)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 0)

        // end the first
        cameraAnimatorsRunner.cameraAnimatorDidStopRunning(animator1)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 2)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 1)

        // end the first again
        cameraAnimatorsRunner.cameraAnimatorDidStopRunning(animator1)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 2)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 1)

        // end the second
        cameraAnimatorsRunner.cameraAnimatorDidStopRunning(animator2)
        XCTAssertEqual(mapboxMap.beginAnimationStub.invocations.count, 2)
        XCTAssertEqual(mapboxMap.endAnimationStub.invocations.count, 2)
    }
}
