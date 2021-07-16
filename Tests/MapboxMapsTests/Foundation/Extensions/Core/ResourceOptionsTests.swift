import XCTest
import MapboxMaps

class ResourceOptionsTests: XCTestCase {

    func testEquality() {
        let a = ResourceOptions(accessToken: "a")
        let b = ResourceOptions(accessToken: "a")
        let c = ResourceOptions(accessToken: "c")

        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func testHashValue() {
        let a = ResourceOptions(accessToken: "a")
        let c = ResourceOptions(accessToken: "c")

        XCTAssertNotEqual(a.hashValue, 0)
        XCTAssertNotEqual(c.hashValue, 0)
        XCTAssertNotEqual(a.hashValue, c.hashValue)

        XCTAssertEqual(a.hashValue, a.hashValue)
    }

    func testAccessTokenIsObfuscated() {
        let a = ResourceOptions(accessToken: "pk.HelloWorld")
        XCTAssertEqual(a.description, "ResourceOptions: pk.H◻︎◻︎◻︎◻︎◻︎◻︎◻︎◻︎◻︎")
    }
}
