@testable import MapboxMaps
import XCTest

final class DefaultViewportTransitionAnimationHelperTests: XCTestCase {
    var mapboxMap: MockMapboxMap!
    var animationSpecProvider: MockDefaultViewportTransitionAnimationSpecProvider!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var animationFactory: MockDefaultViewportTransitionAnimationFactory!
    var helper: DefaultViewportTransitionAnimationHelper!

    override func setUp() {
        super.setUp()
        mapboxMap = MockMapboxMap()
        animationSpecProvider = MockDefaultViewportTransitionAnimationSpecProvider()
        cameraAnimationsManager = MockCameraAnimationsManager()
        animationFactory = MockDefaultViewportTransitionAnimationFactory()
        helper = DefaultViewportTransitionAnimationHelper(
            mapboxMap: mapboxMap,
            animationSpecProvider: animationSpecProvider,
            cameraAnimationsManager: cameraAnimationsManager,
            animationFactory: animationFactory)
    }

    override func tearDown() {
        helper = nil
        animationFactory = nil
        cameraAnimationsManager = nil
        animationSpecProvider = nil
        mapboxMap = nil
        super.tearDown()
    }

    func testMakeAnimationWithZeroSpecs() throws {
        let cameraOptions = CameraOptions.random()
        animationSpecProvider.makeAnimationSpecsStub.defaultReturnValue = []

        let animation = helper.makeAnimation(
            cameraOptions: cameraOptions,
            maxDuration: .random(in: 0...100))

        XCTAssertEqual(animationSpecProvider.makeAnimationSpecsStub.invocations.map(\.parameters), [cameraOptions])

        XCTAssertEqual(animationFactory.makeAnimationStub.invocations.count, 1)
        let makeAnimationInvocation = try XCTUnwrap(animationFactory.makeAnimationStub.invocations.first)
        XCTAssertEqual(makeAnimationInvocation.parameters.count, 0)
        XCTAssertIdentical(animation, makeAnimationInvocation.returnValue)
    }

    func verifyAnimationCreation(spec: DefaultViewportTransitionAnimationSpec, index: Int) throws {
        guard index < cameraAnimationsManager.makeSimpleCameraAnimatorStub.invocations.count,
              index < animationFactory.makeAnimationComponentStub.invocations.count else {
                  XCTFail("index out of bounds")
                  return
              }

        let makeSimpleCameraAnimatorInvocation = cameraAnimationsManager.makeSimpleCameraAnimatorStub.invocations[index]
        let makeAnimationComponentInvocation = animationFactory.makeAnimationComponentStub.invocations[index]

        XCTAssertEqual(makeSimpleCameraAnimatorInvocation.parameters.from, CameraOptions(cameraState: mapboxMap.cameraState))
        XCTAssertEqual(makeSimpleCameraAnimatorInvocation.parameters.to, spec.cameraOptionsComponent.cameraOptions)
        XCTAssertEqual(makeSimpleCameraAnimatorInvocation.parameters.duration, spec.duration)
        XCTAssertEqual(makeSimpleCameraAnimatorInvocation.parameters.curve, .easeInOut)
        XCTAssertEqual(makeSimpleCameraAnimatorInvocation.parameters.owner, .defaultViewportTransition)

        XCTAssertIdentical(makeAnimationComponentInvocation.parameters.animator, makeSimpleCameraAnimatorInvocation.returnValue)
        XCTAssertEqual(makeAnimationComponentInvocation.parameters.delay, spec.delay)
        XCTAssertIdentical(
            makeAnimationComponentInvocation.parameters.cameraOptionsComponent as? MockCameraOptionsComponent,
            spec.cameraOptionsComponent as? MockCameraOptionsComponent)
    }

    func verifyMakeAnimation(maxDuration: TimeInterval,
                             duration: TimeInterval,
                             delay: TimeInterval,
                             expectedScaleFactor: Double) throws {
        let cameraOptions = CameraOptions.random()
        let specs = [
            DefaultViewportTransitionAnimationSpec(
                duration: duration,
                delay: delay,
                cameraOptionsComponent: MockCameraOptionsComponent()),
            DefaultViewportTransitionAnimationSpec(
                duration: 1,
                delay: 0,
                cameraOptionsComponent: MockCameraOptionsComponent())
        ]
        animationSpecProvider.makeAnimationSpecsStub.defaultReturnValue = specs
        mapboxMap.cameraState = .random()

        let animation = helper.makeAnimation(
            cameraOptions: cameraOptions,
            maxDuration: maxDuration)

        XCTAssertEqual(animationSpecProvider.makeAnimationSpecsStub.invocations.map(\.parameters), [cameraOptions])

        // verify that the specs are converted into animations without any scaling
        XCTAssertEqual(cameraAnimationsManager.makeSimpleCameraAnimatorStub.invocations.count, specs.count)
        XCTAssertEqual(animationFactory.makeAnimationComponentStub.invocations.count, specs.count)

        for (idx, spec) in specs.enumerated() {
            try verifyAnimationCreation(spec: spec.scaled(by: expectedScaleFactor), index: idx)
        }

        XCTAssertEqual(animationFactory.makeAnimationStub.invocations.count, 1)
        let makeAnimationInvocation = try XCTUnwrap(animationFactory.makeAnimationStub.invocations.first)
        XCTAssertEqual(makeAnimationInvocation.parameters.count, animationFactory.makeAnimationComponentStub.invocations.count)
        for (a, b) in zip(makeAnimationInvocation.parameters, animationFactory.makeAnimationComponentStub.invocations.map(\.returnValue)) {
            XCTAssertIdentical(a, b)
        }
        XCTAssertIdentical(animation, makeAnimationInvocation.returnValue)
    }

    func testMakeAnimationWithLongestDurationLessThanMax() throws {
        try verifyMakeAnimation(
            maxDuration: 100,
            duration: 25,
            delay: 25,
            expectedScaleFactor: 1)
    }

    func testMakeAnimationWithLongestDurationEqualToMax() throws {
        try verifyMakeAnimation(
            maxDuration: 100,
            duration: 50,
            delay: 50,
            expectedScaleFactor: 1)
    }

    func testMakeAnimationWithLongestDurationGreaterThanMax() throws {
        try verifyMakeAnimation(
            maxDuration: 100,
            duration: 100,
            delay: 100,
            expectedScaleFactor: 0.5)
    }
}
