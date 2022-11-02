import XCTest
@testable import MapboxMaps
@_implementationOnly import MapboxCoreMaps_Private

final class MapboxMapTests: XCTestCase {

    var mapClient: MockMapClient!
    var mapInitOptions: MapInitOptions!
    var mapboxObservableProviderStub: Stub<ObservableProtocol, MapboxObservableProtocol>!
    var mapboxMap: MapboxMap!

    override func setUp() {
        super.setUp()
        let size = CGSize(width: 100, height: 200)
        mapClient = MockMapClient()
        mapClient.getMetalViewStub.defaultReturnValue = MTKView(frame: CGRect(origin: .zero, size: size))
        mapInitOptions = MapInitOptions(mapOptions: MapOptions(size: size))
        mapboxObservableProviderStub = Stub(defaultReturnValue: MockMapboxObservable())
        mapboxMap = MapboxMap(
            mapClient: mapClient,
            mapInitOptions: mapInitOptions,
            mapboxObservableProvider: mapboxObservableProviderStub.call(with:))
    }

    override func tearDown() {
        mapboxMap = nil
        mapboxObservableProviderStub = nil
        mapInitOptions = nil
        mapClient = nil
        super.tearDown()
    }

    func testInitializationOfResourceOptions() {
        let actualResourceOptions = mapboxMap.resourceOptions
        XCTAssertEqual(actualResourceOptions, mapInitOptions.resourceOptions)
    }

    func testInitializationOfMapOptions() {
        let expectedMapOptions = MapOptions(
            __contextMode: nil,
            constrainMode: NSNumber(value: mapInitOptions.mapOptions.constrainMode.rawValue),
            viewportMode: mapInitOptions.mapOptions.viewportMode.map { NSNumber(value: $0.rawValue) },
            orientation: NSNumber(value: mapInitOptions.mapOptions.orientation.rawValue),
            crossSourceCollisions: mapInitOptions.mapOptions.crossSourceCollisions.NSNumber,
            optimizeForTerrain: mapInitOptions.mapOptions.optimizeForTerrain.NSNumber,
            size: mapInitOptions.mapOptions.size.map(Size.init),
            pixelRatio: mapInitOptions.mapOptions.pixelRatio,
            glyphsRasterizationOptions: nil) // __map.getOptions() always returns nil for glyphsRasterizationOptions

        let actualMapOptions = mapboxMap.options

        XCTAssertEqual(actualMapOptions, expectedMapOptions)
    }

    func testInitializationInvokesMapClientGetMetalView() {
        XCTAssertEqual(mapClient.getMetalViewStub.invocations.count, 1)
    }

    func testInitializationMapboxObservable() {
        XCTAssertEqual(mapboxObservableProviderStub.invocations.count, 1)
        XCTAssertIdentical(mapboxObservableProviderStub.invocations.first?.parameters, mapboxMap.__testingMap)
    }

    func testSetSize() {
        let expectedSize = CGSize(
            width: .random(in: 100...1000),
            height: .random(in: 100...1000))

        mapboxMap.size = expectedSize

        XCTAssertEqual(CGSize(mapboxMap.__testingMap.getSize()), expectedSize)
    }

    func testGetSize() {
        let expectedSize = Size(
            width: .random(in: 100...1000),
            height: .random(in: 100...1000))
        mapboxMap.__testingMap.setSizeFor(expectedSize)

        let actualSize = mapboxMap.size

        XCTAssertEqual(actualSize, CGSize(expectedSize))
    }

    func testGetCameraOptions() {
        XCTAssertEqual(mapboxMap.cameraState, CameraState(mapboxMap.__testingMap.getCameraState()))
    }

    func testCameraForCoordinateArray() {
        // A 1:1 square
        let southwest = CLLocationCoordinate2DMake(0, 0)
        let northwest = CLLocationCoordinate2DMake(4, 0)
        let northeast = CLLocationCoordinate2DMake(4, 4)
        let southeast = CLLocationCoordinate2DMake(0, 4)

        let latitudeDelta =  northeast.latitude - southeast.latitude
        let longitudeDelta = southeast.longitude - southwest.longitude

        let expectedCenter = CLLocationCoordinate2DMake(northeast.latitude - (latitudeDelta / 2),
                                                        southeast.longitude - (longitudeDelta / 2))

        let camera = mapboxMap.camera(
            for: [
                southwest,
                northwest,
                northeast,
                southeast
            ],
            padding: .zero,
            bearing: 0,
            pitch: 0)

        XCTAssertEqual(expectedCenter.latitude, camera.center!.latitude, accuracy: 0.25)
        XCTAssertEqual(expectedCenter.longitude, camera.center!.longitude, accuracy: 0.25)
        XCTAssertEqual(camera.bearing, 0)
        XCTAssertEqual(camera.padding, .zero)
        XCTAssertEqual(camera.pitch, 0)
    }

