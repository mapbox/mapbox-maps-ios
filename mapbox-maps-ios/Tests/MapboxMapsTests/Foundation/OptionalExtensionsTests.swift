@testable import MapboxMaps
import XCTest

final class OptionalExtensionTests: XCTestCase {
    func testAsArray() {
        var a: Int?

        XCTAssertEqual(a.asArray, [])
        a = 5

        XCTAssertEqual(a.asArray, [5])
    }
}
