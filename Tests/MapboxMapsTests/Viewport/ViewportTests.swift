import XCTest
@testable import MapboxMaps

final class ViewportTests: XCTestCase {
    var impl: MockViewportImpl!
    var locationProducer: MockLocationProducer!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var mapboxMap: MockMapboxMap!
    var viewport: Viewport!

    override func setUp() {
        super.setUp()
        impl = MockViewportImpl()
        locationProducer = MockLocationProducer()
        cameraAnimationsManager = MockCameraAnimationsManager()
        mapboxMap = MockMapboxMap()
        viewport = Viewport(
            impl: impl,
            locationProducer: locationProducer,
            cameraAnimationsManager: cameraAnimationsManager,
            mapboxMap: mapboxMap)
    }

    override func tearDown() {
        viewport = nil
        mapboxMap = nil
        cameraAnimationsManager = nil
        locationProducer = nil
        impl = nil
        super.tearDown()
    }

    func testStatus() {
        impl.status = [
            .state(MockViewportState()),
            .state(nil),
            .transition(MockViewportTransition(),
                        fromState: MockViewportState(),
                        toState: MockViewportState())
        ].randomElement()!

        XCTAssertEqual(viewport.status, impl.status)
    }

    func testAddStatusObserver() {
        let observer = MockViewportStatusObserver()

        viewport.addStatusObserver(observer)

        XCTAssertTrue(impl.addStatusObserverStub.invocations.map(\.parameters).elementsEqual([observer], by: ===))
    }

    func testRemoveStatusObserver() {
        let observer = MockViewportStatusObserver()

        viewport.removeStatusObserver(observer)

        XCTAssertTrue(impl.removeStatusObserverStub.invocations.map(\.parameters).elementsEqual([observer], by: ===))
    }

    func testIdle() {
        viewport.idle()

        XCTAssertEqual(impl.idleStub.invocations.count, 1)
    }

    func testTransition() throws {
        let toState = MockViewportState()
        let completionStub = Stub<Bool, Void>()

        viewport.transition(to: toState, completion: completionStub.call(with:))

        XCTAssertEqual(impl.transitionStub.invocations.count, 1)
        let implInvocation = try XCTUnwrap(impl.transitionStub.invocations.first)
        XCTAssertTrue(implInvocation.parameters.toState === toState)
        let finished = Bool.random()
        implInvocation.parameters.completion?(finished)
        XCTAssertEqual(completionStub.invocations.map(\.parameters), [finished])
    }

    func testTransitionWithNilCompletion() throws {
        let toState = MockViewportState()

        viewport.transition(to: toState, completion: nil)

        XCTAssertEqual(impl.transitionStub.invocations.count, 1)
        let implInvocation = try XCTUnwrap(impl.transitionStub.invocations.first)
        XCTAssertTrue(implInvocation.parameters.toState === toState)
        XCTAssertNil(implInvocation.parameters.completion)
    }

    func testTransitionWithDefaultCompletion() throws {
        let toState = MockViewportState()

        viewport.transition(to: toState)

        XCTAssertEqual(impl.transitionStub.invocations.count, 1)
        let implInvocation = try XCTUnwrap(impl.transitionStub.invocations.first)
        XCTAssertTrue(implInvocation.parameters.toState === toState)
        XCTAssertNil(implInvocation.parameters.completion)
    }

    func testDefaultTransition() {
        let transitionA = MockViewportTransition()
        impl.defaultTransition = transitionA

        XCTAssertTrue(viewport.defaultTransition === transitionA)

        let transitionB = MockViewportTransition()
        viewport.defaultTransition = transitionB

        XCTAssertTrue(impl.defaultTransition === transitionB)
    }

    func testSetTransition() throws {
        let transition = MockViewportTransition()
        let fromState: MockViewportState? = [nil, .init()].randomElement()!
        let toState = MockViewportState()

        viewport.setTransition(transition, from: fromState, to: toState)

        XCTAssertEqual(impl.setTransitionStub.invocations.count, 1)
        let implInvocation = try XCTUnwrap(impl.setTransitionStub.invocations.first)
        XCTAssertTrue(implInvocation.parameters.transition === transition)
        XCTAssertTrue(implInvocation.parameters.fromState === fromState)
        XCTAssertTrue(implInvocation.parameters.toState === toState)
    }

    func testGetTransition() throws {
        impl.getTransitionStub.defaultReturnValue = [nil, MockViewportTransition()].randomElement()!
        let fromState: MockViewportState? = [nil, .init()].randomElement()!
        let toState = MockViewportState()

        let transition = viewport.getTransition(from: fromState, to: toState)

        XCTAssertEqual(impl.getTransitionStub.invocations.count, 1)
        let implInvocation = try XCTUnwrap(impl.getTransitionStub.invocations.first)
        XCTAssertTrue(implInvocation.parameters.fromState === fromState)
        XCTAssertTrue(implInvocation.parameters.toState === toState)
        XCTAssertTrue(transition === implInvocation.returnValue)
    }

    func testRemoveTransition() throws {
        let fromState: MockViewportState? = [nil, .init()].randomElement()!
        let toState = MockViewportState()

        viewport.removeTransition(from: fromState, to: toState)

        XCTAssertEqual(impl.removeTransitionStub.invocations.count, 1)
        let implInvocation = try XCTUnwrap(impl.removeTransitionStub.invocations.first)
        XCTAssertTrue(implInvocation.parameters.fromState === fromState)
        XCTAssertTrue(implInvocation.parameters.toState === toState)
    }
}
