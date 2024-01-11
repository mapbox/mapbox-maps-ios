import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class DynamicStylingTests: XCTestCase {

    func testAtmosphereSetPropertyValueWithFunction() {
        let atmosphere = Atmosphere()
            .color(Value<StyleColor>.testConstantValue())
            .highColor(Value<StyleColor>.testConstantValue())
            .horizonBlend(Value<Double>.testConstantValue())
            .range(Value<[Double]>.testConstantValue())
            .spaceColor(Value<StyleColor>.testConstantValue())
            .starIntensity(Value<Double>.testConstantValue())

        XCTAssertEqual(atmosphere.color, Value<StyleColor>.testConstantValue())
        XCTAssertEqual(atmosphere.highColor, Value<StyleColor>.testConstantValue())
        XCTAssertEqual(atmosphere.horizonBlend, Value<Double>.testConstantValue())
        XCTAssertEqual(atmosphere.range, Value<[Double]>.testConstantValue())
        XCTAssertEqual(atmosphere.spaceColor, Value<StyleColor>.testConstantValue())
        XCTAssertEqual(atmosphere.starIntensity, Value<Double>.testConstantValue())
    }

    func testTerrainSetPropertyValueWithFunction() {
        let terrain = Terrain(sourceId: "test")
            .exaggeration(Value<Double>.testConstantValue())

        XCTAssertEqual(terrain.exaggeration, Value<Double>.testConstantValue())
    }

    func testStyleImageSetPropertyValueWithFunction() {
        let id = "ID"
        let image = UIImage()
        let styleImage = StyleImage(id: id, image: image)
            .sdf(Bool.testConstantValue())
            .contentInsets(UIEdgeInsets.testConstantValue())

        XCTAssertEqual(styleImage.sdf, Bool.testConstantValue())
        XCTAssertEqual(styleImage.contentInsets, UIEdgeInsets.testConstantValue())
    }

    // Test isEqual

    struct Dummy {
        let id: Int
        let name: String
    }

    func testEqualityByID() {
        let dummy1 = Dummy(id: 1, name: "Test")
        let dummy2 = Dummy(id: 1, name: "Test2")

        let areEqual = MapboxMaps.isEqual(by: \Dummy.id, lhs: dummy1, rhs: dummy2)

        XCTAssertTrue(areEqual, "Expected IDs to be equal but they are not.")
    }

    func testInequalityByID() {
        let dummy1 = Dummy(id: 1, name: "Test")
        let dummy2 = Dummy(id: 2, name: "Test2")

        let areEqual = MapboxMaps.isEqual(by: \Dummy.id, lhs: dummy1, rhs: dummy2)

        XCTAssertFalse(areEqual, "Expected IDs to be different but they are not.")
    }

    func testEqualityByName() {
        let dummy1 = Dummy(id: 1, name: "Test")
        let dummy2 = Dummy(id: 1, name: "Test")

        let areEqual = MapboxMaps.isEqual(by: \Dummy.name, lhs: dummy1, rhs: dummy2)

        XCTAssertTrue(areEqual, "Expected names to be equal but they are not.")
    }

    func testInequalityByName() {
        let dummy1 = Dummy(id: 1, name: "Test")
        let dummy2 = Dummy(id: 1, name: "Test2")

        let areEqual = MapboxMaps.isEqual(by: \Dummy.name, lhs: dummy1, rhs: dummy2)

        XCTAssertFalse(areEqual, "Expected names to be different but they are not.")
    }
}
