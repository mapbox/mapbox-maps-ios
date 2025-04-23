import XCTest
import MetalKit
@_spi(Experimental) @testable import MapboxMaps

final class MapboxMapTests: XCTestCase {

    var mapClient: MockMapClient!
    var mapInitOptions: MapInitOptions!
    var events: MapEvents!
    var mapboxMap: MapboxMap!

    // We don't store fooSubject strongly to test that MapEvents stores the subjects it created.
    weak private var fooGenericSubject: SignalSubject<GenericEvent>?

    override func setUp() {
        super.setUp()
        let size = CGSize(width: 100, height: 200)
        events = MapEvents(makeGenericSubject: { [weak self] eventName in
            let s = SignalSubject<GenericEvent>()
            if eventName == "foo" {
                if let fooSubject = self?.fooGenericSubject {
                    return fooSubject
                } else {
                    self?.fooGenericSubject = s
                    return s
                }
            }
            return s
        })
        mapClient = MockMapClient()
        mapClient.getMetalViewStub.defaultReturnValue = MetalView(frame: CGRect(origin: .zero, size: size), device: nil)
        mapInitOptions = MapInitOptions(mapOptions: MapOptions(size: size))

        let map = CoreMap(client: mapClient, mapOptions: mapInitOptions.mapOptions)
        mapboxMap = MapboxMap(map: map, events: events)
    }

    override func tearDown() {
        mapboxMap = nil
        mapInitOptions = nil
        mapClient = nil
        events = nil
        fooGenericSubject = nil
        super.tearDown()
    }

    func testInitializationOfMapOptions() {
        let expectedMapOptions = MapOptions(
            __contextMode: nil,
            constrainMode: NSNumber(value: mapInitOptions.mapOptions.constrainMode.rawValue),
            viewportMode: mapInitOptions.mapOptions.viewportMode.map { NSNumber(value: $0.rawValue) },
            orientation: NSNumber(value: mapInitOptions.mapOptions.orientation.rawValue),
            crossSourceCollisions: mapInitOptions.mapOptions.crossSourceCollisions.NSNumber,
            size: mapInitOptions.mapOptions.size.map(Size.init),
            pixelRatio: mapInitOptions.mapOptions.pixelRatio,
            glyphsRasterizationOptions: nil) // __map.getOptions() always returns nil for glyphsRasterizationOptions

        let actualMapOptions = mapboxMap.options

        XCTAssertEqual(actualMapOptions, expectedMapOptions)
    }

    func testInitializationInvokesMapClientGetMetalView() {
        XCTAssertEqual(mapClient.getMetalViewStub.invocations.count, 1)
    }

    func testSetSize() {
        let expectedSize = CGSize(
            width: 1000,
            height: 100)

        mapboxMap.size = expectedSize

        XCTAssertEqual(CGSize(mapboxMap.__testingMap.getSize()), expectedSize)
    }

    func testGetSize() {
        let expectedSize = Size(
            width: 124,
            height: 988)
        mapboxMap.__testingMap.setSizeFor(expectedSize)

        let actualSize = mapboxMap.size

        XCTAssertEqual(actualSize, CGSize(expectedSize))
    }

    func testGetRenderWorldCopies() {
        let renderWorldCopies = Bool.testConstantValue()
        mapboxMap.__testingMap.setRenderWorldCopiesForRenderWorldCopies(renderWorldCopies)
        XCTAssertEqual(mapboxMap.shouldRenderWorldCopies, renderWorldCopies)
    }

    func testSetRenderWorldCopies() {
        let renderWorldCopies = Bool.testConstantValue()
        mapboxMap.shouldRenderWorldCopies = renderWorldCopies
        XCTAssertEqual(mapboxMap.__testingMap.getRenderWorldCopies(), renderWorldCopies)
    }

    func testGetStyleGlyphURL() {
        let glyphURL = "test://test/test/{fontstack}/{range}.pbf"
        mapboxMap.__testingMap.setStyleGlyphURLForUrl(glyphURL)
        XCTAssertEqual(mapboxMap.styleGlyphURL, glyphURL)
    }

    func testSetStyleGlyphURL() {
        let glyphURL = "test://test/test/{fontstack}/{range}.pbf"
        mapboxMap.styleGlyphURL = glyphURL
        XCTAssertEqual(mapboxMap.__testingMap.getStyleGlyphURL(), glyphURL)
    }

