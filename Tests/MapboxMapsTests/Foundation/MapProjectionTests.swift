import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class MapProjectionTests: XCTestCase {

    func testNameProperty() {
        var projection = MapProjection.globe(GlobeMapProjection())
        XCTAssertEqual(projection.name, "globe")
        projection = MapProjection.mercator(MercatorMapProjection())
        XCTAssertEqual(projection.name, "mercator")
    }

}
