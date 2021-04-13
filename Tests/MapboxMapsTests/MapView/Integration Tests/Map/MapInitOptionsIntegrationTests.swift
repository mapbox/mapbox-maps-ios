import XCTest
@testable import MapboxMaps

class MapInitOptionsIntegrationTests: XCTestCase {

    private var providerReturnValue: MapInitOptions!

    override func tearDown() {
        super.tearDown()
        providerReturnValue = nil
    }

    func testOptionsWithCustomCredentialsManager() {
        CredentialsManager.default.accessToken = "pk.aaaaaa"
        let credentialsManager = CredentialsManager(accessToken: "pk.cccccc")

        XCTAssertNotEqual(credentialsManager, CredentialsManager.default)

        let mapInitOptions = MapInitOptions(
            resourceOptions: ResourceOptions(accessToken: credentialsManager.accessToken))

        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        let resourceOptions = mapView.__map.getResourceOptions()

        XCTAssertEqual(resourceOptions, mapInitOptions.resourceOptions)
        XCTAssertEqual(resourceOptions.accessToken, credentialsManager.accessToken)
    }

    func testOptionsAreSetFromNibProvider() {
        CredentialsManager.default.accessToken = "pk.aaaaaa"
        let credentialsManager = CredentialsManager(accessToken: "pk.dddddd")

        // Provider should return a custom MapInitOptions
        providerReturnValue = MapInitOptions(
            resourceOptions: ResourceOptions(accessToken: credentialsManager.accessToken))

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

        // Now check the resource options from the initialized MapView
        let resourceOptions = mapView.__map.getResourceOptions()

        XCTAssertEqual(resourceOptions, providerReturnValue.resourceOptions)
        XCTAssertEqual(resourceOptions.accessToken, credentialsManager.accessToken)
    }


    func testDefaultOptionsAreUsedWhenNibDoesntSetProvider() {
        CredentialsManager.default.accessToken = "pk.eeeeee"

        // Although this test checks that a MapView (#2) isn't connected to a
        // Provider, the first MapView will still be instantiated, so a return
        // value is still required.
        providerReturnValue = MapInitOptions(
            resourceOptions: ResourceOptions(accessToken: "do-not-use"))

        // Load view from a nib, where the map view's provider is nil
        let nib = UINib(nibName: "MapInitOptionsTests", bundle: .mapboxMapsTests)

        // Instantiate the view. The nib contains two MapViews, one has their
        // mapInitOptionsProvider outlet connected to this test object (view
        // tag == 1), the other is nil (tag == 2)
        let objects = nib.instantiate(withOwner: self, options: nil)

        // Check MapView 2 -- Not connected in IB
        let mapView = objects.compactMap { $0 as? MapView }.first { $0.tag == 2 }!
        XCTAssertNil(mapView.mapInitOptionsProvider)

        // Now check the resource options from the initialized MapView
        let resourceOptions = mapView.__map.getResourceOptions()

        // The map should use the default MapInitOptions
        XCTAssertEqual(resourceOptions, ResourceOptions(accessToken: CredentialsManager.default.accessToken))
        XCTAssertEqual(resourceOptions.accessToken, CredentialsManager.default.accessToken)
    }
}

extension MapInitOptionsIntegrationTests: MapInitOptionsProvider {
    // This needs to return Any, since MapInitOptions is a struct, and this is
    // an objc delegate.
    public func mapInitOptions() -> MapInitOptions {
        return providerReturnValue
    }
}
