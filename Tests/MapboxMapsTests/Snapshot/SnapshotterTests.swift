import XCTest
@_spi(Experimental) @testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private
import CoreLocation

final class SnapshotterTests: XCTestCase {
    var events: MapEvents!
    var snapshotter: Snapshotter!
    var mockMapSnapshotter: MockMapSnapshotter!

    override func setUp() {
        super.setUp()
        let options = MapSnapshotOptions(
            size: CGSize(width: 100, height: 100),
            pixelRatio: .random(in: 1...3))
        events = MapEvents(makeGenericSubject: { _ in .init() })
        mockMapSnapshotter = MockMapSnapshotter()
        snapshotter = Snapshotter(
            options: options,
            mapSnapshotter: mockMapSnapshotter,
            events: events,
            eventsManager: EventsManagerMock())
    }

    override func tearDown() {
        snapshotter = nil
        mockMapSnapshotter = nil
        super.tearDown()
    }

    func testSnapshotterCompletionInvocationFailed() throws {
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

    func testSnapshotterCancel() throws {
        snapshotter.cancel()
        XCTAssertEqual(mockMapSnapshotter.cancelSnapshotterStub.invocations.count, 1)
    }

    func testSnapshotterSize() throws {
        let size = CGSize(width: 200, height: 200)

        snapshotter.snapshotSize = size
        mockMapSnapshotter.getSizeStub.defaultReturnValue = Size(size)

        XCTAssertEqual(snapshotter.snapshotSize, size)
        XCTAssertEqual(mockMapSnapshotter.getSizeStub.invocations.count, 1)
        XCTAssertEqual(mockMapSnapshotter.setSizeStub.invocations[0].parameters, Size(size))
    }

    func testSnapshotterSetCamera() throws {
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
    func testSnapshotterCoordinateBoundsForCamera() throws {
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

    func testSnapshotterCameraforCoordinateBounds() throws {
        // verify that return value for snapshotter matches return value for mock: coordinateBounds
        let coordinates = [
            CLLocationCoordinate2D(latitude: 44.9753911881, longitude: -124.3348229758),
            CLLocationCoordinate2D(latitude: 48.9862916537, longitude: -124.3635392111),
            CLLocationCoordinate2D(latitude: 49.0163313873, longitude: -114.9828959018),
            CLLocationCoordinate2D(latitude: 45.0077739132, longitude: -114.9541796666),
            CLLocationCoordinate2D(latitude: 44.9753911881, longitude: -124.3348229758)
        ]
        let center = CLLocationCoordinate2D(latitude: 38, longitude: -76)
        let padding = CoreEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        let anchor = CGPoint.zero
        let zoom = 15.0
        let bearing = 45.0
        let pitch = 90.0

        let cameraOptions = CameraOptions(center: center, padding: padding.toUIEdgeInsetsValue(), anchor: anchor, zoom: zoom, bearing: CLLocationDirection(bearing), pitch: CGFloat(pitch))
        mockMapSnapshotter.cameraForCoordinatesStub.defaultReturnValue = CoreCameraOptions(cameraOptions)

        let returnedOptions = snapshotter.camera(for: coordinates, padding: padding.toUIEdgeInsetsValue(), bearing: bearing, pitch: pitch)

        XCTAssertEqual(mockMapSnapshotter.cameraForCoordinatesStub.invocations.count, 1)

        let mockParameters = mockMapSnapshotter.cameraForCoordinatesStub.invocations[0].parameters

        XCTAssertEqual(mockParameters.coordinates.map(\.value), coordinates)
        XCTAssertEqual(mockParameters.padding?.toUIEdgeInsetsValue(), padding.toUIEdgeInsetsValue())
        XCTAssertEqual(mockParameters.bearing, bearing.NSNumber)
        XCTAssertEqual(mockParameters.pitch, pitch.NSNumber)
        XCTAssertEqual(returnedOptions, cameraOptions)
    }

    func testEvents() {
        func checkEvent<T>(
            _ subjectKeyPath: KeyPath<MapEvents, SignalSubject<T>>,
            _ signalKeyPath: KeyPath<Snapshotter, Signal<T>>,
            value: T) {
                var count = 0
                let cancelable = snapshotter[keyPath: signalKeyPath].observe { _ in
                    count += 1
                }

                events[keyPath: subjectKeyPath].send(value)
                XCTAssertEqual(count, 1, "event sent")

                cancelable.cancel()

                events[keyPath: subjectKeyPath].send(value)
                XCTAssertEqual(count, 1, "event not sent due to cancel")
        }

        let timeInterval = EventTimeInterval(begin: Date(), end: Date())
        let mapLoadingError = MapLoadingError(
            type: .source,
            message: "message",
            sourceId: nil,
            tileId: nil,
            timestamp: Date())

        checkEvent(\.onStyleLoaded, \.onStyleLoaded, value: StyleLoaded(timeInterval: timeInterval))
        checkEvent(\.onStyleDataLoaded, \.onStyleDataLoaded, value: StyleDataLoaded(type: .style, timeInterval: timeInterval))
        checkEvent(\.onMapLoadingError, \.onMapLoadingError, value: mapLoadingError)

        checkEvent(\.onStyleImageMissing, \.onStyleImageMissing, value: StyleImageMissing(imageId: "bar", timestamp: Date()))
    }

    @available(*, deprecated)
    func testOnTypedNext() throws {
        let mapLoadedStub = Stub<MapLoaded, Void>()
        let token = snapshotter.onNext(event: .mapLoaded, handler: mapLoadedStub.call(with:))
        defer { token.cancel() }

        let mapLoaded1 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))
        let mapLoaded2 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))
        events.onMapLoaded.send(mapLoaded1)
        events.onMapLoaded.send(mapLoaded2)

