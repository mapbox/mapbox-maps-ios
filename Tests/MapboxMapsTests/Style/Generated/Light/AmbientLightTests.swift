// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class AmbientLightTests: XCTestCase {

    func testAmbientLightProperties() {
        var instance = AmbientLight()
        instance.color = .testConstantValue()
        instance.colorTransition = .testConstantValue()
        instance.colorUseTheme = .testConstantValue()
        instance.intensity = .testConstantValue()
        instance.intensityTransition = .testConstantValue()

        XCTAssertEqual(instance.color, .testConstantValue())
        XCTAssertEqual(instance.colorTransition, .testConstantValue())
        XCTAssertEqual(instance.colorUseTheme, .testConstantValue())
        XCTAssertEqual(instance.intensity, .testConstantValue())
        XCTAssertEqual(instance.intensityTransition, .testConstantValue())
    }

    func testAmbientLightSetters() {
        let instance = AmbientLight()
            .color(StyleColor.testConstantValue())
            .colorTransition(.testConstantValue())
            .colorUseTheme(.none)
            .intensity(Double.testConstantValue())
            .intensityTransition(.testConstantValue())

        XCTAssertEqual(instance.color, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(instance.colorTransition, .testConstantValue())
        XCTAssertEqual(instance.colorUseTheme, .testConstantValue())
        XCTAssertEqual(instance.intensity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(instance.intensityTransition, .testConstantValue())
    }

    func testAmbientLightPropertySerialization() throws {
        var instance = AmbientLight()
        instance.color = .testConstantValue()
        instance.colorTransition = .testConstantValue()
        instance.colorUseTheme = .testConstantValue()
        instance.intensity = .testConstantValue()
        instance.intensityTransition = .testConstantValue()

        let data = try JSONEncoder().encode(instance)
        let decodedInstance = try JSONDecoder().decode(AmbientLight.self, from: data)

        XCTAssertEqual(decodedInstance.color, .testConstantValue())
        XCTAssertEqual(decodedInstance.colorTransition, .testConstantValue())
        XCTAssertEqual(decodedInstance.colorUseTheme, .testConstantValue())
        XCTAssertEqual(decodedInstance.intensity, .testConstantValue())
        XCTAssertEqual(decodedInstance.intensityTransition, .testConstantValue())
    }

    func testAmbientLightSettersSerialization() throws {
        let instance = AmbientLight()
            .color(StyleColor.testConstantValue())
            .colorTransition(.testConstantValue())
            .colorUseTheme(.none)
            .intensity(Double.testConstantValue())
            .intensityTransition(.testConstantValue())

        let data = try JSONEncoder().encode(instance)
        let decodedInstance = try JSONDecoder().decode(AmbientLight.self, from: data)

        XCTAssertEqual(decodedInstance.color, Value.constant(StyleColor.testConstantValue()))
        XCTAssertEqual(decodedInstance.colorTransition, .testConstantValue())
        XCTAssertEqual(decodedInstance.colorUseTheme, .testConstantValue())
        XCTAssertEqual(decodedInstance.intensity, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(decodedInstance.intensityTransition, .testConstantValue())
    }
}

// End of generated file
