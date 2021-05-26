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
        let options = ResourceOptions(accessToken: "pk.aaaaaa")
        let rom = ResourceOptionsManager(resourceOptions: options)
        XCTAssertNotEqual(rom, ResourceOptionsManager.default)
    }

    func testInternalCredentialsManagerWithMainBundle() throws {
        // CredentialsManager searches the application's main bundle
        // For tests, it shouldn't find a token resulting in a default of `nil`
        let rom = ResourceOptionsManager(resourceOptions: nil)
        XCTAssertEqual(rom, ResourceOptionsManager.default)
        XCTAssertEqual(rom.resourceOptions.accessToken, "")
    }

    func testInternalCredentialsManagerWithTestBundle() throws {
        // Provide the test bundle. This should find an associated access token
        // Note - this behavior matches that of `mapboxAccessToken()`
        let rom = ResourceOptionsManager(resourceOptions: nil, for: .mapboxMapsTests)
        XCTAssertNotEqual(rom.resourceOptions.accessToken, "", "Did not find a test access token")
    }

    func testResettingCredentialsManager() throws {
        let rom = ResourceOptionsManager(resourceOptions: nil, for: .mapboxMapsTests)
        let token = rom.resourceOptions.accessToken

        rom.update { options in
            options.accessToken = "custom-token"
        }

        XCTAssertEqual("custom-token", rom.resourceOptions.accessToken, "Resource options is a value type")

        rom.reset()

        XCTAssertEqual(token, rom.resourceOptions.accessToken, "Token should have been reset")
    }
}