        XCTAssertEqual(mapLoadedStub.invocations.count, 1)
        XCTAssertIdentical(mapLoadedStub.invocations[0].parameters, mapLoaded1)

        // ignored cancellable
        let sourceAddedStub = Stub<SourceAdded, Void>()
        snapshotter.onNext(event: .sourceAdded, handler: sourceAddedStub.call(with:))

        let sourceAdded1 = SourceAdded(sourceId: "source-id-1", timestamp: Date())
        let sourceAdded2 = SourceAdded(sourceId: "source-id-2", timestamp: Date())
        events.onSourceAdded.send(sourceAdded1)
        events.onSourceAdded.send(sourceAdded2)
        events.onSourceAdded.send(sourceAdded2)

        XCTAssertEqual(sourceAddedStub.invocations.count, 1)
        XCTAssertIdentical(sourceAddedStub.invocations[0].parameters, sourceAdded1)
    }

    @available(*, deprecated)
    func testOnTypedEvery() throws {
        let mapLoadedStub = Stub<MapLoaded, Void>()
        let token = snapshotter.onEvery(event: .mapLoaded, handler: mapLoadedStub.call(with:))
        defer { token.cancel() }

        let mapLoaded1 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))
        let mapLoaded2 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))
        events.onMapLoaded.send(mapLoaded1)
        events.onMapLoaded.send(mapLoaded2)

        XCTAssertIdentical(mapLoadedStub.invocations[0].parameters, mapLoaded1)
        XCTAssertIdentical(mapLoadedStub.invocations[1].parameters, mapLoaded2)

        // ignored cancellable
        let sourceAddedStub = Stub<SourceAdded, Void>()
        snapshotter.onEvery(event: .sourceAdded, handler: sourceAddedStub.call(with:))

        let sourceAdded1 = SourceAdded(sourceId: "source-id-1", timestamp: Date())
        let sourceAdded2 = SourceAdded(sourceId: "source-id-2", timestamp: Date())
        events.onSourceAdded.send(sourceAdded1)
        events.onSourceAdded.send(sourceAdded2)

        XCTAssertIdentical(sourceAddedStub.invocations[0].parameters, sourceAdded1)
        XCTAssertIdentical(sourceAddedStub.invocations[1].parameters, sourceAdded2)
    }

    func testTileCover() throws {
        let stubReturnTileIDs = [CanonicalTileID(z: 3, x: 5, y: 7)]

        let options = TileCoverOptions(tileSize: 512, minZoom: 4, maxZoom: 8, roundZoom: true)
        mockMapSnapshotter.tileCoverStub.returnValueQueue.append(stubReturnTileIDs)

        let tileIDs = snapshotter.tileCover(for: options)
        XCTAssertEqual(stubReturnTileIDs, tileIDs)

        let parameters = try XCTUnwrap(mockMapSnapshotter.tileCoverStub.invocations.first?.parameters)

        XCTAssertEqual(parameters.options.maxZoom?.uint8Value, options.maxZoom)
        XCTAssertEqual(parameters.options.minZoom?.uint8Value, options.minZoom)
        XCTAssertEqual(parameters.options.roundZoom?.boolValue, options.roundZoom)
        XCTAssertEqual(parameters.options.tileSize?.uint16Value, options.tileSize)
    }
}
