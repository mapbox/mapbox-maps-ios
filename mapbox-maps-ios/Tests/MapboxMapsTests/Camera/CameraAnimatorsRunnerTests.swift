import XCTest
@testable import MapboxMaps

final class CameraAnimatorsRunnerTests: XCTestCase {
    var enablable: Enablable!
    var mapboxMap: MockMapboxMap!
    var cameraAnimatorsRunner: CameraAnimatorsRunner!

    override func setUp() {
        super.setUp()
        enablable = Enablable()
        mapboxMap = MockMapboxMap()
        cameraAnimatorsRunner = CameraAnimatorsRunner(
            mapboxMap: mapboxMap,
            enablable: enablable)
    }

    override func tearDown() {
        cameraAnimatorsRunner = nil
        mapboxMap = nil
        enablable = nil
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

    func testUpdateWithAnimationsEnabled() {
        let animator = MockCameraAnimator()
        cameraAnimatorsRunner.add(animator)
        cameraAnimatorsRunner.cameraAnimatorDidStartRunning(animator)
        enablable.isEnabled = true

        cameraAnimatorsRunner.update()

        XCTAssertEqual(animator.stopAnimationStub.invocations.count, 0)
        XCTAssertEqual(animator.cancelStub.invocations.count, 0)
        XCTAssertEqual(animator.updateStub.invocations.count, 1)
    }

    func testUpdateWithAnimationsDisabled() {
        let animator = MockCameraAnimator()
        cameraAnimatorsRunner.add(animator)
        cameraAnimatorsRunner.cameraAnimatorDidStartRunning(animator)
        enablable.isEnabled = false

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

    func testCancelAnimationsWithMultipleOwners() {
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

        animators[10].owner = AnimationOwner(rawValue: owner1.rawValue + owner2.rawValue + "a")

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

    func testAddWithAnimationsEnabled() {
        enablable.isEnabled = true

        let animator = MockCameraAnimator()

        cameraAnimatorsRunner.add(animator)

        XCTAssertIdentical(animator.delegate, cameraAnimatorsRunner)
        XCTAssertEqual(animator.stopAnimationStub.invocations.count, 0)
    }

    func testAddWithAnimationsDisabled() {
        enablable.isEnabled = false

        let animator = MockCameraAnimator()

        cameraAnimatorsRunner.add(animator)

        XCTAssertIdentical(animator.delegate, cameraAnimatorsRunner)
        XCTAssertEqual(animator.stopAnimationStub.invocations.count, 1)
    }
}
