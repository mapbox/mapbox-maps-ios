import XCTest
@testable import MapboxMaps

class ResourceOptionsManagerTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        ResourceOptionsManager.destroyDefault()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        ResourceOptionsManager.destroyDefault()
    }

    func testInternalResourceOptionsManagerWithMainBundle() throws {
        // ResourceOptionsManager searches the application's main bundle
        // For tests, it shouldn't find a token resulting in a default of `nil`
        let rom = ResourceOptionsManager()
        XCTAssertEqual(rom.resourceOptions, ResourceOptionsManager.default.resourceOptions)
        XCTAssertEqual(rom.resourceOptions.accessToken, .default())

        // But these are different instances, so we should consider them separate
        XCTAssertFalse(rom === ResourceOptionsManager.default)
    }

    func testInternalResourceOptionsManagerWithMainBundle2() throws {
        // ResourceOptionsManager searches the application's main bundle
        // For tests, it shouldn't find a token resulting in a default of `nil`
        let options = ResourceOptions(accessToken: .default())
        let rom = ResourceOptionsManager(resourceOptions: options)
        XCTAssertEqual(rom.resourceOptions, ResourceOptionsManager.default.resourceOptions)
        XCTAssertEqual(rom.resourceOptions.accessToken, .default())

        // But these are different instances, so we should consider them separate
        XCTAssertFalse(rom === ResourceOptionsManager.default)
    }

    func testInternalResourceOptionsManagerWithTestBundle() throws {
        // Provide the test bundle. This should find an associated access token
        // Note - this behavior matches that of `mapboxAccessToken()`
        let resourceOptions = ResourceOptions(accessToken: .default(.mapboxMapsTests))
        let rom = ResourceOptionsManager(resourceOptions: resourceOptions)
        XCTAssertNotEqual(rom.resourceOptions.accessToken, "", "Did not find a test access token")
    }

    func testResettingResourceOptionsManager() throws {
        let token = ResourceOptionsManager.default.resourceOptions.accessToken

        ResourceOptionsManager.default.resourceOptions.accessToken = "custom-token"

        XCTAssertEqual("custom-token", ResourceOptionsManager.default.resourceOptions.accessToken, "Resource options is a value type")

        ResourceOptionsManager.destroyDefault()

        XCTAssertEqual(token, ResourceOptionsManager.default.resourceOptions.accessToken, "Token should have been reset")
    }
}
