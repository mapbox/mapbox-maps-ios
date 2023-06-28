import XCTest
@testable @_spi(Package) import MapboxMaps

final class FollowPuckViewportStateDataSourceTests: XCTestCase {

    var options: FollowPuckViewportStateOptions!
    var observableCameraOptions: MockObservableCameraOptions!
    var dataSource: FollowPuckViewportStateDataSource!
    var onPuckRenderSubject: SignalSubject<PuckRenderingData>!

    override func setUp() {
        super.setUp()
        options = .random()
        observableCameraOptions = MockObservableCameraOptions()
        onPuckRenderSubject = .init()
        dataSource = FollowPuckViewportStateDataSource(
            options: options,
            onPuckRender: onPuckRenderSubject.signal,
            observableCameraOptions: observableCameraOptions)
    }

    override func tearDown() {
        onPuckRenderSubject = nil
        dataSource = nil
        observableCameraOptions = nil
        options = nil
        super.tearDown()
    }

    func updateRenderingData() -> PuckRenderingData {
        let data = PuckRenderingData.random()
        onPuckRenderSubject.send(data)
        return data
    }

    func makeExpectedCamera(data: PuckRenderingData, options: FollowPuckViewportStateOptions) -> CameraOptions {
        return CameraOptions(
            center: data.location.coordinate,
            padding: options.padding,
            zoom: options.zoom,
            bearing: options.bearing?.evaluate(with: data),
            pitch: options.pitch)
    }

    func testOptionsInitialValue() {
        XCTAssertEqual(dataSource.options, options)
    }

    func testSettingOptionsWithoutLatestLocation() {
        let newOptions = FollowPuckViewportStateOptions.random()
        dataSource.options = newOptions

        XCTAssertTrue(observableCameraOptions.notifyStub.invocations.isEmpty)

        // new options used to calculate camera when location updates come in
        let data = updateRenderingData()

        let expectedCamera = makeExpectedCamera(data: data, options: newOptions)
        XCTAssertEqual(observableCameraOptions.notifyStub.invocations.map(\.parameters), [expectedCamera])
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

    func testLocationUpdateNotifiesObservers() {
        let data = updateRenderingData()

        let expectedCamera = makeExpectedCamera(data: data, options: options)
        XCTAssertEqual(observableCameraOptions.notifyStub.invocations.map(\.parameters), [expectedCamera])
    }
}
