import XCTest
@testable import MapboxMaps

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
        let actualResourceOptions = mapboxMap.__map.getResourceOptions()

        XCTAssertEqual(actualResourceOptions, mapInitOptions.resourceOptions)
    }

    func testInitializationOfMapOptions() {
        let expectedMapOptions = MapOptions(
            __contextMode: nil,
            constrainMode: NSNumber(value: mapInitOptions.mapOptions.constrainMode.rawValue),
            viewportMode: mapInitOptions.mapOptions.viewportMode.map { NSNumber(value: $0.rawValue) },
            orientation: NSNumber(value: mapInitOptions.mapOptions.orientation.rawValue),
            crossSourceCollisions: NSNumber(value: mapInitOptions.mapOptions.crossSourceCollisions),
            size: mapInitOptions.mapOptions.size.map(Size.init),
            pixelRatio: mapInitOptions.mapOptions.pixelRatio,
            glyphsRasterizationOptions: nil) // __map.getOptions() always returns nil for glyphsRasterizationOptions

        let actualMapOptions = mapboxMap.__map.getOptions()

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

        XCTAssertEqual(CGSize(mapboxMap.__map.getSize()), expectedSize)
    }

    func testGetSize() {
        let expectedSize = Size(
            width: .random(in: 100...1000),
            height: .random(in: 100...1000))
        mapboxMap.__map.setSizeFor(expectedSize)

        let actualSize = mapboxMap.size

        XCTAssertEqual(actualSize, CGSize(expectedSize))
    }

    func testGetCameraOptions() {
        XCTAssertEqual(mapboxMap.cameraOptions, CameraOptions(mapboxMap.__map.getCameraOptions(forPadding: nil)))
    }
}
