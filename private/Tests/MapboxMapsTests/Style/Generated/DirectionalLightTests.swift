// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class DirectionalLightTests: XCTestCase {

    func testLightEncodingAndDecoding() throws {
        let lightID = UUID().uuidString
        var light = DirectionalLight(id: lightID)
        light.direction = Value<[Double]>.testConstantValue()
        light.directionTransition = StyleTransition(duration: 10.0, delay: 10.0)
        light.color = Value<StyleColor>.testConstantValue()
        light.colorTransition = StyleTransition(duration: 10.0, delay: 10.0)
        light.intensity = Value<Double>.testConstantValue()
        light.intensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
        light.castShadows = Value<Bool>.testConstantValue()
        light.shadowIntensity = Value<Double>.testConstantValue()
        light.shadowIntensityTransition = StyleTransition(duration: 10.0, delay: 10.0)

        let data = try JSONEncoder().encode(light)
        XCTAssertFalse(data.isEmpty)

        let decodedLight = try JSONDecoder().decode(DirectionalLight.self, from: data)

        XCTAssertEqual(decodedLight.lightType, Light3DType.directional)
        XCTAssertEqual(decodedLight.id, lightID)
        XCTAssertEqual(decodedLight.direction, Value<[Double]>.testConstantValue())
        XCTAssertEqual(decodedLight.directionTransition?.duration, 10)
        XCTAssertEqual(decodedLight.directionTransition?.delay, 10)
        XCTAssertEqual(decodedLight.color, Value<StyleColor>.testConstantValue())
        XCTAssertEqual(decodedLight.colorTransition?.duration, 10)
        XCTAssertEqual(decodedLight.colorTransition?.delay, 10)
        XCTAssertEqual(decodedLight.intensity, Value<Double>.testConstantValue())
        XCTAssertEqual(decodedLight.intensityTransition?.duration, 10)
        XCTAssertEqual(decodedLight.intensityTransition?.delay, 10)
        XCTAssertEqual(decodedLight.castShadows, Value<Bool>.testConstantValue())
        XCTAssertEqual(decodedLight.shadowIntensity, Value<Double>.testConstantValue())
        XCTAssertEqual(decodedLight.shadowIntensityTransition?.duration, 10)
        XCTAssertEqual(decodedLight.shadowIntensityTransition?.delay, 10)
    }
}

// End of generated file
