import XCTest
import MapboxMaps
import MapboxCoreMaps

class CredentialsManagerTests: XCTestCase {

    private var oldDefaultAccessToken: String = ""

    override func setUp() {
        super.setUp()
        oldDefaultAccessToken = CredentialsManager.default.accessToken
    }

    override func tearDown() {
        super.tearDown()
        CredentialsManager.default.accessToken = oldDefaultAccessToken
        oldDefaultAccessToken = ""
    }

    func testNewInstanceIsNotDefault() {
        let cm = CredentialsManager(accessToken: "pk.aaaaaa")
        XCTAssertNotEqual(cm, CredentialsManager.default)
    }

    func testAccessTokenIsObfuscated() {
        CredentialsManager.default.accessToken = "pk.HelloWorld"
        XCTAssertEqual(CredentialsManager.default.description, "CredentialsManager: pk.H◻︎◻︎◻︎◻︎◻︎◻︎◻︎◻︎◻︎")
    }
}
