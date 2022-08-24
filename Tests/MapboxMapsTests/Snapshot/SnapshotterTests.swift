import XCTest
@testable import MapboxMaps
@_implementationOnly import MapboxCoreMaps_Private
@_implementationOnly import MapboxCommon_Private

final class SnapshotterTests: XCTestCase {

    var mapboxObservableProviderStub: Stub<ObservableProtocol, MapboxObservableProtocol>!
    var snapshotter: Snapshotter!
    var mockMapSnapshotter: MockMapSnapshotter!
    var mockMapSnapshot: MockMapSnapshot!

    override func setUp() {
        super.setUp()
        let options = MapSnapshotOptions(
            size: CGSize(width: 100, height: 100),
            pixelRatio: .random(in: 1...3))
        mapboxObservableProviderStub = Stub(defaultReturnValue: MockMapboxObservable())
        mockMapSnapshotter = MockMapSnapshotter()
        mockMapSnapshot = MockMapSnapshot()
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

    // Test snapshot start invokes mockMapSnapshotter startStub
    func testSnapshotterStartInvocation() {
        snapshotter.start(overlayHandler: nil) { (_) in
            XCTAssertNotNil(self.mockMapSnapshotter.startStub.defaultReturnValue)
        }

        XCTAssertEqual(mockMapSnapshotter.startStub.invocations.count, 1)
    }

    func testSnapshotterCompletionInvocationFailed() {
        //given
        let options = MapSnapshotOptions(size: CGSize.init(width: 300, height: 300), pixelRatio: 2)
        snapshotter = Snapshotter(options: options, mapboxObservableProvider: mapboxObservableProviderStub.call(with:), mapSnapshotter: mockMapSnapshotter)

        //grabbed the start stub for mockmapsnapshotter in comparison to snapshotter and verified that 
        let resultString = "FAILED"
        mockMapSnapshotter.startStub.defaultSideEffect = { invocation in
            invocation.parameters(Expected(error: resultString as NSString))
        }

        // given, when, then
        snapshotter.start(overlayHandler: nil) { (result) in
            switch result {
            case .failure:
                print("Successful test")

                break
            case .success:
                XCTFail()
            }
        }
    }

    func testSnapshotterOverlayHandler() {
        //given
        let options = MapSnapshotOptions(size: CGSize.init(width: 300.0, height: 300.0), pixelRatio: 2)
        snapshotter = Snapshotter(options: options, mapboxObservableProvider: mapboxObservableProviderStub.call(with:), mapSnapshotter: mockMapSnapshotter)

        //when
        let format = UIGraphicsImageRendererFormat()
        let scale = CGFloat(options.pixelRatio)
        format.scale = scale

        let mbxImage = mockMapSnapshot.image()
        guard let uiImage = UIImage(mbxImage: mbxImage, scale: scale) else {
            XCTFail("Could not convert internal Image type to UIImage.")
            return
        }

        let renderer = UIGraphicsImageRenderer(size: uiImage.size, format: format)

        let compositeImage = renderer.image { rendererContext in

            // First draw the snaphot image into the context
            let context = rendererContext.cgContext

            let mockPointForCoordinate = { (coordinate: CLLocationCoordinate2D) -> CGPoint in
                let screenCoordinate = self.mockMapSnapshot.screenCoordinate(for: coordinate)
                return CGPoint(x: screenCoordinate.x, y: screenCoordinate.y)
            }

            let mockCoordinateForPoint = { (point: CGPoint) -> CLLocationCoordinate2D in
                return self.mockMapSnapshot.coordinate(for: point.screenCoordinate)
            }

            let mockMapSnapshotOverlay = SnapshotOverlay(context: context,
                                                         scale: scale,
                                                         pointForCoordinate: mockPointForCoordinate,
                                                         coordinateForPoint: mockCoordinateForPoint)

            //        let resultString = "FAILED"
            mockMapSnapshotter.startStub.defaultSideEffect = { _ in
//                invocation.parameters(Expected(value: _))
            }

            snapshotter.start { overlay in
                print("UGH")
                XCTAssertEqual(mockMapSnapshotOverlay.context, overlay.context)
                XCTAssertNotNil(mockMapSnapshotOverlay)
            } completion: { (_) in
                // do nothing
            }
        }

//        if let overlayHandler = overlayHandler {
//            context.saveGState()
//            overlayHandler(overlay)
//            context.restoreGState()
//        }

    }

    func testSnapshotterCompletionStyleInvocation() {

        //given
        let options = MapSnapshotOptions(size: CGSize.init(width: 300, height: 300), pixelRatio: 2)
        snapshotter = Snapshotter(options: options, mapboxObservableProvider: mapboxObservableProviderStub.call(with:), mapSnapshotter: mockMapSnapshotter)
//
//        //grabbed the start stub for mockmapsnapshotter in comparison to snapshotter and verified that
//        let resultString = "FAILED"
        mockMapSnapshotter.startStub.defaultSideEffect = { _ in
//            invocation.parameters(Expected(value: _))
        }

        // when
        snapshotter.start { _ in
            XCTAssertNotNil(self.mockMapSnapshotter.style)
        } completion: { (_) in
            // do nothing
        }
    }

    func testSnapshotterCompletionStyleAttributionInvocation() {

        //given
        let options = MapSnapshotOptions(size: CGSize.init(width: 300, height: 300), pixelRatio: 2)
        snapshotter = Snapshotter(options: options, mapboxObservableProvider: mapboxObservableProviderStub.call(with:), mapSnapshotter: mockMapSnapshotter)

        mockMapSnapshotter.startStub.defaultSideEffect = { _ in
//            invocation.parameters(Expected(value: <#T##_#>))
        }

        // when
        snapshotter.start { _ in
            print("UGH")
            XCTAssertTrue(self.mockMapSnapshot.attributionStub.invocations.count > 0)
        } completion: { (_) in
            // do nothing
        }
    }

    func testSnapshotterCancel() {
        // given snapshot is cancelled
        snapshotter.cancel()
        // mockMapSnapshotter cancel snapshotter stub should equal that of snapshotter
        XCTAssertEqual(mockMapSnapshotter.cancelSnapshotterStub.invocations.count, 1)
    }

    func testSnapshotterSize() {
        let size = CGSize(width: 200, height: 200)

        snapshotter.mapSnapshotter.setSizeFor(.init(size))

        mockMapSnapshotter.getSizeStub.defaultReturnValue = Size(size)
        XCTAssertEqual(snapshotter.snapshotSize, size)

        snapshotter.snapshotSize = size
        XCTAssertEqual(mockMapSnapshotter.setSizeStub.invocations[0].parameters, Size(size))
    }

    func testSnapshotterTileMode() {

        snapshotter.mapSnapshotter.setTileModeForSet(true)

        XCTAssertEqual(mockMapSnapshotter.setTileModeStub.invocations.count, 1)
        XCTAssertEqual(snapshotter.tileMode, mockMapSnapshotter.isInTileMode())
    }

    func testSnapshotterSetCamera() {
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 38, longitude: -76), padding: .zero, anchor: .zero, zoom: 15, bearing: .zero, pitch: 90)
        let coreCameraOptions = MapboxCoreMaps.CameraOptions(cameraOptions)

