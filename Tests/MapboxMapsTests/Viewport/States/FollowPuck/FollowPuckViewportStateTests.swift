import XCTest
@testable @_spi(Experimental) import MapboxMaps

final class FollowPuckViewportStateTest: XCTestCase {

    var dataSource: MockFollowPuckViewportStateDataSource!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var mapboxMap: MockMapboxMap!
    var state: FollowPuckViewportState!

    override func setUp() {
        super.setUp()
        dataSource = MockFollowPuckViewportStateDataSource()
        cameraAnimationsManager = MockCameraAnimationsManager()
        mapboxMap = MockMapboxMap()
        state = FollowPuckViewportState(
            dataSource: dataSource,
            cameraAnimationsManager: cameraAnimationsManager,
            mapboxMap: mapboxMap)
    }

    override func tearDown() {
        state = nil
        mapboxMap = nil
        cameraAnimationsManager = nil
        dataSource = nil
        super.tearDown()
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

        // verify that the camera was set
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.map(\.parameters), [cameraOptions])
        // verify that the handler returns true (to continue receiving updates)
        XCTAssertTrue(result)

        // stop updates
        state.stopUpdatingCamera()

        // verify that the observe cancelable is canceled
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
