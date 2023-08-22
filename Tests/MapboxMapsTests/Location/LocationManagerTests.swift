@testable @_spi(Experimental) import MapboxMaps
import XCTest

final class LocationManagerTests: XCTestCase {
    @TestPublished var location = [Location]()
    @TestPublished var heading: Heading?
    @TestSignal var displayLink: Signal<Void>
    @MutableRef var now = Date.init(timeIntervalSince1970: 0)
    var styleManager: MockStyle!
    var mapboxMap: MockMapboxMap!
    var tokens = Set<AnyCancelable>()

    var me: LocationManager!

    override func setUp() {
        styleManager = MockStyle()
        mapboxMap = MockMapboxMap()
        me = LocationManager(
            styleManager: styleManager,
            mapboxMap: mapboxMap,
            displayLink: displayLink,
            locationProvider: $location,
            headingProvider: $heading.skipNil(),
            nowTimestamp: $now)
    }

    override func tearDown() {
        tokens.removeAll()
        me = nil
        mapboxMap = nil
        styleManager = nil
        heading = nil
        location = []
    }

    @available(*, deprecated)
    func testOverrideWithSignalProviders() {
        var observedLocations = [[Location]]()
        var observedHeading = [Heading]()
        me.onLocationChange.observe { observedLocations.append($0) }.store(in: &tokens)
        me.onHeadingChange.observe { observedHeading.append($0) }.store(in: &tokens)

        XCTAssertEqual(observedLocations, [[]], "initial update")
        XCTAssertEqual(observedHeading, [], "no initial update, heading is nil")
        XCTAssertEqual(me.onLocationChange.latestValue, [])
        XCTAssertEqual(me.onHeadingChange.latestValue, nil)
        XCTAssertEqual(me.latestLocation, nil)

        let l1 = Location.random()
        let l2 = Location.random()
        location = [l1, l2]

        XCTAssertEqual(observedLocations, [[], [l1, l2]])
        XCTAssertEqual(me.onLocationChange.latestValue, [l1, l2])
        XCTAssertEqual(me.latestLocation, l2)

        let h1 = Heading.random()
        heading = h1

        XCTAssertEqual(observedHeading, [h1])
        XCTAssertEqual(me.onHeadingChange.latestValue, h1)

        // override with signal (no cached value)
        let locationSubject = SignalSubject<[Location]>()
        let headingSubject = SignalSubject<Heading>()

        me.override(
            locationProvider: locationSubject.signal,
            headingProvider: headingSubject.signal)

        XCTAssertEqual(observedLocations, [[], [l1, l2]])
        XCTAssertEqual(me.onLocationChange.latestValue, [l1, l2])
        XCTAssertEqual(me.latestLocation, l2)

        let l3 = Location.random()
        locationSubject.send([l3])
        XCTAssertEqual(observedLocations, [[], [l1, l2], [l3]])
        XCTAssertEqual(me.latestLocation, l3)

        let h2 = Heading.random()
        headingSubject.send(h2)
        XCTAssertEqual(observedHeading, [h1, h2])

        // override with signal with cached value
        let l4 = Location.random()
        let justLocationSignal = Signal(just: [l4])

        let h3 = Heading.random()
        let justHeadingSignal = Signal(just: h3)

        me.override(locationProvider: justLocationSignal, headingProvider: justHeadingSignal)

        XCTAssertEqual(observedLocations, [[], [l1, l2], [l3], [l4]])
        XCTAssertEqual(observedHeading, [h1, h2, h3])
    }

    @available(*, deprecated)
    func testOverrideWithObjectProviders() {
        let locationProvider = LocationProviderMock()
        let headingProvider = HeadingProviderMock()

        me.override(locationProvider: locationProvider, headingProvider: headingProvider)

        var observedLocations = [[Location]]()
        var observedHeading = [Heading]()
        me.onLocationChange.observe { observedLocations.append($0) }.store(in: &tokens)
        me.onHeadingChange.observe { observedHeading.append($0) }.store(in: &tokens)

        XCTAssertEqual(observedLocations, [[]], "initial update")
        XCTAssertEqual(observedHeading, [], "no initial update, heading is nil")
        XCTAssertEqual(me.onLocationChange.latestValue, [])
        XCTAssertEqual(me.onHeadingChange.latestValue, nil)
        XCTAssertEqual(me.latestLocation, nil)

        let l1 = Location.random()
        let l2 = Location.random()
        let h1 = Heading.random()

        locationProvider.location = [l1, l2]
        headingProvider.latestHeading = h1

        XCTAssertEqual(observedLocations, [[], [l1, l2]])
        XCTAssertEqual(observedHeading, [h1])
        XCTAssertEqual(me.onLocationChange.latestValue, [l1, l2])
        XCTAssertEqual(me.onHeadingChange.latestValue, h1)
        XCTAssertEqual(me.latestLocation, l2)
    }

