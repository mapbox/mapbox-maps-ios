import XCTest
@testable import MapboxMaps

class MapInitOptionsIntegrationTests: XCTestCase {

    private var providerReturnValue: MapInitOptions!
    private var cancelables = Set<AnyCancelable>()

    override func tearDown() {
        super.tearDown()
        providerReturnValue = nil
        cancelables.removeAll()
    }

    func testOptionsAreSetFromNibProvider() {
        // Provider should return a custom MapInitOptions
        providerReturnValue = MapInitOptions(styleURI: .satellite)

        // Load views from a nib, where the map view's provider is the file's owner,
        // i.e. this test.
        let nib = UINib(nibName: "MapInitOptionsTests", bundle: .mapboxMapsTests)

        // Instantiate the map views. The nib contains two MapViews, one has their
        // mapInitOptionsProvider outlet connected to this test object (view
        // tag == 1), the other is nil (tag == 2)
        let objects = nib.instantiate(withOwner: self, options: nil)
        let mapViews = objects.compactMap { $0 as? MapView }

        // Check MapView 1 -- connected in IB
        let mapView = mapViews.first { $0.tag == 1 }!
        XCTAssertNotNil(mapView.mapInitOptionsProvider)

        let optionsFromProvider = mapView.mapInitOptionsProvider!.mapInitOptions()

        // Check that the provider in the MapView is correctly wired, so that the
        // expected options are returned
        XCTAssertEqual(optionsFromProvider, providerReturnValue)

        XCTAssertEqual(mapView.mapboxMap.styleURI, .satellite)
    }

    func testDefaultOptionsAreUsedWhenNibDoesntSetProvider() {
        // Although this test checks that a MapView (#2) isn't connected to a
        // Provider, the first MapView will still be instantiated, so a return
        // value is still required.
        providerReturnValue = MapInitOptions()

        // Load view from a nib, where the map view's provider is nil
        let nib = UINib(nibName: "MapInitOptionsTests", bundle: .mapboxMapsTests)

        // Instantiate the view. The nib contains two MapViews, one has their
        // mapInitOptionsProvider outlet connected to this test object (view
        // tag == 1), the other is nil (tag == 2)
        let objects = nib.instantiate(withOwner: self, options: nil)

        // Check MapView 2 -- Not connected in IB
        let mapView = objects.compactMap { $0 as? MapView }.first { $0.tag == 2 }!
        XCTAssertNil(mapView.mapInitOptionsProvider)
    }

    func testStyleDefaultCamera() throws {
        // Get path to empty style
        let path = Bundle.mapboxMapsTests.path(forResource: "empty-style-chicago", ofType: "json")!
        let url = URL(fileURLWithPath: path)

        let data = try Data(contentsOf: url)
        guard let styleJSONObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            XCTFail("Failed to deserialize style JSON")
            return
        }

        let mapInitOptions = MapInitOptions(styleURI: StyleURI(url: url))
        let view = MapView(frame: .zero, mapInitOptions: mapInitOptions)

        let expectation = self.expectation(description: "Wait for style to load")
        view.mapboxMap.onStyleLoaded.observeNext { _ in
            expectation.fulfill()
        }.store(in: &cancelables)

        wait(for: [expectation], timeout: 1.0)

        guard let sourceCenter = styleJSONObject["center"] as? [Double],
              let sourceZoom = styleJSONObject["zoom"] as? CGFloat else {
            XCTFail("Invalid JSON")
            return
        }

        let destCenter = view.mapboxMap.cameraState.center
        let destZoom = view.mapboxMap.cameraState.zoom

        XCTAssertEqual(sourceCenter[0], destCenter.longitude, accuracy: 0.0000001)
        XCTAssertEqual(sourceCenter[1], destCenter.latitude, accuracy: 0.0000001)
        XCTAssertEqual(sourceZoom, destZoom, accuracy: 0.0000001)
    }

    func testInitialCameraOverridesStyleDefaultCamera() throws {
        // Get path to empty style
        let path = Bundle.mapboxMapsTests.path(forResource: "empty-style-chicago", ofType: "json")!
        let url = URL(fileURLWithPath: path)

        let sourceCamera = CameraOptions(center: CLLocationCoordinate2D(latitude: 1.23, longitude: 4.56), zoom: 14)

        let mapInitOptions = MapInitOptions(cameraOptions: sourceCamera,
                                            styleURI: StyleURI(url: url))
        let view = MapView(frame: .zero, mapInitOptions: mapInitOptions)

        let expectation = self.expectation(description: "Wait for style to load")
        view.mapboxMap.onStyleLoaded.observeNext { _ in
            expectation.fulfill()
        }.store(in: &cancelables)

        wait(for: [expectation], timeout: 1.0)

        let sourceCenter = sourceCamera.center!
        let sourceZoom = sourceCamera.zoom!

        let destCenter = view.mapboxMap.cameraState.center
        let destZoom = view.mapboxMap.cameraState.zoom

        XCTAssertEqual(sourceCenter.longitude, destCenter.longitude, accuracy: 0.0000001)
        XCTAssertEqual(sourceCenter.latitude, destCenter.latitude, accuracy: 0.0000001)
        XCTAssertEqual(sourceZoom, destZoom, accuracy: 0.0000001)
    }
}

extension MapInitOptionsIntegrationTests: MapInitOptionsProvider {
    // This needs to return Any, since MapInitOptions is a struct, and this is
    // an objc delegate.
    public func mapInitOptions() -> MapInitOptions {
        return providerReturnValue
    }
}
