import XCTest
@testable import MapboxMaps

class ResourceOptionsManagerTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        ResourceOptionsManager.default.reset()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        ResourceOptionsManager.destroyDefault()
    }

    func testNewInstanceIsNotDefault() throws {
        let rom = ResourceOptionsManager(accessToken: "pk.aaaaaa")
        XCTAssertNotEqual(rom, ResourceOptionsManager.default)
    }

    func testInternalResourceOptionsManagerWithMainBundle() throws {
        // ResourceOptionsManager searches the application's main bundle
        // For tests, it shouldn't find a token resulting in a default of `nil`
        let rom = ResourceOptionsManager(accessToken: nil)
        XCTAssertEqual(rom.resourceOptions, ResourceOptionsManager.default.resourceOptions)
        XCTAssertEqual(rom.resourceOptions.accessToken, "")

        // But these are different instances, so we should consider them separate
        XCTAssertFalse(rom === ResourceOptionsManager.default)
        XCTAssertEqual(rom, ResourceOptionsManager.default)
    }

    func testInternalResourceOptionsManagerWithTestBundle() throws {
        // Provide the test bundle. This should find an associated access token
        // Note - this behavior matches that of `mapboxAccessToken()`
        let rom = ResourceOptionsManager(accessToken: nil, for: .mapboxMapsTests)
        XCTAssertNotEqual(rom.resourceOptions.accessToken, "", "Did not find a test access token")
    }

    func testResettingResourceOptionsManager() throws {
        let rom = ResourceOptionsManager(accessToken: nil, for: .mapboxMapsTests)
        let token = rom.resourceOptions.accessToken

        rom.update { options in
            options.accessToken = "custom-token"
        }

        XCTAssertEqual("custom-token", rom.resourceOptions.accessToken, "Resource options is a value type")

        rom.reset()

        XCTAssertEqual(token, rom.resourceOptions.accessToken, "Token should have been reset")
    }
}
