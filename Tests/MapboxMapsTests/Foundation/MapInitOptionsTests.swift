import XCTest
@testable import MapboxMaps

class MapInitOptionsTests: XCTestCase {

    func testDefaultStyleURIAndCamera() {
        let mapInitOptions = MapInitOptions()
        XCTAssert(mapInitOptions.styleURI == .standard)
        XCTAssertNil(mapInitOptions.cameraOptions)
    }

    func testEquality() {
        let a = MapInitOptions()
        let b = MapInitOptions()
        XCTAssertEqual(a, b)

        let c = MapInitOptions(mapOptions: MapOptions(constrainMode: .widthAndHeight))
        XCTAssertNotEqual(a, c)
    }

    func testHashable() {
        var set = Set<MapInitOptions>()

        let a = MapInitOptions()
        set.insert(a)

        let b = MapInitOptions()
        set.insert(b)

        XCTAssert(set.count == 1)
    }
}
