import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class MapProjectionTests: XCTestCase {

    func testNameProperty() {
        var projection = MapProjection.globe()
        XCTAssertEqual(projection.name, "globe")
        projection = MapProjection.mercator()
        XCTAssertEqual(projection.name, "mercator")
    }

}