    func testGetCameraOptions() {
        XCTAssertEqual(mapboxMap.cameraState, CameraState(mapboxMap.__testingMap.getCameraState()))
    }

    func testGetScreenCullingShape() {
        let screenCullingShape = [CGPoint(x: 0, y: 0.5), CGPoint(x: 0.3, y: 0), CGPoint(x: 0.7, y: 1)]
        mapboxMap.__testingMap.setScreenCullingShapeForShape(screenCullingShape.map(\.vec2))
        XCTAssertEqual(mapboxMap.screenCullingShape, screenCullingShape)
    }

    func testSetScreenCullingShape() {
        let screenCullingShape = [CGPoint(x: 0, y: 0.5), CGPoint(x: 0.3, y: 0), CGPoint(x: 0.7, y: 1)]
        mapboxMap.screenCullingShape = screenCullingShape
        XCTAssertEqual(mapboxMap.__testingMap.getScreenCullingShape(), screenCullingShape.map(\.vec2))
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
        XCTAssertNil(camera.padding)
        XCTAssertEqual(camera.pitch, 0)
    }

    func testCameraForCoordinateBounds() {
        let southwest = CLLocationCoordinate2DMake(0, 0)
        let northeast = CLLocationCoordinate2DMake(4, 4)
        let southeast = CLLocationCoordinate2DMake(0, 4)
        let latitudeDelta =  northeast.latitude - southeast.latitude
        let longitudeDelta = southeast.longitude - southwest.longitude
        let expectedCenter = CLLocationCoordinate2DMake(northeast.latitude - (latitudeDelta / 2), southeast.longitude - (longitudeDelta / 2))
        let coordinateBounds = CoordinateBounds(southwest: southwest, northeast: northeast)

        let camera = mapboxMap.camera(for: coordinateBounds,
                                      padding: .zero,
                                      bearing: 0,
                                      pitch: 0,
                                      maxZoom: 0,
                                      offset: nil)
        XCTAssertEqual(expectedCenter.latitude, camera.center!.latitude, accuracy: 0.25)
        XCTAssertEqual(expectedCenter.longitude, camera.center!.longitude, accuracy: 0.25)
        XCTAssertEqual(camera.bearing, 0)
        XCTAssertNil(camera.padding)
        XCTAssertEqual(camera.pitch, 0)
    }

    func testCameraForCoordinateBoundsWithValues() {
        let southwest = CLLocationCoordinate2DMake(0, 0)
        let northeast = CLLocationCoordinate2DMake(4, 4)
        let southeast = CLLocationCoordinate2DMake(0, 4)
        let latitudeDelta =  northeast.latitude - southeast.latitude
        let longitudeDelta = southeast.longitude - southwest.longitude
        let expectedCenter = CLLocationCoordinate2DMake(northeast.latitude - (latitudeDelta / 2), southeast.longitude - (longitudeDelta / 2))
        let coordinateBounds = CoordinateBounds(southwest: southwest, northeast: northeast)
        let screenCoordinate = CGPoint(x: 1.0, y: 2.0)

        let camera = mapboxMap.camera(for: coordinateBounds,
                                      padding: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
                                      bearing: 4,
                                      pitch: 65,
                                      maxZoom: 12,
                                      offset: screenCoordinate)
        XCTAssertEqual(expectedCenter.latitude, camera.center!.latitude, accuracy: 0.25)
        XCTAssertEqual(expectedCenter.longitude, camera.center!.longitude, accuracy: 0.25)
        XCTAssertEqual(camera.bearing, 4)
        XCTAssertNil(camera.padding)
        XCTAssertEqual(camera.pitch, 65)
    }

    func testCameraForCoordinates() throws {
        // A 1:1 square
        let southwest = CLLocationCoordinate2DMake(0, 0)
        let northwest = CLLocationCoordinate2DMake(4, 0)
        let northeast = CLLocationCoordinate2DMake(4, 4)
        let southeast = CLLocationCoordinate2DMake(0, 4)
        let latitudeDelta =  northeast.latitude - southeast.latitude
        let longitudeDelta = southeast.longitude - southwest.longitude

        let expectedCenter = CLLocationCoordinate2DMake(northeast.latitude - (latitudeDelta / 2),
                                                        southeast.longitude - (longitudeDelta / 2))
        let padding = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)