    func testCameraForGeometry() {
        // A 1:1 square
        let southwest = CLLocationCoordinate2DMake(0, 0)
        let northwest = CLLocationCoordinate2DMake(4, 0)
        let northeast = CLLocationCoordinate2DMake(4, 4)
        let southeast = CLLocationCoordinate2DMake(0, 4)

        let coordinates = [
            southwest,
            northwest,
            northeast,
            southeast,
        ]

        let latitudeDelta =  northeast.latitude - southeast.latitude
        let longitudeDelta = southeast.longitude - southwest.longitude

        let expectedCenter = CLLocationCoordinate2DMake(northeast.latitude - (latitudeDelta / 2),
                                                        southeast.longitude - (longitudeDelta / 2))

        let geometry = Geometry.polygon(Polygon([coordinates]))

        let camera = mapboxMap.camera(
            for: geometry,
            padding: .zero,
            bearing: 0,
            pitch: 0)

        XCTAssertEqual(expectedCenter.latitude, camera.center!.latitude, accuracy: 0.25)
        XCTAssertEqual(expectedCenter.longitude, camera.center!.longitude, accuracy: 0.25)
        XCTAssertEqual(camera.bearing, 0)
        XCTAssertEqual(camera.padding, .zero)
        XCTAssertEqual(camera.pitch, 0)
    }

    func testProtocolConformance() {
        // Compilation check only
        _ = mapboxMap as MapFeatureQueryable
        _ = mapboxMap as MapEventsObservable
    }

    func testBeginAndEndAnimation() {
        XCTAssertFalse(mapboxMap.__testingMap.isUserAnimationInProgress())

        mapboxMap.beginAnimation()

        XCTAssertTrue(mapboxMap.__testingMap.isUserAnimationInProgress())

        mapboxMap.beginAnimation()

        XCTAssertTrue(mapboxMap.__testingMap.isUserAnimationInProgress())

        mapboxMap.endAnimation()

        XCTAssertTrue(mapboxMap.__testingMap.isUserAnimationInProgress())

        mapboxMap.beginAnimation()

        XCTAssertTrue(mapboxMap.__testingMap.isUserAnimationInProgress())

        mapboxMap.endAnimation()

        XCTAssertTrue(mapboxMap.__testingMap.isUserAnimationInProgress())

        mapboxMap.endAnimation()

        XCTAssertFalse(mapboxMap.__testingMap.isUserAnimationInProgress())
    }

    func testBeginAndEndGesture() {
        XCTAssertFalse(mapboxMap.__testingMap.isGestureInProgress())

        mapboxMap.beginGesture()

        XCTAssertTrue(mapboxMap.__testingMap.isGestureInProgress())

        mapboxMap.beginGesture()

        XCTAssertTrue(mapboxMap.__testingMap.isGestureInProgress())

        mapboxMap.endGesture()

        XCTAssertTrue(mapboxMap.__testingMap.isGestureInProgress())

        mapboxMap.beginGesture()

        XCTAssertTrue(mapboxMap.__testingMap.isGestureInProgress())

        mapboxMap.endGesture()

        XCTAssertTrue(mapboxMap.__testingMap.isGestureInProgress())

        mapboxMap.endGesture()

        XCTAssertFalse(mapboxMap.__testingMap.isGestureInProgress())
    }

    func testSubscribe() throws {
        let observer = MockObserver()
        let events: [String] = .random()
        let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

        mapboxMap.subscribe(observer, events: events)

        XCTAssertEqual(mapboxObservable.subscribeStub.invocations.count, 1)
        XCTAssertIdentical(mapboxObservable.subscribeStub.invocations.first?.parameters.observer, observer)
        XCTAssertEqual(mapboxObservable.subscribeStub.invocations.first?.parameters.events, events)
    }

