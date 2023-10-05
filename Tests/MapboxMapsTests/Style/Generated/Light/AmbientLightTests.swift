// This file is generated
import XCTest
@testable import MapboxMaps

final class AmbientLightTests: XCTestCase {

    func testLightEncodingAndDecoding() throws {
        let lightID = UUID().uuidString
        var light = AmbientLight(id: lightID)
        light.color = Value<StyleColor>.testConstantValue()
        light.colorTransition = StyleTransition(duration: 10.0, delay: 10.0)
        light.intensity = Value<Double>.testConstantValue()
        light.intensityTransition = StyleTransition(duration: 10.0, delay: 10.0)

        let data = try JSONEncoder().encode(light)
        XCTAssertFalse(data.isEmpty)

        let decodedLight = try JSONDecoder().decode(AmbientLight.self, from: data)

        XCTAssertEqual(decodedLight.id, lightID)
        XCTAssertEqual(decodedLight.color, Value<StyleColor>.testConstantValue())
        XCTAssertEqual(decodedLight.colorTransition?.duration, 10)
        XCTAssertEqual(decodedLight.colorTransition?.delay, 10)
        XCTAssertEqual(decodedLight.intensity, Value<Double>.testConstantValue())
        XCTAssertEqual(decodedLight.intensityTransition?.duration, 10)
        XCTAssertEqual(decodedLight.intensityTransition?.delay, 10)
    }
}

// End of generated file
