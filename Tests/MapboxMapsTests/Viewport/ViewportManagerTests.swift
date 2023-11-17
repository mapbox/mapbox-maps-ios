import XCTest
@testable import MapboxMaps

final class ViewportManagerTests: XCTestCase {
    var impl: MockViewportManagerImpl!
    var puckRenderDataSubject = SignalSubject<PuckRenderingData>()
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var mapboxMap: MockMapboxMap!
    var styleManager: MockStyle!
    var viewport: ViewportManager!

    override func setUp() {
        super.setUp()
        impl = MockViewportManagerImpl()
        cameraAnimationsManager = MockCameraAnimationsManager()
        mapboxMap = MockMapboxMap()
        styleManager = MockStyle()
        viewport = ViewportManager(
            impl: impl,
            onPuckRender: puckRenderDataSubject.signal,
            cameraAnimationsManager: cameraAnimationsManager,
            mapboxMap: mapboxMap,
            styleManager: styleManager)
    }

    override func tearDown() {
        styleManager = nil
        viewport = nil
        mapboxMap = nil
        cameraAnimationsManager = nil
        impl = nil
        super.tearDown()
    }

    func testOptions() {
        let value = viewport.options

        XCTAssertEqual([value], impl.$options.getStub.invocations.map(\.returnValue))

        let newValue = ViewportOptions.random()

        viewport.options = newValue

        XCTAssertEqual(impl.$options.setStub.invocations.map(\.parameters), [newValue])
    }

    func testStatus() {
        let value = viewport.status

        XCTAssertEqual([value], impl.$status.getStub.invocations.map(\.returnValue))
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
        let transition = MockViewportTransition()
        let completionStub = Stub<Bool, Void>()

        viewport.transition(
            to: toState,
            transition: transition,
            completion: completionStub.call(with:))

        XCTAssertEqual(impl.transitionStub.invocations.count, 1)
        let implInvocation = try XCTUnwrap(impl.transitionStub.invocations.first)
        XCTAssertTrue(implInvocation.parameters.toState === toState)
        XCTAssertTrue(implInvocation.parameters.transition === transition)
        let finished = Bool.random()
        implInvocation.parameters.completion?(finished)
        XCTAssertEqual(completionStub.invocations.map(\.parameters), [finished])
    }

    func testTransitionWithNilTransitionAndNilCompletion() throws {
        let toState = MockViewportState()

        viewport.transition(to: toState, transition: nil, completion: nil)

        XCTAssertEqual(impl.transitionStub.invocations.count, 1)
        let implInvocation = try XCTUnwrap(impl.transitionStub.invocations.first)
        XCTAssertTrue(implInvocation.parameters.toState === toState)
        XCTAssertNil(implInvocation.parameters.transition)
        XCTAssertNil(implInvocation.parameters.completion)
    }

    func testTransitionWithDefaultTransitionAndCompletion() throws {
        let toState = MockViewportState()

        viewport.transition(to: toState)

        XCTAssertEqual(impl.transitionStub.invocations.count, 1)
        let implInvocation = try XCTUnwrap(impl.transitionStub.invocations.first)
        XCTAssertTrue(implInvocation.parameters.toState === toState)
        XCTAssertNil(implInvocation.parameters.transition)
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

    func testMakeFollowPuckViewportStateWithDefaultOptions() {
        let state = viewport.makeFollowPuckViewportState()

        XCTAssertEqual(state.options, .init())
    }

    func testMakeFollowPuckViewportStateWithCustomOptions() {
        let options = FollowPuckViewportStateOptions.random()

        let state = viewport.makeFollowPuckViewportState(options: options)

        XCTAssertEqual(state.options, options)
    }

    func testMakeOverviewViewportStateWithCustomOptions() {
        let options = OverviewViewportStateOptions.random()

        let state = viewport.makeOverviewViewportState(options: options)

        XCTAssertEqual(state.options, options)
    }

    func testMakeDefaultViewportTransitionWithDefaultOptions() {
        let transition = viewport.makeDefaultViewportTransition()

        XCTAssertEqual(transition.options, .init())
    }

    func testMakeDefaultViewportTransitionWithCustomOptions() {
        let options = DefaultViewportTransitionOptions.random()

        let transition = viewport.makeDefaultViewportTransition(options: options)

        XCTAssertEqual(transition.options, options)
    }

    func testMakeImmediateViewportTransition() {
        let _: ImmediateViewportTransition = viewport.makeImmediateViewportTransition()

        // doesn't crash; no interface to verify
    }
}
