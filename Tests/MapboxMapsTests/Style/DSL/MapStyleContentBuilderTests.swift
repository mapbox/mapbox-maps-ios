import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class MapStyleContentBuilderTests: XCTestCase {

    func testCompositeStyleContent() throws {
        let terrain = Terrain(sourceId: "DummyID")
        let atmosphere = Atmosphere()

        @MapStyleContentBuilder func content() -> MapStyleContent {
            terrain
            atmosphere
        }

        let composite = try XCTUnwrap(content() as? CompositeStyleContent)
        let visitor = MapStyleContentVisitor()
        composite._visit(visitor)

        XCTAssertEqual(composite.children.count, 2)
        XCTAssertEqual(visitor.model.layers, [:])
        XCTAssertEqual(visitor.model.sources, [:])
        XCTAssertEqual(visitor.model.images, [:])
        XCTAssertEqual(visitor.model.terrain, terrain)
        XCTAssertEqual(visitor.model.atmosphere, atmosphere)
        XCTAssertNil(visitor.model.projection)
    }

}
