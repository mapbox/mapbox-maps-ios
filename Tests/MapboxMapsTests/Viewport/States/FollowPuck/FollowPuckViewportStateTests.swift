import XCTest
@testable @_spi(Experimental) import MapboxMaps

final class FollowPuckViewportStateTest: XCTestCase {

    var dataSource: MockFollowPuckViewportStateDataSource!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var state: FollowPuckViewportState!

    override func setUp() {
        super.setUp()
        dataSource = MockFollowPuckViewportStateDataSource()
        cameraAnimationsManager = MockCameraAnimationsManager()
        state = FollowPuckViewportState(
            dataSource: dataSource,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    override func tearDown() {
        state = nil
        cameraAnimationsManager = nil
        dataSource = nil
        super.tearDown()
    }

    func verifyEaseTo(with expectedCamera: CameraOptions) throws -> MockCancelable {
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        let easeToInvocation = try XCTUnwrap(cameraAnimationsManager.easeToStub.invocations.first)
        XCTAssertEqual(easeToInvocation.parameters.camera, expectedCamera)
        XCTAssertEqual(easeToInvocation.parameters.duration,
                       max(0, dataSource.options.animationDuration))
        XCTAssertEqual(easeToInvocation.parameters.curve, .linear)
        XCTAssertNil(easeToInvocation.parameters.completion)
        return try XCTUnwrap(easeToInvocation.returnValue as? MockCancelable)
    }

    func testGetOptions() {
        let options = state.options

        XCTAssertEqual(dataSource.$options.getStub.invocations.map(\.returnValue), [options])
    }

    func testSetOptions() {
        let newOptions = FollowPuckViewportStateOptions.random()

        state.options = newOptions

        XCTAssertEqual(dataSource.$options.setStub.invocations.map(\.parameters), [newOptions])
    }

    func testObserveDataSource() throws {
        let handlerStub = Stub<CameraOptions, Bool>(defaultReturnValue: .random())

        let cancelable = state.observeDataSource(with: handlerStub.call(with:))

        XCTAssertEqual(dataSource.observeStub.invocations.count, 1)
        let dataSourceInvocation = try XCTUnwrap(dataSource.observeStub.invocations.first)

        // verify that when the handler passed to the internal data source is invoked
        // the one passed in externally is as well.
        let handler = dataSourceInvocation.parameters
        let cameraOptions = CameraOptions.random()

        let result = handler(cameraOptions)

        XCTAssertEqual(handlerStub.invocations.map(\.parameters), [cameraOptions])
        XCTAssertEqual(handlerStub.invocations.map(\.returnValue), [result])

        // verify that canceling the returned cancelable also cancels
        // the one returned by the call to the internal data source. They could
        // be the same cancelable, but writing the test to avoid that
        // assumption should make refactoring easier.
        let observeCancelable = try XCTUnwrap(dataSourceInvocation.returnValue as? MockCancelable)

        cancelable.cancel()

        XCTAssertEqual(observeCancelable.cancelStub.invocations.count, 1)
    }

    func testStartAndStopUpdatingCamera() throws {
        let cameraOptions = CameraOptions.random()
        state.startUpdatingCamera()

        // verify that an observation was created
        XCTAssertEqual(dataSource.observeStub.invocations.count, 1)
        let dataSourceInvocation = try XCTUnwrap(dataSource.observeStub.invocations.first)
        let observeHandler = dataSourceInvocation.parameters
        let observeCancelable = try XCTUnwrap(dataSourceInvocation.returnValue as? MockCancelable)

        // exercise the observation handler
        let result = observeHandler(cameraOptions)

        // verify that the expected animation was started
        let easeToCancelable = try verifyEaseTo(with: cameraOptions)
        // verify that the handler returns true (to continue receiving updates)
        XCTAssertTrue(result)

        // stop updates
        state.stopUpdatingCamera()

        // verify that the animation and observe cancelables are both canceled
        XCTAssertEqual(easeToCancelable.cancelStub.invocations.count, 1)
        XCTAssertEqual(observeCancelable.cancelStub.invocations.count, 1)
    }

    func testStartUpdatingMultipleTimesDoesNothing() {
        state.startUpdatingCamera()
        state.startUpdatingCamera()

        // only one observation is created
        XCTAssertEqual(dataSource.observeStub.invocations.count, 1)
    }

    func testRestartingUpdates() {
        state.startUpdatingCamera()
        state.stopUpdatingCamera()
        dataSource.observeStub.reset()

        // restart
        state.startUpdatingCamera()

        // a new observation is created
        XCTAssertEqual(dataSource.observeStub.invocations.count, 1)
    }
}
