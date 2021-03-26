import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

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

    func testCoreMapsPositionEquality() {
        let a = MapboxCoreMaps.LayerPosition(above: nil, below: nil, at: nil)
        let b = MapboxCoreMaps.LayerPosition(above: nil, below: nil, at: nil)
        let c = MapboxCoreMaps.LayerPosition(above: "above", below: nil, at: nil)
        let d = MapboxCoreMaps.LayerPosition(above: "above", below: "below", at: nil)
        let e = MapboxCoreMaps.LayerPosition(above: "above", below: "below", at: 3)
        let f = MapboxCoreMaps.LayerPosition(above: "above", below: "below", at: 3)

        XCTAssertEqual(a, b)
        XCTAssertEqual(e, f)

        XCTAssertNotEqual(a, c)
        XCTAssertNotEqual(c, d)
        XCTAssertNotEqual(d, e)

        XCTAssertEqual(f.at, 3)
    }
}
