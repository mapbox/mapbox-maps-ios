import XCTest
@testable import MapboxMaps

class CredentialsManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        CredentialsManager.default.accessToken = nil
    }

    override func tearDown() {
        super.tearDown()
        CredentialsManager.default.accessToken = nil
    }

    func testNewInstanceIsNotDefault() {
        let cm = CredentialsManager(accessToken: "pk.aaaaaa")
        XCTAssertNotEqual(cm, CredentialsManager.default)
    }

    func testAccessTokenIsObfuscated() {
        CredentialsManager.default.accessToken = "pk.HelloWorld"
        XCTAssertEqual(CredentialsManager.default.description, "CredentialsManager: pk.H◻︎◻︎◻︎◻︎◻︎◻︎◻︎◻︎◻︎")
    }

    func testInternalCredentialsManagerWithMainBundle() throws {
        // CredentialsManager searches the application's main bundle
        // For tests, it shouldn't find a token resulting in a default of `nil`
        let cm = CredentialsManager(accessToken: nil)
        XCTAssertEqual(cm, CredentialsManager.default)
        XCTAssertNil(cm.accessToken)
    }

    func testInternalCredentialsManagerWithTestBundle() throws {
        // Provide the test bundle. This should find an associated access token
        // Note - this behavior matches that of `mapboxAccessToken()`
        let cm = CredentialsManager(accessToken: nil, for: .mapboxMapsTests)
        XCTAssertNotEqual(cm.accessToken, "", "Did not find a test access token")
    }

    func testResettingCredentialsManager() {
        let cm = CredentialsManager(accessToken: nil, for: .mapboxMapsTests)
        let token = cm.accessToken

        cm.accessToken = "custom-token"
        cm.accessToken = nil

        XCTAssertEqual(token, cm.accessToken, "Token should have been reset")
    }
}
