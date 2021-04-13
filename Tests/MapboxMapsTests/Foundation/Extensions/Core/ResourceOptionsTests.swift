import XCTest
import MapboxMaps

private class SubResourceOptions: ResourceOptions {
    override init() {
        super.init()
    }
}

class ResourceOptionsTests: XCTestCase {

    func testEquality() {
        let a = ResourceOptions()
        let b = ResourceOptions()
        let c = ResourceOptions(accessToken: "c")
        let d = SubResourceOptions()

        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
        XCTAssertNotEqual(a, d)
    }

    func testHashValue() {
        let a = ResourceOptions()
        let c = ResourceOptions(accessToken: "c")

        XCTAssertNotEqual(a.hashValue, 0)
        XCTAssertNotEqual(c.hashValue, 0)
        XCTAssertNotEqual(a.hashValue, c.hashValue)

        XCTAssertEqual(a.hash, a.hashValue)
    }

    func testAccessTokenFromDefaultInit() {
        let options = ResourceOptions()
        // Access token is "" here because of Swift creates a sane default
        // because of the nonnull attribute in Obj-C (and exposed in Swift as
        // `String`)
        XCTAssertEqual(options.accessToken, "")
    }
}
