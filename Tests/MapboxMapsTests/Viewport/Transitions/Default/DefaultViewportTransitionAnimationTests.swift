@testable import MapboxMaps
import UIKit
import XCTest

final class DefaultViewportTransitionAnimationTests: XCTestCase {
    var components: [MockDefaultViewportTransitionAnimation]!
    var animation: DefaultViewportTransitionAnimation!

    override func setUp() {
        super.setUp()
        components = Array.random(
            withLength: .random(in: 1...10),
            generator: MockDefaultViewportTransitionAnimation.init)
        animation = DefaultViewportTransitionAnimation(components: components)
    }

    override func tearDown() {
        animation = nil
        components = nil
        super.tearDown()
    }

    func testStartAllComponentsSucceed() throws {
        let completionStub = Stub<Bool, Void>()
        let completionExpectation = expectation(description: "completion invoked")
        completionStub.defaultSideEffect = { _ in
            completionExpectation.fulfill()
        }

        animation.start(with: completionStub.call(with:))

        for component in components {
            XCTAssertEqual(component.startStub.invocations.count, 1)
            let completion = try XCTUnwrap(component.startStub.invocations.first?.parameters)
            completion(true)
        }

        wait(for: [completionExpectation], timeout: 0.5)

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [true])
    }

    func testStartOneComponentFails() throws {
        let completionStub = Stub<Bool, Void>()
        let completionExpectation = expectation(description: "completion invoked")
        completionStub.defaultSideEffect = { _ in
            completionExpectation.fulfill()
        }

        animation.start(with: completionStub.call(with:))

        let failingIndex = Int.random(in: 0..<components.count)
        for (idx, component) in components.enumerated() {
            XCTAssertEqual(component.startStub.invocations.count, 1)
            let completion = try XCTUnwrap(component.startStub.invocations.first?.parameters)
            completion(idx != failingIndex)
        }

        wait(for: [completionExpectation], timeout: 0.5)

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [false])
    }

    func testStartWithZeroComponents() throws {
        animation = DefaultViewportTransitionAnimation(components: [])

        let completionStub = Stub<Bool, Void>()
        let completionExpectation = expectation(description: "completion invoked")
        completionStub.defaultSideEffect = { _ in
            completionExpectation.fulfill()
        }

        animation.start(with: completionStub.call(with:))

        wait(for: [completionExpectation], timeout: 0.5)

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [true])
    }

    func testUpdateTargetCamera() {
        let cameraOptions = CameraOptions.random()

        animation.updateTargetCamera(with: cameraOptions)

        for component in components {
            XCTAssertEqual(component.updateTargetCameraStub.invocations.map(\.parameters), [cameraOptions])
        }
    }

    func testCancel() {
        animation.cancel()

        for component in components {
            XCTAssertEqual(component.cancelStub.invocations.count, 1)
        }
    }
}

final class DefaultViewportTransitionAnimationComponentTests: XCTestCase {
    var animator: MockSimpleCameraAnimator!
    var delay: TimeInterval!
    var cameraOptionsComponent: MockCameraOptionsComponent!
    var mapboxMap: MockMapboxMap!
    var animationComponent: DefaultViewportTransitionAnimationComponent!

    override func setUp() {
        super.setUp()
        animator = MockSimpleCameraAnimator()
        delay = .random(in: 0...100)
        cameraOptionsComponent = MockCameraOptionsComponent()
        mapboxMap = MockMapboxMap()
        animationComponent = DefaultViewportTransitionAnimationComponent(
            animator: animator,
            delay: delay,
            cameraOptionsComponent: cameraOptionsComponent,
            mapboxMap: mapboxMap)
    }

    override func tearDown() {
        animationComponent = nil
        mapboxMap = nil
        cameraOptionsComponent = nil
        delay = nil
        animator = nil
        super.tearDown()
    }

    func testStartAndCompleteWithPositionStartOrEnd() throws {
        let completionStub = Stub<Bool, Void>()

        animationComponent.start(with: completionStub.call(with:))

        XCTAssertEqual(animator.addCompletionStub.invocations.count, 1)
        let animatorCompletion = try XCTUnwrap(animator.addCompletionStub.invocations.first?.parameters)
        XCTAssertEqual(animator.startAnimationAfterDelayStub.invocations.map(\.parameters), [delay])

        let position: UIViewAnimatingPosition = [.start, .end].randomElement()!
        animatorCompletion(position)

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [true])
    }

    func testStartAndCompleteWithPositionCurrent() throws {
        let completionStub = Stub<Bool, Void>()

        animationComponent.start(with: completionStub.call(with:))

        XCTAssertEqual(animator.addCompletionStub.invocations.count, 1)
        let animatorCompletion = try XCTUnwrap(animator.addCompletionStub.invocations.first?.parameters)
        XCTAssertEqual(animator.startAnimationAfterDelayStub.invocations.map(\.parameters), [delay])

        animatorCompletion(.current)

        XCTAssertEqual(completionStub.invocations.map(\.parameters), [false])
    }

    func testUpdateTargetCameraWhenUpdatedComponentIsNil() {
        let cameraOptions = CameraOptions.random()
        cameraOptionsComponent.updatedStub.defaultReturnValue = nil

        animationComponent.updateTargetCamera(with: cameraOptions)

        XCTAssertEqual(cameraOptionsComponent.updatedStub.invocations.map(\.parameters), [cameraOptions])
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
        XCTAssertEqual(animator.$to.setStub.invocations.count, 0)
    }

    func testUpdateTargetCameraWhenUpdatedComponentIsNonNilAndAnimatorIsInactive() {
        let updatedComponent = MockCameraOptionsComponent()
        cameraOptionsComponent.updatedStub.defaultReturnValue = updatedComponent
        animator.state = .inactive
        let cameraOptions = CameraOptions.random()

        animationComponent.updateTargetCamera(with: cameraOptions)

        XCTAssertEqual(cameraOptionsComponent.updatedStub.invocations.map(\.parameters), [cameraOptions])
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.map(\.parameters), [updatedComponent.cameraOptions])
        XCTAssertEqual(animator.$to.setStub.invocations.count, 0)
    }

    func testUpdateTargetCameraWhenUpdatedComponentIsNonNilAndAnimatorIsNotInactive() {
        let updatedComponent = MockCameraOptionsComponent()
        cameraOptionsComponent.updatedStub.defaultReturnValue = updatedComponent
        animator.state = [.active, .stopped].randomElement()!
        let cameraOptions = CameraOptions.random()

        animationComponent.updateTargetCamera(with: cameraOptions)

        XCTAssertEqual(cameraOptionsComponent.updatedStub.invocations.map(\.parameters), [cameraOptions])
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)
        XCTAssertEqual(animator.$to.setStub.invocations.map(\.parameters), [updatedComponent.cameraOptions])
    }

    func testCancel() {
        animationComponent.cancel()

        XCTAssertEqual(animator.cancelStub.invocations.count, 1)
    }
}
