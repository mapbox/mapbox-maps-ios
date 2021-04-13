import XCTest
@testable import MapboxMaps

class MapInitOptionsIntegrationTests: XCTestCase {

    private var dataSourceReturnValue: MapInitOptions?

    override func tearDown() {
        super.tearDown()
        dataSourceReturnValue = nil
    }

    func testOptionsWithCustomCredentialsManager() {
        CredentialsManager.default.accessToken = "pk.aaaaaa"
        let credentialsManager = CredentialsManager(accessToken: "pk.cccccc")

        XCTAssertNotEqual(credentialsManager, CredentialsManager.default)

        let mapInitOptions = MapInitOptions(
            resourceOptions: ResourceOptions(accessToken: credentialsManager.accessToken))

        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        let resourceOptions = try! mapView.__map.getResourceOptions()

        XCTAssertEqual(resourceOptions, mapInitOptions.resourceOptions)
        XCTAssertEqual(resourceOptions.accessToken, credentialsManager.accessToken)
    }

    func testOptionsAreSetFromNibDataSource() {
        let credentialsManager = CredentialsManager(accessToken: "pk.dddddd")

        dataSourceReturnValue = MapInitOptions(
            resourceOptions: ResourceOptions(accessToken: credentialsManager.accessToken))

        // Load view from a nib, where the map view's datasource is the file's owner,
        // i.e. this test.
        let nib = UINib(nibName: "MapInitOptionsTests", bundle: .mapboxMapsTests)

        // Instantiate the view. The nib contains two MapViews, one has their
        // mapInitOptionsDataSource outlet connected to this test object (view
        // tag == 1), the other is nil (tag == 2)
        let objects = nib.instantiate(withOwner: self, options: nil)
        let mapView = objects.compactMap { $0 as? MapView }.first { $0.tag == 1 }!
        XCTAssertNotNil(mapView.mapInitOptionsDataSource)

        guard let optionsFromDataSource = mapView.mapInitOptionsDataSource?.mapInitOptions() else {
            XCTFail("MapInitOptions not returned from data source")
            return
        }

        // Check that the dataSource in MapView is correctly wired, so that the
        // expected options are returned
        XCTAssertEqual(optionsFromDataSource, dataSourceReturnValue)

        // Now check the resource options from the initialized MapView
        let resourceOptions = try! mapView.__map.getResourceOptions()

        XCTAssertEqual(resourceOptions, dataSourceReturnValue?.resourceOptions)
        XCTAssertEqual(resourceOptions.accessToken, credentialsManager.accessToken)
    }

    func testDefaultOptionsAreUsedWhenNibDoesntSetDataSource() {
        CredentialsManager.default.accessToken = "pk.eeeeee"

        // Load view from a nib, where the map view's datasource is nil
        let nib = UINib(nibName: "MapInitOptionsTests", bundle: .mapboxMapsTests)

        // Instantiate the view. The nib contains two MapViews, one has their
        // mapInitOptionsDataSource outlet connected to this test object (view
        // tag == 1), the other is nil (tag == 2)
        let objects = nib.instantiate(withOwner: self, options: nil)
        let mapView = objects.compactMap { $0 as? MapView }.first { $0.tag == 2 }!
        XCTAssertNil(mapView.mapInitOptionsDataSource)

        // Now check the resource options from the initialized MapView
        let resourceOptions = try! mapView.__map.getResourceOptions()

        XCTAssertEqual(resourceOptions, ResourceOptions(accessToken: CredentialsManager.default.accessToken))
        XCTAssertEqual(resourceOptions.accessToken, CredentialsManager.default.accessToken)
    }
}

extension MapInitOptionsIntegrationTests: MapInitOptionsDataSource {
    // This needs to return Any, since MapInitOptions is a struct, and this is
    // an objc delegate.
    public func mapInitOptions() -> MapInitOptions? {
        return dataSourceReturnValue
    }
}
