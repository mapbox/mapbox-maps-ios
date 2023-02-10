import XCTest
@testable import MapboxMaps

final class Encodable_ToJSONTests: XCTestCase {
    func testToJSON() {
        XCTAssertEqual(try 1.toJSON() as? Int, 1)
        XCTAssertEqual(try 1.0.toJSON() as? Double, 1.0)
        XCTAssertEqual(try "abc".toJSON() as? String, "abc")
        XCTAssertEqual(try true.toJSON() as? Bool, true)
        XCTAssertEqual(try false.toJSON() as? Bool, false)
        XCTAssertEqual(try String?.none.toJSON() as? NSNull, NSNull())
        XCTAssertEqual(try ["abc", "def"].toJSON() as? [String], ["abc", "def"])
        XCTAssertEqual(try ["abc": "def"].toJSON() as? [String: String], ["abc": "def"])
    }
}
