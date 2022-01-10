import XCTest
@testable import MapboxMaps

final class ImmediateViewportTransitionTests: XCTestCase {

    var mapboxMap: MockMapboxMap!
    var transition: ImmediateViewportTransition!

    override func setUp() {
        super.setUp()
        mapboxMap = MockMapboxMap()
        transition = ImmediateViewportTransition(mapboxMap: mapboxMap)
    }

    override func tearDown() {
        transition = nil
        mapboxMap = nil
        super.tearDown()
    }

    func testRunCancellation() throws {
        let toState = MockViewportState()
        let completionStub = Stub<Void, Void>()
        let cancelable = transition.run(from: nil, to: toState, completion: completionStub.call)

        XCTAssertEqual(toState.observeDataSourceStub.invocations.count, 1)
        let observeDataSourceInvocation = try XCTUnwrap(toState.observeDataSourceStub.invocations.first)
        let observeDataSourceCancelable = try XCTUnwrap(observeDataSourceInvocation.returnValue as? MockCancelable)

        cancelable.cancel()

        XCTAssertEqual(observeDataSourceCancelable.cancelStub.invocations.count, 1)
        XCTAssertTrue(completionStub.invocations.isEmpty)
    }

    func testRunCompletion() throws {
        let toState = MockViewportState()
        let completionStub = Stub<Void, Void>()
        _ = transition.run(from: nil, to: toState, completion: completionStub.call)

        XCTAssertEqual(toState.observeDataSourceStub.invocations.count, 1)
        let observeDataSourceInvocation = try XCTUnwrap(toState.observeDataSourceStub.invocations.first)
        let observeDataSourceHandler = observeDataSourceInvocation.parameters
        let cameraOptions = CameraOptions.random()

        let shouldContinue = observeDataSourceHandler(cameraOptions)

        XCTAssertEqual(mapboxMap.setCameraStub.invocations.map(\.parameters), [cameraOptions])
        XCTAssertEqual(completionStub.invocations.count, 1)
        XCTAssertFalse(shouldContinue)
    }
}