        let camera = try mapboxMap.camera(
            for: [
                southwest,
                northwest,
                northeast,
                southeast
            ],
            camera: CameraOptions(padding: padding),
            coordinatesPadding: nil,
            maxZoom: 100,
            offset: .zero
        )

        XCTAssertEqual(expectedCenter.latitude, camera.center!.latitude, accuracy: 0.25)
        XCTAssertEqual(expectedCenter.longitude, camera.center!.longitude, accuracy: 0.25)
        XCTAssertEqual(camera.bearing, 0)
        XCTAssertEqual(camera.padding, padding)
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
        XCTAssertNil(camera.padding)
        XCTAssertEqual(camera.pitch, 0)
    }

    func testProtocolConformance() {
        // Compilation check only
        _ = mapboxMap as MapFeatureQueryable
    }

    func testGetAnimationInProgressGetter() {
        XCTAssertFalse(mapboxMap.isAnimationInProgress)

        mapboxMap.__testingMap.setUserAnimationInProgressForInProgress(true)

        XCTAssertTrue(mapboxMap.isAnimationInProgress)
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

    func testGetGestureInProgressGetter() {
        XCTAssertFalse(mapboxMap.isGestureInProgress)

        mapboxMap.__testingMap.setGestureInProgressForInProgress(true)

        XCTAssertTrue(mapboxMap.isGestureInProgress)
    }

    func testBeginAndEndGesture() {
        XCTAssertFalse(mapboxMap.__testingMap.isGestureInProgress())
        XCTAssertEqual(mapboxMap.__testingMap.getCenterAltitudeMode(), .terrain)

        mapboxMap.beginGesture()

        XCTAssertTrue(mapboxMap.__testingMap.isGestureInProgress())
        XCTAssertEqual(mapboxMap.__testingMap.getCenterAltitudeMode(), .sea)

        mapboxMap.centerAltitudeMode = .terrain
        mapboxMap.beginGesture()

        XCTAssertTrue(mapboxMap.__testingMap.isGestureInProgress())
        XCTAssertEqual(mapboxMap.__testingMap.getCenterAltitudeMode(), .sea)

        mapboxMap.endGesture()

        XCTAssertTrue(mapboxMap.__testingMap.isGestureInProgress())
        XCTAssertEqual(mapboxMap.__testingMap.getCenterAltitudeMode(), .sea)

        mapboxMap.beginGesture()

        XCTAssertTrue(mapboxMap.__testingMap.isGestureInProgress())
        XCTAssertEqual(mapboxMap.__testingMap.getCenterAltitudeMode(), .sea)

        mapboxMap.endGesture()

        XCTAssertTrue(mapboxMap.__testingMap.isGestureInProgress())
        XCTAssertEqual(mapboxMap.__testingMap.getCenterAltitudeMode(), .sea)

        mapboxMap.endGesture()

        XCTAssertFalse(mapboxMap.__testingMap.isGestureInProgress())
        XCTAssertEqual(mapboxMap.__testingMap.getCenterAltitudeMode(), .terrain)

        mapboxMap.beginGesture()

        XCTAssertTrue(mapboxMap.__testingMap.isGestureInProgress())
        XCTAssertEqual(mapboxMap.__testingMap.getCenterAltitudeMode(), .sea)

        mapboxMap.centerAltitudeMode = .sea
        mapboxMap.endGesture()

        XCTAssertFalse(mapboxMap.__testingMap.isGestureInProgress())
        XCTAssertEqual(mapboxMap.__testingMap.getCenterAltitudeMode(), .sea)
    }

    func testLoadStyleHandlerIsInvokedExactlyOnce() throws {
        let completionIsCalledOnce = expectation(description: "loadStyle completion should be called once")

        mapboxMap.loadStyle(.dark) { _ in
            completionIsCalledOnce.fulfill()
        }
        let interval = EventTimeInterval(begin: .init(), end: .init())
        events.onStyleLoaded.send(StyleLoaded(timeInterval: interval))
        events.onStyleLoaded.send(StyleLoaded(timeInterval: interval))

        waitForExpectations(timeout: 10)
    }

    func testEvents() {
        func checkEvent<T>(
            _ subjectKeyPath: KeyPath<MapEvents, SignalSubject<T>>,
            _ signalKeyPath: KeyPath<MapboxMap, Signal<T>>,
            value: T) {
                var count = 0
                let cancelable = mapboxMap[keyPath: signalKeyPath].observe { _ in
                    count += 1
                }

                events[keyPath: subjectKeyPath].send(value)
                XCTAssertEqual(count, 1, "event sent")

                cancelable.cancel()

                events[keyPath: subjectKeyPath].send(value)
                XCTAssertEqual(count, 1, "event not sent due to cancel")
        }

        let timeInterval = EventTimeInterval(begin: Date(), end: Date())
        let mapLoaded = MapLoaded(timeInterval: timeInterval)
        let mapLoadingError = MapLoadingError(
            type: .source,
            message: "message",
            sourceId: nil,
            tileId: nil,
            timestamp: Date())
        let cameraChanged = CameraChanged(
            cameraState: CameraState(center: .testConstantValue(), padding: .testConstantValue(), zoom: 0, bearing: 0, pitch: 0),
            timestamp: Date())

        checkEvent(\.onMapIdle, \.onMapIdle, value: MapIdle(timestamp: Date()))
        checkEvent(\.onMapLoaded, \.onMapLoaded, value: mapLoaded)
        checkEvent(\.onStyleLoaded, \.onStyleLoaded, value: StyleLoaded(timeInterval: timeInterval))
        checkEvent(\.onStyleDataLoaded, \.onStyleDataLoaded, value: StyleDataLoaded(type: .style, timeInterval: timeInterval))
        checkEvent(\.onMapLoadingError, \.onMapLoadingError, value: mapLoadingError)
        checkEvent(\.onCameraChanged, \.onCameraChanged, value: cameraChanged)
        checkEvent(\.onSourceAdded, \.onSourceAdded, value: SourceAdded(sourceId: "foo", timestamp: Date()))
        checkEvent(\.onSourceRemoved, \.onSourceRemoved, value: SourceRemoved(sourceId: "foo", timestamp: Date()))
        checkEvent(\.onStyleImageMissing, \.onStyleImageMissing, value: StyleImageMissing(imageId: "bar", timestamp: Date()))
        checkEvent(\.onStyleImageRemoveUnused, \.onStyleImageRemoveUnused, value: StyleImageRemoveUnused(imageId: "bar", timestamp: Date()))
        checkEvent(\.onRenderFrameStarted, \.onRenderFrameStarted, value: RenderFrameStarted(timestamp: Date()))
        checkEvent(\.onRenderFrameFinished, \.onRenderFrameFinished, value: RenderFrameFinished(renderMode: .full, needsRepaint: true, placementChanged: true, timeInterval: timeInterval))

        let resourceRequest =  ResourceRequest(
            source: .network,
            request: RequestInfo(
                url: "https://mapbox.com",
                resource: .glyphs,
                priority: .regular,
                loadingMethod: [NSNumber(value: RequestLoadingMethodType.network.rawValue)]),
            response: nil, cancelled: false, timeInterval: timeInterval)
        checkEvent(\.onResourceRequest, \.onResourceRequest, value: resourceRequest)
    }

    func testGenericEvents() {
        var cancelables = Set<AnyCancelable>()
        var received = [GenericEvent]()
        mapboxMap["foo"].observe { received.append($0) }.store(in: &cancelables)

        let timeInterval = EventTimeInterval(begin: Date(), end: Date())
        let e1 = GenericEvent(name: "foo", data: 0, timeInterval: timeInterval)
        let e2 = GenericEvent(name: "foo", data: 0, timeInterval: timeInterval)

        fooGenericSubject?.send(e1)
        XCTAssertIdentical(received.last, e1)

        fooGenericSubject?.send(e2)
        XCTAssertIdentical(received.last, e2)
    }

    @available(*, deprecated)
    func testOnTypedNext() throws {
        let mapLoadedStub = Stub<MapLoaded, Void>()
        let token = mapboxMap.onNext(event: .mapLoaded, handler: mapLoadedStub.call(with:))
        defer { token.cancel() }

        let mapLoaded1 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))
        let mapLoaded2 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))
        events.onMapLoaded.send(mapLoaded1)
        events.onMapLoaded.send(mapLoaded2)

        XCTAssertEqual(mapLoadedStub.invocations.count, 1)
        XCTAssertIdentical(mapLoadedStub.invocations[0].parameters, mapLoaded1)

        // ignored cancellable
        let sourceAddedStub = Stub<SourceAdded, Void>()
        mapboxMap.onNext(event: .sourceAdded, handler: sourceAddedStub.call(with:))

        let sourceAdded1 = SourceAdded(sourceId: "source-id-1", timestamp: Date())
        let sourceAdded2 = SourceAdded(sourceId: "source-id-2", timestamp: Date())
        events.onSourceAdded.send(sourceAdded1)
        events.onSourceAdded.send(sourceAdded2)
        events.onSourceAdded.send(sourceAdded2)

        XCTAssertEqual(mapLoadedStub.invocations.count, 1)
        XCTAssertIdentical(sourceAddedStub.invocations[0].parameters, sourceAdded1)
    }

    @available(*, deprecated)
    func testOnTypedEvery() throws {
        let mapLoadedStub = Stub<MapLoaded, Void>()
        let token = mapboxMap.onEvery(event: .mapLoaded, handler: mapLoadedStub.call(with:))
        defer { token.cancel() }

        let mapLoaded1 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))
        let mapLoaded2 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))
        events.onMapLoaded.send(mapLoaded1)
        events.onMapLoaded.send(mapLoaded2)

        XCTAssertIdentical(mapLoadedStub.invocations[0].parameters, mapLoaded1)
        XCTAssertIdentical(mapLoadedStub.invocations[1].parameters, mapLoaded2)

        // ignored cancellable
        let sourceAddedStub = Stub<SourceAdded, Void>()
        mapboxMap.onEvery(event: .sourceAdded, handler: sourceAddedStub.call(with:))

        let sourceAdded1 = SourceAdded(sourceId: "source-id-1", timestamp: Date())
        let sourceAdded2 = SourceAdded(sourceId: "source-id-2", timestamp: Date())
        events.onSourceAdded.send(sourceAdded1)
        events.onSourceAdded.send(sourceAdded2)

        XCTAssertIdentical(sourceAddedStub.invocations[0].parameters, sourceAdded1)
        XCTAssertIdentical(sourceAddedStub.invocations[1].parameters, sourceAdded2)
    }

    func testFittingPoint() {
        let size = CGSize(width: 100, height: 100)

        XCTAssertEqual(CGPoint(x: 1, y: 1).fit(to: size), CGPoint(x: 1, y: 1))
        XCTAssertEqual(CGPoint(x: 0, y: 0).fit(to: size), CGPoint(x: 0, y: 0))
        XCTAssertEqual(CGPoint(x: 100, y: 100).fit(to: size), CGPoint(x: 100, y: 100))
        XCTAssertEqual(CGPoint(x: -0.1, y: 0.2).fit(to: size), CGPoint(x: 0, y: 0.2))
        XCTAssertEqual(CGPoint(x: 1, y: -0.2).fit(to: size), CGPoint(x: 1, y: 0))
        XCTAssertEqual(CGPoint(x: -0.3, y: -0.3).fit(to: size), CGPoint(x: 0, y: 0))
        XCTAssertEqual(CGPoint(x: -0.5, y: -0.3).fit(to: size), CGPoint(x: -1, y: -1))
        XCTAssertEqual(CGPoint(x: -0.3, y: -0.5).fit(to: size), CGPoint(x: -1, y: -1))
        XCTAssertEqual(CGPoint(x: 100.1, y: 99.9).fit(to: size), CGPoint(x: 100, y: 99.9))
        XCTAssertEqual(CGPoint(x: 99.9, y: 100.1).fit(to: size), CGPoint(x: 99.9, y: 100))
        XCTAssertEqual(CGPoint(x: 102, y: 1).fit(to: size), CGPoint(x: -1, y: -1))
        XCTAssertEqual(CGPoint(x: 1, y: 101).fit(to: size), CGPoint(x: -1, y: -1))
    }

    func testViewAnnotationAvoidLayers() {
        let layers: Set<String> = ["my-symbol-layer", "my-fill-layer"]

        mapboxMap.viewAnnotationAvoidLayers = layers

        XCTAssertEqual(mapboxMap.viewAnnotationAvoidLayers, layers)
        XCTAssertEqual(mapboxMap.__testingMap.getViewAnnotationAvoidLayers(), layers)
    }
}
