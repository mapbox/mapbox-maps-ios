import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class MapEventsTests: XCTestCase {
    private var source: MapEventsSource!
    private var me: MapEvents!
    private var cancelables = Set<AnyCancelable>()

    // We don't store fooSubject strongly to test that MapEvents stores the subjects it created.
    weak private var fooSubject: SignalSubject<GenericEvent>?

    override func setUp() {
        source = MapEventsSource(makeGenericSubject: { [weak self] eventName in
            let s = SignalSubject<GenericEvent>()
            if eventName == "foo" {
                if let fooSubject = self?.fooSubject {
                    return fooSubject
                } else {
                    self?.fooSubject = s
                    return s
                }
            }
            return s
        })
        me = MapEvents(source: source)
        cancelables.removeAll()
    }

    override func tearDown() {
        cancelables.removeAll()
        me = nil
        source = nil
        fooSubject = nil
    }

    func testMuteEvents() {
        func checkEvent<T>(
            _ subjectKeyPath: KeyPath<MapEventsSource, SignalSubject<T>>,
            _ signalKeyPath: KeyPath<MapEvents, Signal<T>>,
            value: T) {
                var count = 0
                let cancelable = me[keyPath: signalKeyPath].observe { _ in
                    count += 1
                }

                me.performWithoutNotifying {
                    source[keyPath: subjectKeyPath].send(value)
                }
                XCTAssertEqual(count, 0, "event not sent due to mute")

                source[keyPath: subjectKeyPath].send(value)
                XCTAssertEqual(count, 1, "event sent")

                cancelable.cancel()

                source[keyPath: subjectKeyPath].send(value)
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
            cameraState: CameraState(center: .random(), padding: .random(), zoom: 0, bearing: 0, pitch: 0),
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
        var received = [GenericEvent]()
        me["foo"].observe { received.append($0) }.store(in: &cancelables)

        let timeInterval = EventTimeInterval(begin: Date(), end: Date())
        let e1 = GenericEvent(name: "foo", data: 0, timeInterval: timeInterval)
        let e2 = GenericEvent(name: "foo", data: 0, timeInterval: timeInterval)

        fooSubject?.send(e1)
        XCTAssertIdentical(received.last, e1)

        me.performWithoutNotifying {
            fooSubject?.send(e2)
        }

        XCTAssertIdentical(received.last, e1, "event not sent due to mute")

        fooSubject?.send(e2)
        XCTAssertIdentical(received.last, e2)
    }

    @available(*, deprecated)
    func testOnEvery() {
        var received = [MapLoaded]()
        let c = me.onEvery(event: .mapLoaded) { received.append($0) }

        let e1 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))
        let e2 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))
        let e3 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))
        source.onMapLoaded.send(e1)

        XCTAssertIdentical(received.last, e1)

        me.performWithoutNotifying {
            source.onMapLoaded.send(e2)
        }
        XCTAssertIdentical(received.last, e1, "event not sent due to mute")

        source.onMapLoaded.send(e2)
        XCTAssertIdentical(received.last, e2)

        c.cancel()
        source.onMapLoaded.send(e3)
        XCTAssertIdentical(received.last, e2, "event not sent due to cancel")
    }
    @available(*, deprecated)
    func testOnEveryNoStoreCancelable() {
        var received = [MapLoaded]()
        me.onEvery(event: .mapLoaded) { received.append($0) }

        let e1 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))
        let e2 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))
        source.onMapLoaded.send(e1)
        XCTAssertIdentical(received.last, e1)
        source.onMapLoaded.send(e2)
        XCTAssertIdentical(received.last, e2)
    }

    @available(*, deprecated)
    func testOnNext() {
        var received = [MapLoaded]()
        me.onNext(event: .mapLoaded) { received.append($0) }

        let e1 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))
        let e2 = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))

        me.performWithoutNotifying {
            source.onMapLoaded.send(e1)
        }
        XCTAssertIdentical(received.last, nil, "event not sent due to mute")

        source.onMapLoaded.send(e1)
        XCTAssertIdentical(received.last, e1)
        source.onMapLoaded.send(e2)
        XCTAssertIdentical(received.last, e1, "event not sent due self-cancel")
    }
}