    func testUnsubscribe() throws {
        let observer = MockObserver()
        let events: [String] = .random()
        let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

        mapboxMap.unsubscribe(observer, events: events)

        XCTAssertEqual(mapboxObservable.unsubscribeStub.invocations.count, 1)
        XCTAssertIdentical(mapboxObservable.unsubscribeStub.invocations.first?.parameters.observer, observer)
        XCTAssertEqual(mapboxObservable.unsubscribeStub.invocations.first?.parameters.events, events)
    }

    func testLoadStyleHandlerIsInvokedExactlyOnce() throws {
        let styleLoadEventOccurred = expectation(description: "style-loaded event occurred")
        let mapLoadingErrorEventOccurred = expectation(description: "map-loading-error event occurred")
        let completionIsCalledOnce = expectation(description: "loadStyle completion should be called once")
        completionIsCalledOnce.assertForOverFulfill = true

        let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)
        mapboxObservable.onTypedNextStub.defaultSideEffect = { invocation in
            guard invocation.parameters.eventName == "style-loaded" else { return }

            let event = MapboxCoreMaps.Event(type: "style-loaded", data: NSNull())
            invocation.parameters.handler(MapEvent<NoPayload>(event: event))
            styleLoadEventOccurred.fulfill()
        }
        mapboxObservable.onTypedEveryStub.defaultSideEffect = { invocation in
            guard invocation.parameters.eventName == "map-loading-error" else { return }

            let event = MapboxCoreMaps.Event(
                type: "source",
                data: ["type": "source", "message": "Cannot load source", "source-id": "dummy-source-id"])
            invocation.parameters.handler(MapEvent<MapLoadingErrorPayload>(event: event))
            mapLoadingErrorEventOccurred.fulfill()
        }

        mapboxMap.loadStyleURI(.dark) { _ in
            completionIsCalledOnce.fulfill()
        }

        waitForExpectations(timeout: 0.3)
    }

    @available(*, deprecated)
    func testOnNext() throws {
        let handlerStub = Stub<Event, Void>()
        let eventType = MapEvents.EventKind.allCases.randomElement()!
        let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

        mapboxMap.onNext(eventType, handler: handlerStub.call(with:))

        XCTAssertEqual(mapboxObservable.onNextStub.invocations.count, 1)
        XCTAssertEqual(mapboxObservable.onNextStub.invocations.first?.parameters.eventTypes, [eventType])
        // To verify that the handler passed to MapboxMap is effectively the same as the one received by MapboxObservable,
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

            mapboxMap.onNext(event: eventType, handler: handlerStub.call(with:))

            XCTAssertEqual(mapboxObservable.onTypedNextStub.invocations.count, 1)
            XCTAssertEqual(mapboxObservable.onTypedNextStub.invocations.first?.parameters.eventName, eventType.name)
            // To verify that the handler passed to MapboxMap is effectively the same as the one received by MapboxObservable,
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
        let handlerStub = Stub<Event, Void>()
        let eventType = MapEvents.EventKind.allCases.randomElement()!
        let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

        mapboxMap.onEvery(eventType, handler: handlerStub.call(with:))

        XCTAssertEqual(mapboxObservable.onEveryStub.invocations.count, 1)
        XCTAssertEqual(mapboxObservable.onEveryStub.invocations.first?.parameters.eventTypes, [eventType])
        // To verify that the handler passed to MapboxMap is effectively the same as the one received by MapboxObservable,
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

            mapboxMap.onEvery(event: eventType, handler: handlerStub.call(with:))

            XCTAssertEqual(mapboxObservable.onTypedEveryStub.invocations.count, 1)
            XCTAssertEqual(mapboxObservable.onTypedEveryStub.invocations.first?.parameters.eventName, eventType.name)
            // To verify that the handler passed to MapboxMap is effectively the same as the one received by MapboxObservable,
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

    func testPerformWithoutNotifying() throws {
        let blockStub = Stub<Void, Void>()
        let mapboxObservable = try XCTUnwrap(mapboxObservableProviderStub.invocations.first?.returnValue as? MockMapboxObservable)

        mapboxMap.performWithoutNotifying(blockStub.call)

        XCTAssertEqual(mapboxObservable.performWithoutNotifyingInvocationCount, 1)
        XCTAssertEqual(blockStub.invocations.count, 1)
    }
}
