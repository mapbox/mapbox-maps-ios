import XCTest
@testable import MapboxMaps

final class LayerPositionTests: XCTestCase {

    func testPositionEnumEquality() {
        let a = LayerPosition.default
        let b = LayerPosition.default
        let c = LayerPosition.above("something")
        let d = LayerPosition.above("something-else")
        let e = LayerPosition.below("something")
        let f = LayerPosition.below("something-else")
        let g = LayerPosition.at(3)
        let h = LayerPosition.at(4)

        XCTAssertEqual(a, b)
        XCTAssertNotEqual(c, d)
        XCTAssertNotEqual(c, e)
        XCTAssertNotEqual(d, f)
        XCTAssertNotEqual(e, f)
        XCTAssertNotEqual(g, h)
    }
}
