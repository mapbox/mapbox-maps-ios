import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class MapboxMapTests: XCTestCase {

    var mapClient: MockMapClient!
    var mapInitOptions: MapInitOptions!
    var mapboxMap: MapboxMap!

    override func setUp() {
        super.setUp()
        let size = CGSize(width: 100, height: 200)
        mapClient = MockMapClient()
        mapClient.getMetalViewStub.defaultReturnValue = MTKView(frame: CGRect(origin: .zero, size: size))
        mapInitOptions = MapInitOptions(mapOptions: MapOptions(size: size))
        mapboxMap = MapboxMap(mapClient: mapClient, mapInitOptions: mapInitOptions)
    }

    override func tearDown() {
        mapboxMap = nil
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
        _ = mapboxMap as ObservableProtocol
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

    func testSetMapProjection() {
        XCTAssertEqual(mapboxMap.__testingMap.getMapProjection() as? [String: String], ["name": "mercator"])
        try? mapboxMap.setProjection(mode: GlobeMapProjection())
        XCTAssertEqual(mapboxMap.__testingMap.getMapProjection() as? [String: String], ["name": "globe"])
    }

    func testGetMapProjection() {
        try? mapboxMap.setProjection(mode: MercatorMapProjection())
        var projection = try? mapboxMap.getMapProjection()
        XCTAssert(projection is MercatorMapProjection)

        try? mapboxMap.setProjection(mode: GlobeMapProjection())
        projection = try? mapboxMap.getMapProjection()
        XCTAssert(projection is GlobeMapProjection)
    }
}
