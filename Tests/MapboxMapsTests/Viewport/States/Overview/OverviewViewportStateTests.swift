import XCTest
@testable @_spi(Experimental) import MapboxMaps

final class OverviewViewportStateTest: XCTestCase {
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var observableCameraOptions: MockObservableCameraOptions!
    var state: OverviewViewportState!

    override func setUp() {
        super.setUp()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        observableCameraOptions = MockObservableCameraOptions()
        state = OverviewViewportState(
            options: .random(),
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager,
            observableCameraOptions: observableCameraOptions)
    }

    override func tearDown() {
        state = nil
        observableCameraOptions = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        super.tearDown()
    }

    func verifyEaseTo(with expectedCamera: CameraOptions) throws -> MockCancelable {
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        let easeToInvocation = try XCTUnwrap(cameraAnimationsManager.easeToStub.invocations.first)
        XCTAssertEqual(easeToInvocation.parameters.camera, expectedCamera)
        XCTAssertEqual(easeToInvocation.parameters.duration,
                       max(0, state.options.animationDuration))
        XCTAssertEqual(easeToInvocation.parameters.curve, .linear)
        XCTAssertNil(easeToInvocation.parameters.completion)
        return try XCTUnwrap(easeToInvocation.returnValue as? MockCancelable)
    }

    func verifyCameraOptionsUpdate(with options: OverviewViewportStateOptions) throws {
        XCTAssertEqual(mapboxMap.cameraForGeometryStub.invocations.count, 1)
        let cameraForInvocation = try XCTUnwrap(mapboxMap.cameraForGeometryStub.invocations.first)
        XCTAssertEqual(cameraForInvocation.parameters.geometry, options.geometry)
        XCTAssertEqual(cameraForInvocation.parameters.padding, options.padding)
        XCTAssertEqual(cameraForInvocation.parameters.bearing, options.bearing.map(CGFloat.init(_:)))
        XCTAssertEqual(cameraForInvocation.parameters.pitch, options.pitch)

        XCTAssertEqual(observableCameraOptions.notifyStub.invocations.map(\.parameters), [cameraForInvocation.returnValue])
    }

    func testSetOptionsRecalculatesCameraOptions() throws {
        mapboxMap.cameraForGeometryStub.reset()
        observableCameraOptions.notifyStub.reset()
        let newOptions = OverviewViewportStateOptions.random()

        state.options = newOptions

        try verifyCameraOptionsUpdate(with: newOptions)
    }

    func testInitializesObservableCameraOptions() throws {
        try verifyCameraOptionsUpdate(with: state.options)
    }

    func testObserveDataSource() throws {
        let handlerStub = Stub<CameraOptions, Bool>(defaultReturnValue: .random())

        let cancelable = state.observeDataSource(with: handlerStub.call(with:))

        XCTAssertEqual(observableCameraOptions.observeStub.invocations.count, 1)
        let observableCameraOptionsInvocation = try XCTUnwrap(observableCameraOptions.observeStub.invocations.first)

        // verify that when the handler passed to the internal observableCameraOptions is invoked
        // the one passed in externally is as well.
        let handler = observableCameraOptionsInvocation.parameters
        let cameraOptions = CameraOptions.random()

        let result = handler(cameraOptions)

        XCTAssertEqual(handlerStub.invocations.map(\.parameters), [cameraOptions])
        XCTAssertEqual(handlerStub.invocations.map(\.returnValue), [result])

        // verify that canceling the returned cancelable also cancels
        // the one returned by the call to the internal observableCameraOptions. They could
        // be the same cancelable, but writing the test to avoid that
        // assumption should make refactoring easier.
        let observeCancelable = try XCTUnwrap(observableCameraOptionsInvocation.returnValue as? MockCancelable)

        cancelable.cancel()

        XCTAssertEqual(observeCancelable.cancelStub.invocations.count, 1)
    }

    func testStartAndStopUpdatingCamera() throws {
        let cameraOptions = CameraOptions.random()
        state.startUpdatingCamera()

        // verify that an observation was created
        XCTAssertEqual(observableCameraOptions.observeStub.invocations.count, 1)
        let observableCameraOptionsInvocation = try XCTUnwrap(observableCameraOptions.observeStub.invocations.first)
        let observeHandler = observableCameraOptionsInvocation.parameters
        let observeCancelable = try XCTUnwrap(observableCameraOptionsInvocation.returnValue as? MockCancelable)

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
        XCTAssertEqual(observableCameraOptions.observeStub.invocations.count, 1)
    }

    func testRestartingUpdates() {
        state.startUpdatingCamera()
        state.stopUpdatingCamera()
        observableCameraOptions.observeStub.reset()

        // restart
        state.startUpdatingCamera()

        // a new observation is created
        XCTAssertEqual(observableCameraOptions.observeStub.invocations.count, 1)
    }
}
