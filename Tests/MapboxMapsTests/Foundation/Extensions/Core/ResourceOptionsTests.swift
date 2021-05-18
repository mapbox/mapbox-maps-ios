import XCTest
import MapboxMaps

private class SubResourceOptions: ResourceOptions {
    convenience init() {
        self.init(accessToken: "overridden")
    }
}

class ResourceOptionsTests: XCTestCase {

    func testEquality() {
        let a = ResourceOptions(accessToken: "a")
        let b = ResourceOptions(accessToken: "a")
        let c = ResourceOptions(accessToken: "c")
        let d = SubResourceOptions()

        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
        XCTAssertNotEqual(a, d)
    }

    func testHashValue() {
        let a = ResourceOptions(accessToken: "a")
        let c = ResourceOptions(accessToken: "c")

        XCTAssertNotEqual(a.hashValue, 0)
        XCTAssertNotEqual(c.hashValue, 0)
        XCTAssertNotEqual(a.hashValue, c.hashValue)

        XCTAssertEqual(a.hashValue, a.hashValue)
    }
}
