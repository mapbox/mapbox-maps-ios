import XCTest
@testable import MapboxMaps

final class FollowingViewportStateTest: XCTestCase {
    var options: FollowingViewportStateOptions!
    var locationProducer: MockLocationProducer!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var state: FollowingViewportState!

    override func setUp() {
        super.setUp()
        options = .random()
        locationProducer = MockLocationProducer()
        cameraAnimationsManager = MockCameraAnimationsManager()
        state = FollowingViewportState(
            options: options,
            locationProducer: locationProducer,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    override func tearDown() {
        state = nil
        cameraAnimationsManager = nil
        locationProducer = nil
        options = nil
        super.tearDown()
    }

    @discardableResult
    func updateLocation() throws -> Location {
        let consumer = try XCTUnwrap(locationProducer.addStub.invocations.first?.parameters)
        let location = Location.random()
        consumer.locationUpdate(newLocation: location)
        return location
    }

    func makeExpectedCamera(location: Location, options: FollowingViewportStateOptions) -> CameraOptions {
        return CameraOptions(
            center: location.location.coordinate,
            zoom: options.zoom,
            bearing: options.bearing.evaluate(with: location),
            pitch: options.pitch)
    }

    func verifyEaseTo(for location: Location, options: FollowingViewportStateOptions) throws {
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 1)
        let easeToInvocation = try XCTUnwrap(cameraAnimationsManager.easeToStub.invocations.first)
        let expectedCamera = makeExpectedCamera(location: location, options: options)
        XCTAssertEqual(easeToInvocation.parameters.camera, expectedCamera)
        XCTAssertEqual(easeToInvocation.parameters.duration, 1)
        XCTAssertEqual(easeToInvocation.parameters.curve, .linear)
        XCTAssertNil(easeToInvocation.parameters.completion)
    }

    func testOptionsInitialization() {
        XCTAssertEqual(state.options, options)
    }

    func testStartsConsumingLocationsUponInitialization() {
        XCTAssertEqual(locationProducer.addStub.invocations.count, 1)
    }

    func testUpdatingOptionsWithoutLocationDoesNotSendUpdates() {
        let handlerStub = Stub<CameraOptions, Bool>(defaultReturnValue: true)
        _ = state.observeDataSource(with: handlerStub.call(with:))
        state.startUpdatingCamera()
        let newOptions = FollowingViewportStateOptions.random()

        state.options = newOptions

        XCTAssertEqual(state.options, newOptions)
        XCTAssertTrue(handlerStub.invocations.isEmpty)
        XCTAssertTrue(cameraAnimationsManager.easeToStub.invocations.isEmpty)
    }

    func testUpdatingOptionsWithLocationDoesSendUpdates() throws {
        let handlerStub = Stub<CameraOptions, Bool>(defaultReturnValue: true)
        _ = state.observeDataSource(with: handlerStub.call(with:))
        state.startUpdatingCamera()
        let location = try updateLocation()
        handlerStub.reset()
        cameraAnimationsManager.easeToStub.reset()
        let newOptions = FollowingViewportStateOptions.random()

        state.options = newOptions

        XCTAssertEqual(state.options, newOptions)
        let expectedCamera = makeExpectedCamera(location: location, options: newOptions)
        XCTAssertEqual(handlerStub.invocations.map(\.parameters), [expectedCamera])
        try verifyEaseTo(for: location, options: newOptions)
    }

    func testObserveDataSourceWithoutLatestLocation() {
        let handlerStub = Stub<CameraOptions, Bool>(defaultReturnValue: true)

        _ = state.observeDataSource(with: handlerStub.call(with:))

        XCTAssertTrue(handlerStub.invocations.isEmpty)
    }

    func testObserveDataSourceWithLatestLocation() throws {
        let handlerStub = Stub<CameraOptions, Bool>(defaultReturnValue: true)
        try updateLocation()

        _ = state.observeDataSource(with: handlerStub.call(with:))

        XCTAssertEqual(handlerStub.invocations.count, 1)
    }

    func testObserveDataSourceHandlesLocationUpdate() throws {
        let handlerStub = Stub<CameraOptions, Bool>(defaultReturnValue: true)
        _ = state.observeDataSource(with: handlerStub.call(with:))

        let location = try updateLocation()

        let expectedCamera = makeExpectedCamera(location: location, options: options)
        XCTAssertEqual(handlerStub.invocations.map(\.parameters), [expectedCamera])
    }

    func testObserveDataSourceCancelable() throws {
        let handlerStub = Stub<CameraOptions, Bool>(defaultReturnValue: true)
        let cancelable = state.observeDataSource(with: handlerStub.call(with:))

        cancelable.cancel()

        try updateLocation()
        XCTAssertTrue(handlerStub.invocations.isEmpty)
    }

    func testObserveDataSourceCancelsByReturningFalse() throws {
        let handlerStub = Stub<CameraOptions, Bool>(defaultReturnValue: false)
        _ = state.observeDataSource(with: handlerStub.call(with:))
        // handler returns false
        try updateLocation()
        handlerStub.reset()

        // subsequent invocation should not be delivered to handler
        try updateLocation()

        XCTAssertTrue(handlerStub.invocations.isEmpty)
    }

    func testObserveDataSourceCancelsContinuesWhenReturningTrue() throws {
        let handlerStub = Stub<CameraOptions, Bool>(defaultReturnValue: true)
        _ = state.observeDataSource(with: handlerStub.call(with:))
        // handler returns true
        try updateLocation()
        handlerStub.reset()

        // subsequent invocation should be delivered to handler
        let location = try updateLocation()

        let expectedCamera = makeExpectedCamera(location: location, options: options)
        XCTAssertEqual(handlerStub.invocations.map(\.parameters), [expectedCamera])
    }

    func testStartUpdatingWithoutLatestLocation() {
        state.startUpdatingCamera()

        XCTAssertTrue(cameraAnimationsManager.easeToStub.invocations.isEmpty)
    }

    func testStartUpdatingWithLatestLocation() throws {
        let location = try updateLocation()

        state.startUpdatingCamera()

        try verifyEaseTo(for: location, options: options)
    }

    func testStartUpdatingHandlesLocationUpdate() throws {
        state.startUpdatingCamera()

        let location = try updateLocation()

        try verifyEaseTo(for: location, options: options)
    }

    func testMultipleLocationUpdates() throws {
        state.startUpdatingCamera()

        try verifyEaseTo(for: updateLocation(), options: options)
        cameraAnimationsManager.easeToStub.reset()
        try verifyEaseTo(for: updateLocation(), options: options)
    }

    func testStopUpdating() throws {
        state.startUpdatingCamera()

        try updateLocation()

        let easeToInvocation = try XCTUnwrap(cameraAnimationsManager.easeToStub.invocations.first)
        let easeToCancelable = try XCTUnwrap(easeToInvocation.returnValue as? MockCancelable)
        cameraAnimationsManager.easeToStub.reset()

        state.stopUpdatingCamera()

        XCTAssertEqual(easeToCancelable.cancelStub.invocations.count, 1)

        try updateLocation()

        XCTAssertTrue(cameraAnimationsManager.easeToStub.invocations.isEmpty)
    }

    func testMultipleStartsAndStops() throws {
        state.startUpdatingCamera()
        state.startUpdatingCamera()

        try verifyEaseTo(for: updateLocation(), options: options)
        cameraAnimationsManager.easeToStub.reset()

        state.startUpdatingCamera()

        XCTAssertTrue(cameraAnimationsManager.easeToStub.invocations.isEmpty)

        state.stopUpdatingCamera()
        state.stopUpdatingCamera()

        let location = try updateLocation()

        XCTAssertTrue(cameraAnimationsManager.easeToStub.invocations.isEmpty)

        state.startUpdatingCamera()
        state.startUpdatingCamera()

        try verifyEaseTo(for: location, options: options)
    }

    func testUpdatingAndMultipleObservers() throws {
        let handlerStub1 = Stub<CameraOptions, Bool>(defaultReturnValue: false)
        _ = state.observeDataSource(with: handlerStub1.call(with:))

        let handlerStub2 = Stub<CameraOptions, Bool>(defaultReturnValue: true)
        let cancelable = state.observeDataSource(with: handlerStub2.call(with:))

        state.startUpdatingCamera()

        let handlerStub3 = Stub<CameraOptions, Bool>(defaultReturnValue: true)
        _ = state.observeDataSource(with: handlerStub3.call(with:))

        try updateLocation()

        try updateLocation()

        cancelable.cancel()

        try updateLocation()

        state.stopUpdatingCamera()

        try updateLocation()

        XCTAssertEqual(handlerStub1.invocations.count, 1)
        XCTAssertEqual(handlerStub2.invocations.count, 2)
        XCTAssertEqual(cameraAnimationsManager.easeToStub.invocations.count, 3)
        XCTAssertEqual(handlerStub3.invocations.count, 4)
    }
}
