import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

final class LayerPositionTests: XCTestCase {
    func testPositionEquality() {
        let a = LayerPosition(above: nil, below: nil, at: nil)
        let b = LayerPosition(above: nil, below: nil, at: nil)
        let c = LayerPosition(above: "above", below: nil, at: nil)
        let d = LayerPosition(above: "above", below: "below", at: nil)
        let e = LayerPosition(above: "above", below: "below", at: 3)
        let f = LayerPosition(above: "above", below: "below", at: 3)

        XCTAssertEqual(a, b)
        XCTAssertEqual(e, f)

        XCTAssertNotEqual(a,c)
        XCTAssertNotEqual(c,d)
        XCTAssertNotEqual(d,e)

        XCTAssertEqual(f.at, 3)
    }
}
