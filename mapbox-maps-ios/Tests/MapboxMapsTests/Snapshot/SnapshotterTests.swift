import XCTest
@testable import MapboxMaps
@_implementationOnly import MapboxCoreMaps_Private
@_implementationOnly import MapboxCommon_Private
import CoreLocation

final class SnapshotterTests: XCTestCase {

    var mapboxObservableProviderStub: Stub<ObservableProtocol, MapboxObservableProtocol>!
    var snapshotter: Snapshotter!
    var mockMapSnapshotter: MockMapSnapshotter!

    override func setUp() {
        super.setUp()
        let options = MapSnapshotOptions(
            size: CGSize(width: 100, height: 100),
            pixelRatio: .random(in: 1...3))
        mapboxObservableProviderStub = Stub(defaultReturnValue: MockMapboxObservable())
        mockMapSnapshotter = MockMapSnapshotter()
        snapshotter = Snapshotter(
            options: options,
            mapboxObservableProvider: mapboxObservableProviderStub.call(with:),
            mapSnapshotter: mockMapSnapshotter)
    }

    override func tearDown() {
        snapshotter = nil
        mapboxObservableProviderStub = nil
        mockMapSnapshotter = nil
        super.tearDown()
    }

    func testSnapshotterCompletionInvocationFailed() {

        let options = MapSnapshotOptions(size: CGSize.init(width: 300, height: 300), pixelRatio: 2)

        let resultString = "FAILED"
        mockMapSnapshotter.startStub.defaultSideEffect = { invocation in
            invocation.parameters(Expected(error: resultString as NSString))
        }

        snapshotter.start(overlayHandler: nil) { (result) in
            XCTAssertNotNil(self.mockMapSnapshotter.startStub.defaultReturnValue)

            if case .success = result {
              XCTFail("Expect a failure")
            }
            XCTAssertEqual(self.mockMapSnapshotter.startStub.invocations.count, 1)
        }
    }

    func testSnapshotterCancel() {
        snapshotter.cancel()
        XCTAssertEqual(mockMapSnapshotter.cancelSnapshotterStub.invocations.count, 1)
    }

    func testSnapshotterSize() {
        let size = CGSize(width: 200, height: 200)

        snapshotter.snapshotSize = size
        mockMapSnapshotter.getSizeStub.defaultReturnValue = Size(size)

        XCTAssertEqual(snapshotter.snapshotSize, size)
        XCTAssertEqual(mockMapSnapshotter.getSizeStub.invocations.count, 1)
        XCTAssertEqual(mockMapSnapshotter.setSizeStub.invocations[0].parameters, Size(size))
    }

    func testSnapshotterTileMode() {

        snapshotter.tileMode = true

        XCTAssertEqual(mockMapSnapshotter.setTileModeStub.invocations.count, 1)
        XCTAssertEqual(snapshotter.tileMode, mockMapSnapshotter.isInTileMode())
    }

    func testSnapshotterSetCamera() {
        let center = CLLocationCoordinate2D(latitude: 38, longitude: -76)
        let padding = UIEdgeInsets.zero
        let anchor = CGPoint.zero
        let zoom = 15.0
        let bearing = CLLocationDirection.zero
        let pitch = 90.0
        let cameraOptions = CameraOptions(
            center: center,
            padding: padding,
            anchor: anchor,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch)

        snapshotter.setCamera(to: cameraOptions)

        XCTAssertEqual(mockMapSnapshotter.setCameraStub.invocations.count, 1)
        XCTAssertEqual(CameraOptions(mockMapSnapshotter.setCameraStub.invocations[0].parameters), cameraOptions)
    }

    //Test snapshot coordinate bounds for camera match those of mock
    func testSnapshotterCoordinateBoundsForCamera() {
        let center = CLLocationCoordinate2D(latitude: 38, longitude: -76)
        let padding = UIEdgeInsets.zero
        let anchor = CGPoint.zero
        let zoom = 15.0
        let bearing = 45.0
        let pitch = 90.0
        let cameraOptions = CameraOptions(center: center, padding: padding, anchor: anchor, zoom: zoom, bearing: bearing, pitch: pitch)

        let coordinateBounds = CoordinateBounds(southwest: .random(), northeast: .random())
        mockMapSnapshotter.coordinateBoundsForCameraStub.defaultReturnValue = coordinateBounds

        let returnedCoordinateBounds = snapshotter.coordinateBounds(for: cameraOptions)

        XCTAssertEqual(mockMapSnapshotter.coordinateBoundsForCameraStub.invocations.count, 1)
        XCTAssertEqual(
            CameraOptions(mockMapSnapshotter.coordinateBoundsForCameraStub.invocations[0].parameters),
            cameraOptions
        )
        XCTAssertEqual(coordinateBounds, returnedCoordinateBounds)
    }

