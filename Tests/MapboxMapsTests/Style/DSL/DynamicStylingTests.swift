import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class DynamicStylingTests: XCTestCase {

    func testAtmosphereSetPropertyValueWithFunction() {
        let atmosphere = Atmosphere()
            .color(StyleColor.testConstantValue())
            .highColor(StyleColor.testConstantValue())
            .horizonBlend(Double.testConstantValue())
            .range(start: 0, end: 1)
            .spaceColor(StyleColor.testConstantValue())
            .starIntensity(Double.testConstantValue())

        XCTAssertEqual(atmosphere.color, Value<StyleColor>.constant(.testConstantValue()))
        XCTAssertEqual(atmosphere.highColor, Value<StyleColor>.constant(.testConstantValue()))
        XCTAssertEqual(atmosphere.horizonBlend, Value<Double>.testConstantValue())
        XCTAssertEqual(atmosphere.range, .constant([0, 1]))
        XCTAssertEqual(atmosphere.spaceColor, Value<StyleColor>.constant(.testConstantValue()))
        XCTAssertEqual(atmosphere.starIntensity, Value<Double>.testConstantValue())
    }

    func testTerrainSetPropertyValueWithFunction() {
        let terrain = Terrain(sourceId: "test")
            .exaggeration(Double.testConstantValue())

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
}