    @available(*, deprecated)
    func testPuckRenderingData() throws {
        // set initial location to 0, 0
        let beginCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        location = [Location(coordinate: beginCoordinate)]
        heading = Heading(direction: 0, accuracy: 0)

        var observedData = [PuckRenderingData]()
        me.onPuckRender.observe { observedData.append($0) }.store(in: &tokens)

        XCTAssertEqual(observedData, [], "no data before display link")

        $displayLink.send()

        XCTAssertEqual(observedData.count, 1)
        let observedData1 = try XCTUnwrap(observedData.last)
        XCTAssertEqual(observedData1.location.coordinate, CLLocationCoordinate2D(latitude: 0, longitude: 0))
        XCTAssertEqual(observedData1.heading?.direction, 0)

        let endCoordinate = CLLocationCoordinate2D(latitude: 10, longitude: 10)
        location = [Location(coordinate: endCoordinate)]
        heading = Heading(direction: 10, accuracy: 10)

        now = Date(timeIntervalSince1970: 0.2)
        $displayLink.send()

        XCTAssertEqual(observedData.count, 2)
        let observedData2 = try XCTUnwrap(observedData.last)
        XCTAssertGreaterThan(observedData2.location.coordinate.latitude, beginCoordinate.latitude)
        XCTAssertGreaterThan(observedData2.location.coordinate.longitude, beginCoordinate.longitude)
        let observedHeading = try XCTUnwrap(observedData2.heading)
        XCTAssertGreaterThan(observedHeading.direction, 0)

        now = Date(timeIntervalSince1970: 2)
        $displayLink.send()

        XCTAssertEqual(observedData.count, 3)
        let observedData3 = try XCTUnwrap(observedData.last)
        XCTAssertEqual(observedData3.location.coordinate, endCoordinate)
        let observedHeading2 = try XCTUnwrap(observedData3.heading)
        XCTAssertEqual(observedHeading2.direction, 10)
    }

    func testPuck2dIsAddedToMap() throws {
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        location = [Location(coordinate: coordinate)]
        heading = Heading(direction: 20, accuracy: 0)

        me.options = .init(puckType: .puck2D())

        $displayLink.send()

        let addedLayersProps = styleManager.addPersistentLayerWithPropertiesStub.invocations.map(\.parameters.properties)

        let puckLayerProps = try XCTUnwrap(addedLayersProps.first { $0["id"] as? String == "puck" })

        let locationValue = try XCTUnwrap(puckLayerProps["location"] as? [Double])
        XCTAssertEqual(locationValue, [coordinate.latitude, coordinate.longitude, 0])
    }

    func testPuck3dIsAddedToMap() throws {
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        location = [Location(coordinate: coordinate)]
        heading = Heading(direction: 20, accuracy: 0)

        let model = Model(uri: URL(string: "file://foo.glb"))
        me.options = .init(puckType: .puck3D(.init(model: model)))

        $displayLink.send()

        let addedLayers = styleManager.addPersistentLayerStub.invocations.map(\.parameters.layer)

        let puckModelLayer = addedLayers
            .compactMap { $0 as? ModelLayer }
            .filter { $0.id == "puck-model-layer" }
            .last
        XCTAssertNotNil(puckModelLayer)

        let addedSources = styleManager.addSourceStub.invocations.map(\.parameters.source)
        let modelSource = addedSources
            .compactMap { $0 as? ModelSource }
            .filter { $0.id == puckModelLayer?.source }
            .last

        let observedModel = try XCTUnwrap(modelSource?.models?["puck-model"] as? Model)
        XCTAssertEqual(observedModel.uri, URL(string: "file://foo.glb"))
        XCTAssertEqual(observedModel.position, [coordinate.latitude, coordinate.longitude])
    }
}

private final class LocationProviderMock: LocationProvider {
    var location = [Location]() {
        didSet {
            for observer in observers.allObjects {
                observer.onLocationUpdateReceived(for: location)
            }
        }
    }

    private var observers = WeakSet<LocationObserver>()

    func addLocationObserver(for observer: LocationObserver) {
        observers.add(observer)
    }

    func removeLocationObserver(for observer: LocationObserver) {
        observers.remove(observer)
    }

    func getLastObservedLocation() -> Location? {
        location.last
    }
}

private final class HeadingProviderMock: HeadingProvider {
    private var observers = WeakSet<HeadingObserver>()
    var latestHeading: Heading? {
        didSet {
            if let heading = latestHeading {
                for observer in observers.allObjects {
                    observer.onHeadingUpdate(heading)
                }
            }
        }
    }

    func add(headingObserver: HeadingObserver) {
        observers.add(headingObserver)
    }

    func remove(headingObserver: HeadingObserver) {
        observers.remove(headingObserver)
    }
}
