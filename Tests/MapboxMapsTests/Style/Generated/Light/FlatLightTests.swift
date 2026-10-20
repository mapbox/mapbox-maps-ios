// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class FlatLightTests: XCTestCase {

    func testFlatLightProperties() {
        var instance = FlatLight()
        instance.anchor = .testConstantValue()
        instance.color = .testConstantValue()
        instance.colorTransition = .testConstantValue()
        instance.colorUseTheme = .testConstantValue()
        instance.intensity = .testConstantValue()
        instance.intensityTransition = .testConstantValue()
        instance.position = .testConstantValue()
        instance.positionTransition = .testConstantValue()

        XCTAssertEqual(instance.anchor, .testConstantValue())
        XCTAssertEqual(instance.color, .testConstantValue())
        XCTAssertEqual(instance.colorTransition, .testConstantValue())
        XCTAssertEqual(instance.colorUseTheme, .testConstantValue())
        XCTAssertEqual(instance.intensity, .testConstantValue())
        XCTAssertEqual(instance.intensityTransition, .testConstantValue())
        XCTAssertEqual(instance.position, .testConstantValue())
        XCTAssertEqual(instance.positionTransition, .testConstantValue())
    }

    func testFlatLightSetters() {
        let instance = FlatLight()
            .anchor(Anchor.testConstantValue())
            .color(StyleColor.testConstantValue())
            .colorTransition(.testConstantValue())
            .colorUseTheme(.none)
            .intensity(Double.testConstantValue())
            .intensityTransition(.testConstantValue())
            .position(radial: 0, azimuthal: 1, polar: 2)
            .positionTransition(.testConstantValue())

        XCTAssertEqual(instance.anchor, Value.constant(Anchor.testConstantValue()))
        XCTAssertEqual(instance.color, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(instance.colorTransition, .testConstantValue())
        XCTAssertEqual(instance.colorUseTheme, .testConstantValue())
        XCTAssertEqual(instance.intensity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(instance.intensityTransition, .testConstantValue())
        XCTAssertEqual(instance.position, Value.constant([0, 1, 2]))
        XCTAssertEqual(instance.positionTransition, .testConstantValue())
    }

    func testFlatLightPropertySerialization() throws {
        var instance = FlatLight()
        instance.anchor = .testConstantValue()
        instance.color = .testConstantValue()
        instance.colorTransition = .testConstantValue()
        instance.colorUseTheme = .testConstantValue()
        instance.intensity = .testConstantValue()
        instance.intensityTransition = .testConstantValue()
        instance.position = .testConstantValue()
        instance.positionTransition = .testConstantValue()

        let data = try JSONEncoder().encode(instance)
        let decodedInstance = try JSONDecoder().decode(FlatLight.self, from: data)

        XCTAssertEqual(decodedInstance.anchor, .testConstantValue())
        XCTAssertEqual(decodedInstance.color, .testConstantValue())
        XCTAssertEqual(decodedInstance.colorTransition, .testConstantValue())
        XCTAssertEqual(decodedInstance.colorUseTheme, .testConstantValue())
        XCTAssertEqual(decodedInstance.intensity, .testConstantValue())
        XCTAssertEqual(decodedInstance.intensityTransition, .testConstantValue())
        XCTAssertEqual(decodedInstance.position, .testConstantValue())
        XCTAssertEqual(decodedInstance.positionTransition, .testConstantValue())
    }

    func testFlatLightSettersSerialization() throws {
        let instance = FlatLight()
            .anchor(Anchor.testConstantValue())
            .color(StyleColor.testConstantValue())
            .colorTransition(.testConstantValue())
            .colorUseTheme(.none)
            .intensity(Double.testConstantValue())
            .intensityTransition(.testConstantValue())
            .position(radial: 0, azimuthal: 1, polar: 2)
            .positionTransition(.testConstantValue())

        let data = try JSONEncoder().encode(instance)
        let decodedInstance = try JSONDecoder().decode(FlatLight.self, from: data)

        XCTAssertEqual(decodedInstance.anchor, Value.constant(Anchor.testConstantValue()))
        XCTAssertEqual(decodedInstance.color, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(decodedInstance.colorTransition, .testConstantValue())
        XCTAssertEqual(decodedInstance.colorUseTheme, .testConstantValue())
        XCTAssertEqual(decodedInstance.intensity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(decodedInstance.intensityTransition, .testConstantValue())
        XCTAssertEqual(decodedInstance.position, Value.constant([0, 1, 2]))
        XCTAssertEqual(decodedInstance.positionTransition, .testConstantValue())
    }
}

// End of generated file
