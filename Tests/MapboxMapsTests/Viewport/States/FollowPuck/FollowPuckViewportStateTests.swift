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

        assertMethodCall(dataSource.observeStub)
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

        assertMethodCall(observeCancelable.cancelStub)
    }

    func testStartAndStopUpdatingCamera() throws {
        let cameraOptions0 = CameraOptions.random()
        let cameraOptions1 = CameraOptions.random()
        let cameraOptions2 = CameraOptions.random()
        state.startUpdatingCamera()

        // verify that an observation was created
        assertMethodCall(dataSource.observeStub)
        let dataSourceInvocation = try XCTUnwrap(dataSource.observeStub.invocations.first)
        let observeHandler = dataSourceInvocation.parameters
        let observeCancelable = try XCTUnwrap(dataSourceInvocation.returnValue as? MockCancelable)

        // exercise the observation handler and
        // verify that it returns true (to continue receiving updates)
        XCTAssertTrue(observeHandler(cameraOptions0))

        // verify that an animation was started
        assertMethodCall(cameraAnimationsManager.easeToStub)
        let easeToInvocation = try XCTUnwrap(cameraAnimationsManager.easeToStub.invocations.first)
        XCTAssertEqual(easeToInvocation.parameters.camera, cameraOptions0)
        XCTAssertEqual(easeToInvocation.parameters.duration, state.options.animationDuration)
        XCTAssertEqual(easeToInvocation.parameters.curve, .linear)
        let easeToCompletion = try XCTUnwrap(easeToInvocation.parameters.completion)
        let easeToCancelable = try XCTUnwrap(easeToInvocation.returnValue as? MockCancelable)
        cameraAnimationsManager.easeToStub.reset()

        // verify that the camera was not set
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)

        // exercise the observation handler again and
        // verify that it returns true (to continue receiving updates)
        XCTAssertTrue(observeHandler(cameraOptions1))

        // verify that no further animation was started
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 0)

        // verify that the camera was not set
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.count, 0)

        // invoke the animation completion block
        easeToCompletion(.random())

        // exercise the observation handler again and
        // verify that it returns true (to continue receiving updates)
        XCTAssertTrue(observeHandler(cameraOptions2))

        // verify that no further animation was started
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 0)

        // verify that the camera was set
        XCTAssertEqual(mapboxMap.setCameraStub.invocations.map(\.parameters), [cameraOptions2])

        // stop updates
        state.stopUpdatingCamera()

        // verify that the observe cancelable and animation cancelable are both canceled
        assertMethodCall(observeCancelable.cancelStub)
        assertMethodCall(easeToCancelable.cancelStub)
    }

    func testStartUpdatingMultipleTimesDoesNothing() {
        state.startUpdatingCamera()
        state.startUpdatingCamera()

        // only one observation is created
        assertMethodCall(dataSource.observeStub)
    }

    func testRestartingUpdates() {
        state.startUpdatingCamera()
        state.stopUpdatingCamera()
        dataSource.observeStub.reset()

        // restart
        state.startUpdatingCamera()

        // a new observation is created
        assertMethodCall(dataSource.observeStub)
    }
}