        snapshotter.mapSnapshotter.setCameraFor(coreCameraOptions)

        XCTAssertEqual(mockMapSnapshotter.setCameraStub.invocations.count, 1)
        XCTAssertEqual(cameraOptions, mockMapSnapshotter.cameraOptions)
    }

    //Test snapshot coordinate bounds for camera match those of mock
    func testSnapshotterCoordinateBoundsForCamera() {
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 38, longitude: -76), padding: .zero, anchor: .zero, zoom: 15, bearing: .zero, pitch: 90)

        let coordinateBounds = snapshotter.mapSnapshotter.coordinateBoundsForCamera(forCamera: MapboxCoreMaps.CameraOptions(cameraOptions))

        XCTAssertEqual(mockMapSnapshotter.coordinateBoundsStub.invocations.count, 1)
        XCTAssertEqual(coordinateBounds, mockMapSnapshotter.coordinateBoundsStub.defaultReturnValue)
    }

    func testSnapshotterCameraforCoordinateBounds() {
        let coordinates = [
            CLLocation(latitude: 44.9753911881, longitude: -124.3348229758),
            CLLocation(latitude: 48.9862916537, longitude: -124.3635392111),
            CLLocation(latitude: 49.0163313873, longitude: -114.9828959018),
            CLLocation(latitude: 45.0077739132, longitude: -114.9541796666),
            CLLocation(latitude: 44.9753911881, longitude: -124.3348229758)
        ]

        let snapshotterCameraForCoordinates = snapshotter.mapSnapshotter.cameraForCoordinates(forCoordinates: coordinates, padding: EdgeInsets(top: 10, left: 10, bottom: 10, right: 10), bearing: 0, pitch: 0)

        XCTAssertEqual(mockMapSnapshotter.cameraForCoordinatesStub.invocations.count, 1)
        XCTAssertIdentical(snapshotterCameraForCoordinates, mockMapSnapshotter.cameraForCoordinatesStub.defaultReturnValue)
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
