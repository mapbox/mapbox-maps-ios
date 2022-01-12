import XCTest
@testable import MapboxMaps

final class FollowingViewportStateDataSourceTests: XCTestCase {

    var options: FollowingViewportStateOptions!
    var locationProducer: MockLocationProducer!
    var observableCameraOptions: MockObservableCameraOptions!
    var dataSource: FollowingViewportStateDataSource!

    override func setUp() {
        super.setUp()
        options = .random()
        locationProducer = MockLocationProducer()
        observableCameraOptions = MockObservableCameraOptions()
        dataSource = FollowingViewportStateDataSource(
            options: options,
            locationProducer: locationProducer,
            observableCameraOptions: observableCameraOptions)
    }

    override func tearDown() {
        dataSource = nil
        observableCameraOptions = nil
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
            padding: options.padding,
            zoom: options.zoom,
            bearing: options.bearing.evaluate(with: location),
            pitch: options.pitch)
    }

    func testOptionsInitialValue() {
        XCTAssertEqual(dataSource.options, options)
    }

    func testSettingOptionsWithoutLatestLocation() throws {
        let newOptions = FollowingViewportStateOptions.random()
        dataSource.options = newOptions

        XCTAssertTrue(observableCameraOptions.notifyStub.invocations.isEmpty)

        // new options used to calculate camera when location updates come in
        let location = try updateLocation()

        let expectedCamera = makeExpectedCamera(location: location, options: newOptions)
        XCTAssertEqual(observableCameraOptions.notifyStub.invocations.map(\.parameters), [expectedCamera])
    }

    func testSettingOptionsWithLatestLocationNotifiesObservers() throws {
        let location = try updateLocation()
        let newOptions = FollowingViewportStateOptions.random()
        let expectedCameraOptions = makeExpectedCamera(location: location, options: newOptions)
        observableCameraOptions.notifyStub.reset()

        dataSource.options = newOptions

        XCTAssertEqual(observableCameraOptions.notifyStub.invocations.map(\.parameters), [expectedCameraOptions])
    }

    func testObserve() throws {
        let handlerStub = Stub<CameraOptions, Bool>(defaultReturnValue: .random())

        let cancelable = dataSource.observe(with: handlerStub.call(with:))

        XCTAssertEqual(observableCameraOptions.observeStub.invocations.count, 1)
        let observeInvocation = try XCTUnwrap(observableCameraOptions.observeStub.invocations.first)

        // verify that when the handler passed to the internal observable is invoked
        // the one passed in externally is as well.
        let handler = observeInvocation.parameters
        let cameraOptions = CameraOptions.random()

        let result = handler(cameraOptions)

        XCTAssertEqual(handlerStub.invocations.map(\.parameters), [cameraOptions])
        XCTAssertEqual(handlerStub.invocations.map(\.returnValue), [result])

        // verify that canceling the returned cancelable also cancels
        // the one returned by the call to the internal observable. They could
        // be the same cancelable, but writing the test to avoid that
        // assumption should make refactoring easier.
        let observeCancelable = try XCTUnwrap(observeInvocation.returnValue as? MockCancelable)

        cancelable.cancel()

        XCTAssertEqual(observeCancelable.cancelStub.invocations.count, 1)
    }

    func testLocationUpdateNotifiesObservers() throws {
        let location = try updateLocation()

        let expectedCamera = makeExpectedCamera(location: location, options: options)
        XCTAssertEqual(observableCameraOptions.notifyStub.invocations.map(\.parameters), [expectedCamera])
    }
}
