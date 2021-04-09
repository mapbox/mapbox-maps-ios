import XCTest
import MapboxMaps
import MapboxCoreMaps

class MapInitOptionsTests: XCTestCase {

    private var dataSourceReturnValue: Any = false
    private var oldDefaultAccessToken: String = ""

    override func setUp() {
        super.setUp()
        oldDefaultAccessToken = CredentialsManager.default.accessToken
    }
    override func tearDown() {
        super.tearDown()
        CredentialsManager.default.accessToken = oldDefaultAccessToken

        oldDefaultAccessToken = ""
        dataSourceReturnValue = false
    }

    func testDefaultMapInitOptionsAreOverridden() {
        do {
            let updatedMapInitOptions = MapInitOptions()
            XCTAssertNotEqual(updatedMapInitOptions.resourceOptions.accessToken, "pk.aaaaaa")
        }

        CredentialsManager.default.accessToken = "pk.aaaaaa"

        do {
            let updatedMapInitOptions = MapInitOptions()
            XCTAssertEqual(updatedMapInitOptions.resourceOptions.accessToken, "pk.aaaaaa")
        }
    }

    func testOverridingDefaultCredentialsManagerAccessToken() {
        CredentialsManager.default.accessToken = "pk.bbbbbb"

        let mapView = MapView(with: .zero)
        let resourceOptions = try! mapView.__map.getResourceOptions()

        XCTAssertEqual(resourceOptions, ResourceOptions(accessToken: CredentialsManager.default.accessToken))
        XCTAssertEqual(resourceOptions.accessToken, CredentialsManager.default.accessToken)
    }

    func testOptionsWithCustomCredentialsManager() {
        CredentialsManager.default.accessToken = "pk.aaaaaa"
        let credentialsManager = CredentialsManager(accessToken: "pk.cccccc")

        XCTAssertNotEqual(credentialsManager, CredentialsManager.default)

        let mapInitOptions = MapInitOptions(
            resourceOptions: ResourceOptions(accessToken: credentialsManager.accessToken))

        let mapView = MapView(with: .zero, mapInitOptions: mapInitOptions)
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
        let testBundle = Bundle.module
        let nib = UINib(nibName: "MapInitOptionsTests", bundle: testBundle)

        // Instantiate the view.
        let objects = nib.instantiate(withOwner: self, options: nil)

        let view = objects.first { object -> Bool in
            return (object as? MapView)?.tag == 1
        }

        guard let mapView = view as? MapView else {
            XCTFail("Not a MapView")
            return
        }
        XCTAssertNotNil(mapView.mapInitOptionsDataSource)

        guard let optionsFromDataSource = mapView.mapInitOptionsDataSource?.mapInitOptions() as? MapInitOptions else {
            XCTFail("MapInitOptions not returned from data source")
            return
        }

        guard let dataSourceReturnValue = self.dataSourceReturnValue as? MapInitOptions else {
            XCTFail("dataSourceReturnValue not a MapInitOptions")
            return
        }

        // Check that the dataSource in MapView is correctly wired, so that the
        // expected options are returned
        XCTAssertEqual(optionsFromDataSource, dataSourceReturnValue)

        // Now check the resource options from the initialized MapView
        let resourceOptions = try! mapView.__map.getResourceOptions()

        XCTAssertEqual(resourceOptions, dataSourceReturnValue.resourceOptions)
        XCTAssertEqual(resourceOptions.accessToken, credentialsManager.accessToken)
    }

    func testDefaultOptionsAreUsedWhenNibDoesntSetDataSource() {
        XCTAssert(dataSourceReturnValue is Bool )
        CredentialsManager.default.accessToken = "pk.eeeeee"

        // Load view from a nib, where the map view's datasource is nil
        let testBundle = Bundle.module
        let nib = UINib(nibName: "MapInitOptionsTests", bundle: testBundle)

        // Instantiate the view.
        let objects = nib.instantiate(withOwner: self, options: nil)

        // Second view doesn't have data source connected.
        let view = objects.first { object -> Bool in
            return (object as? MapView)?.tag == 2
        }

        guard let mapView = view as? MapView else {
            XCTFail("Not a MapView")
            return
        }
        XCTAssertNil(mapView.mapInitOptionsDataSource)

        // Now check the resource options from the initialized MapView
        let resourceOptions = try! mapView.__map.getResourceOptions()

        XCTAssertEqual(resourceOptions, ResourceOptions(accessToken: CredentialsManager.default.accessToken))
        XCTAssertEqual(resourceOptions.accessToken, CredentialsManager.default.accessToken)
    }
}

extension MapInitOptionsTests: MapInitOptionsDataSource {
    // This needs to return Any, since MapInitOptions is a struct, and this is
    // an objc delegate.
    public func mapInitOptions() -> Any {
        return dataSourceReturnValue
    }
}
