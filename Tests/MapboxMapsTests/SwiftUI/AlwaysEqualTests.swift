@testable import MapboxMaps
import XCTest

final class AlwaysEqualTests: XCTestCase {
    func testAlwaysEqual() {
        XCTAssertEqual(AlwaysEqual(value: 1), AlwaysEqual(value: 2))

        let closure = {}
        XCTAssertEqual(AlwaysEqual(value: closure), AlwaysEqual(value: closure))
    }

    func testOptionalAlwaysEqual() {
        let i: AlwaysEqual<Int>? = AlwaysEqual(value: 5)
        XCTAssertNotEqual(i, nil)

        let v: AlwaysEqual<Int>? = AlwaysEqual(value: 2)
        XCTAssertEqual(i, v)
    }
}