    func testSnapshotterCameraforCoordinateBounds() {
        // verify that return value for snapshotter matches return value for mock: coordinateBounds
        let coordinates = [
            CLLocationCoordinate2D(latitude: 44.9753911881, longitude: -124.3348229758),
            CLLocationCoordinate2D(latitude: 48.9862916537, longitude: -124.3635392111),
            CLLocationCoordinate2D(latitude: 49.0163313873, longitude: -114.9828959018),
            CLLocationCoordinate2D(latitude: 45.0077739132, longitude: -114.9541796666),
            CLLocationCoordinate2D(latitude: 44.9753911881, longitude: -124.3348229758)
        ]
        let center = CLLocationCoordinate2D(latitude: 38, longitude: -76)
        let padding = EdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        let anchor = CGPoint.zero
        let zoom = 15.0
        let bearing = 45.0
        let pitch = 90.0

        let cameraOptions = CameraOptions(center: center, padding: padding.toUIEdgeInsetsValue(), anchor: anchor, zoom: zoom, bearing: CLLocationDirection(bearing), pitch: CGFloat(pitch))
        mockMapSnapshotter.cameraForCoordinatesStub.defaultReturnValue = MapboxCoreMaps.CameraOptions(cameraOptions)

        let returnedOptions = snapshotter.camera(for: coordinates, padding: padding.toUIEdgeInsetsValue(), bearing: bearing, pitch: pitch)

        XCTAssertEqual(mockMapSnapshotter.cameraForCoordinatesStub.invocations.count, 1)

        let mockParameters = mockMapSnapshotter.cameraForCoordinatesStub.invocations[0].parameters

        XCTAssertEqual(mockParameters.coordinates.map(\.coordinate), coordinates)
        XCTAssertEqual(mockParameters.padding.toUIEdgeInsetsValue(), padding.toUIEdgeInsetsValue())
        XCTAssertEqual(mockParameters.bearing, bearing.NSNumber)
        XCTAssertEqual(mockParameters.pitch, pitch.NSNumber)
        XCTAssertEqual(returnedOptions, cameraOptions)
    }

    func testInitializationMapboxObservable() {
        XCTAssertEqual(mapboxObservableProviderStub.invocations.count, 1)
        XCTAssertIdentical(mapboxObservableProviderStub.invocations.first?.parameters, snapshotter.mapSnapshotter)
    }

    func testSubscribe() throws {
        let observer = MockObserver()
        let events: [String] = .random()
        let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

        snapshotter.subscribe(observer, events: events)

        XCTAssertEqual(mapboxObservable.subscribeStub.invocations.count, 1)
        XCTAssertIdentical(mapboxObservable.subscribeStub.invocations.first?.parameters.observer, observer)
        XCTAssertEqual(mapboxObservable.subscribeStub.invocations.first?.parameters.events, events)
    }

    func testUnsubscribe() throws {
        let observer = MockObserver()
        let events: [String] = .random()
        let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

        snapshotter.unsubscribe(observer, events: events)

        XCTAssertEqual(mapboxObservable.unsubscribeStub.invocations.count, 1)
        XCTAssertIdentical(mapboxObservable.unsubscribeStub.invocations.first?.parameters.observer, observer)
        XCTAssertEqual(mapboxObservable.unsubscribeStub.invocations.first?.parameters.events, events)
    }

    @available(*, deprecated)
    func testOnNext() throws {
        let handlerStub = Stub<MapboxCoreMaps.Event, Void>()
        let eventType = MapEvents.EventKind.allCases.randomElement()!
        let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

        snapshotter.onNext(eventType, handler: handlerStub.call(with:))

        XCTAssertEqual(mapboxObservable.onNextStub.invocations.count, 1)
        XCTAssertEqual(mapboxObservable.onNextStub.invocations.first?.parameters.eventTypes, [eventType])
        // To verify that the handler passed to Snapshotter is effectively the same as the one received by MapboxObservable,
        // we exercise the received handler and verify that the passed one is invoked. If blocks were identifiable, maybe
        // we'd just write this as `passedHandler === receivedHandler`.
        let handler = try XCTUnwrap(mapboxObservable.onNextStub.invocations.first?.parameters.handler)
        let event = Event(type: "", data: 0)
        handler(event)
        XCTAssertEqual(handlerStub.invocations.count, 1)
        XCTAssertIdentical(handlerStub.invocations.first?.parameters, event)
    }

