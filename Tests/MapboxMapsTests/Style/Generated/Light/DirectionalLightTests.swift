// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class DirectionalLightTests: XCTestCase {

    func testDirectionalLightProperties() {
        var instance = DirectionalLight()
        instance.castShadows = .testConstantValue()
        instance.color = .testConstantValue()
        instance.colorTransition = .testConstantValue()
        instance.colorUseTheme = .testConstantValue()
        instance.direction = .testConstantValue()
        instance.directionTransition = .testConstantValue()
        instance.intensity = .testConstantValue()
        instance.intensityTransition = .testConstantValue()
        instance.shadowDrawBeforeLayer = .testConstantValue()
        instance.shadowIntensity = .testConstantValue()
        instance.shadowIntensityTransition = .testConstantValue()

        XCTAssertEqual(instance.castShadows, .testConstantValue())
        XCTAssertEqual(instance.color, .testConstantValue())
        XCTAssertEqual(instance.colorTransition, .testConstantValue())
        XCTAssertEqual(instance.colorUseTheme, .testConstantValue())
        XCTAssertEqual(instance.direction, .testConstantValue())
        XCTAssertEqual(instance.directionTransition, .testConstantValue())
        XCTAssertEqual(instance.intensity, .testConstantValue())
        XCTAssertEqual(instance.intensityTransition, .testConstantValue())
        XCTAssertEqual(instance.shadowDrawBeforeLayer, .testConstantValue())
        XCTAssertEqual(instance.shadowIntensity, .testConstantValue())
        XCTAssertEqual(instance.shadowIntensityTransition, .testConstantValue())
    }

    func testDirectionalLightSetters() {
        let instance = DirectionalLight()
            .castShadows(Bool.testConstantValue())
            .color(StyleColor.testConstantValue())
            .colorTransition(.testConstantValue())
            .colorUseTheme(.none)
            .direction(azimuthal: 0, polar: 1)
            .directionTransition(.testConstantValue())
            .intensity(Double.testConstantValue())
            .intensityTransition(.testConstantValue())
            .shadowDrawBeforeLayer(String.testConstantValue())
            .shadowIntensity(Double.testConstantValue())
            .shadowIntensityTransition(.testConstantValue())

        XCTAssertEqual(instance.castShadows, Value.constant(Bool.testConstantValue()))
        XCTAssertEqual(instance.color, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(instance.colorTransition, .testConstantValue())
        XCTAssertEqual(instance.colorUseTheme, .testConstantValue())
        XCTAssertEqual(instance.direction, Value.constant([0, 1]))
        XCTAssertEqual(instance.directionTransition, .testConstantValue())
        XCTAssertEqual(instance.intensity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(instance.intensityTransition, .testConstantValue())
        XCTAssertEqual(instance.shadowDrawBeforeLayer, Value.constant(String.testConstantValue()))
        XCTAssertEqual(instance.shadowIntensity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(instance.shadowIntensityTransition, .testConstantValue())
    }

    func testDirectionalLightPropertySerialization() throws {
        var instance = DirectionalLight()
        instance.castShadows = .testConstantValue()
        instance.color = .testConstantValue()
        instance.colorTransition = .testConstantValue()
        instance.colorUseTheme = .testConstantValue()
        instance.direction = .testConstantValue()
        instance.directionTransition = .testConstantValue()
        instance.intensity = .testConstantValue()
        instance.intensityTransition = .testConstantValue()
        instance.shadowDrawBeforeLayer = .testConstantValue()
        instance.shadowIntensity = .testConstantValue()
        instance.shadowIntensityTransition = .testConstantValue()

        let data = try JSONEncoder().encode(instance)
        let decodedInstance = try JSONDecoder().decode(DirectionalLight.self, from: data)

        XCTAssertEqual(decodedInstance.castShadows, .testConstantValue())
        XCTAssertEqual(decodedInstance.color, .testConstantValue())
        XCTAssertEqual(decodedInstance.colorTransition, .testConstantValue())
        XCTAssertEqual(decodedInstance.colorUseTheme, .testConstantValue())
        XCTAssertEqual(decodedInstance.direction, .testConstantValue())
        XCTAssertEqual(decodedInstance.directionTransition, .testConstantValue())
        XCTAssertEqual(decodedInstance.intensity, .testConstantValue())
        XCTAssertEqual(decodedInstance.intensityTransition, .testConstantValue())
        XCTAssertEqual(decodedInstance.shadowDrawBeforeLayer, .testConstantValue())
        XCTAssertEqual(decodedInstance.shadowIntensity, .testConstantValue())
        XCTAssertEqual(decodedInstance.shadowIntensityTransition, .testConstantValue())
    }

    func testDirectionalLightSettersSerialization() throws {
        let instance = DirectionalLight()
            .castShadows(Bool.testConstantValue())
            .color(StyleColor.testConstantValue())
            .colorTransition(.testConstantValue())
            .colorUseTheme(.none)
            .direction(azimuthal: 0, polar: 1)
            .directionTransition(.testConstantValue())
            .intensity(Double.testConstantValue())
            .intensityTransition(.testConstantValue())
            .shadowDrawBeforeLayer(String.testConstantValue())
            .shadowIntensity(Double.testConstantValue())
            .shadowIntensityTransition(.testConstantValue())

        let data = try JSONEncoder().encode(instance)
        let decodedInstance = try JSONDecoder().decode(DirectionalLight.self, from: data)

        XCTAssertEqual(decodedInstance.castShadows, Value.constant(Bool.testConstantValue()))
        XCTAssertEqual(decodedInstance.color, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(decodedInstance.colorTransition, .testConstantValue())
        XCTAssertEqual(decodedInstance.colorUseTheme, .testConstantValue())
        XCTAssertEqual(decodedInstance.direction, Value.constant([0, 1]))
        XCTAssertEqual(decodedInstance.directionTransition, .testConstantValue())
        XCTAssertEqual(decodedInstance.intensity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(decodedInstance.intensityTransition, .testConstantValue())
        XCTAssertEqual(decodedInstance.shadowDrawBeforeLayer, Value.constant(String.testConstantValue()))
        XCTAssertEqual(decodedInstance.shadowIntensity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(decodedInstance.shadowIntensityTransition, .testConstantValue())
    }
}

// End of generated file