    func testOnTypedNext() throws {
        func verifyInvocation<Payload>(
            eventType: MapEvents.Event<Payload>,
            event: MapEvent<Payload> = .init(event: Event(type: "", data: 0)),
            handlerStub: Stub<MapEvent<Payload>, Void> = .init()
        ) throws {
            let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

            snapshotter.onNext(event: eventType, handler: handlerStub.call(with:))

            XCTAssertEqual(mapboxObservable.onTypedNextStub.invocations.count, 1)
            XCTAssertEqual(mapboxObservable.onTypedNextStub.invocations.first?.parameters.eventName, eventType.name)
            // To verify that the handler passed to Snapshotter is effectively the same as the one received by MapboxObservable,
            // we exercise the received handler and verify that the passed one is invoked. If blocks were identifiable, maybe
            // we'd just write this as `passedHandler === receivedHandler`.
            let handler = try XCTUnwrap(mapboxObservable.onTypedNextStub.invocations.first?.parameters.handler)
            handler(event)
            XCTAssertEqual(handlerStub.invocations.count, 1)
            XCTAssertIdentical(handlerStub.invocations.first?.parameters, event)
        }

        // swiftlint:disable opening_brace
        let eventInvocations = [
            { try verifyInvocation(eventType: .mapLoaded) },
            { try verifyInvocation(eventType: .mapLoadingError) },
            { try verifyInvocation(eventType: .mapIdle) },
            { try verifyInvocation(eventType: .styleDataLoaded) },
            { try verifyInvocation(eventType: .styleLoaded) },
            { try verifyInvocation(eventType: .styleImageMissing) },
            { try verifyInvocation(eventType: .styleImageRemoveUnused) },
            { try verifyInvocation(eventType: .sourceDataLoaded) },
            { try verifyInvocation(eventType: .sourceAdded) },
            { try verifyInvocation(eventType: .sourceRemoved) },
            { try verifyInvocation(eventType: .renderFrameStarted) },
            { try verifyInvocation(eventType: .renderFrameFinished) },
            { try verifyInvocation(eventType: .cameraChanged) },
            { try verifyInvocation(eventType: .resourceRequest) }
        ]
        // swiftlint:enable opening_brace
        try eventInvocations.randomElement()!()
    }

    @available(*, deprecated)
    func testOnEvery() throws {
        let handlerStub = Stub<MapboxCoreMaps.Event, Void>()
        let eventType = MapEvents.EventKind.allCases.randomElement()!
        let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

        snapshotter.onEvery(eventType, handler: handlerStub.call(with:))

        XCTAssertEqual(mapboxObservable.onEveryStub.invocations.count, 1)
        XCTAssertEqual(mapboxObservable.onEveryStub.invocations.first?.parameters.eventTypes, [eventType])
        // To verify that the handler passed to Snapshotter is effectively the same as the one received by MapboxObservable,
        // we exercise the received handler and verify that the passed one is invoked. If blocks were identifiable, maybe
        // we'd just write this as `passedHandler === receivedHandler`.
        let handler = try XCTUnwrap(mapboxObservable.onEveryStub.invocations.first?.parameters.handler)
        let event = Event(type: "", data: 0)
        handler(event)
        XCTAssertEqual(handlerStub.invocations.count, 1)
        XCTAssertIdentical(handlerStub.invocations.first?.parameters, event)
    }

    func testOnTypedEvery() throws {
        func verifyInvocation<Payload>(
            eventType: MapEvents.Event<Payload>,
            event: MapEvent<Payload> = .init(event: Event(type: "", data: 0)),
            handlerStub: Stub<MapEvent<Payload>, Void> = .init()
        ) throws {
            let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

            snapshotter.onEvery(event: eventType, handler: handlerStub.call(with:))

            XCTAssertEqual(mapboxObservable.onTypedEveryStub.invocations.count, 1)
            XCTAssertEqual(mapboxObservable.onTypedEveryStub.invocations.first?.parameters.eventName, eventType.name)
            // To verify that the handler passed to Snapshotter is effectively the same as the one received by MapboxObservable,
            // we exercise the received handler and verify that the passed one is invoked. If blocks were identifiable, maybe
            // we'd just write this as `passedHandler === receivedHandler`.
            let handler = try XCTUnwrap(mapboxObservable.onTypedEveryStub.invocations.first?.parameters.handler)
            handler(event)
            XCTAssertEqual(handlerStub.invocations.count, 1)
            XCTAssertIdentical(handlerStub.invocations.first?.parameters, event)
        }

        // swiftlint:disable opening_brace
        let eventInvocations = [
            { try verifyInvocation(eventType: .mapLoaded) },
            { try verifyInvocation(eventType: .mapLoadingError) },
            { try verifyInvocation(eventType: .mapIdle) },
            { try verifyInvocation(eventType: .styleDataLoaded) },
            { try verifyInvocation(eventType: .styleLoaded) },
            { try verifyInvocation(eventType: .styleImageMissing) },
            { try verifyInvocation(eventType: .styleImageRemoveUnused) },
            { try verifyInvocation(eventType: .sourceDataLoaded) },
            { try verifyInvocation(eventType: .sourceAdded) },
            { try verifyInvocation(eventType: .sourceRemoved) },
            { try verifyInvocation(eventType: .renderFrameStarted) },
            { try verifyInvocation(eventType: .renderFrameFinished) },
            { try verifyInvocation(eventType: .cameraChanged) },
            { try verifyInvocation(eventType: .resourceRequest) }
        ]
        // swiftlint:enable opening_brace
        try eventInvocations.randomElement()!()
    }
}
