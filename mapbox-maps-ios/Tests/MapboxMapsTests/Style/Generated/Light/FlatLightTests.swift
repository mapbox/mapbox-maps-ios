// This file is generated
import XCTest
@testable import MapboxMaps

final class FlatLightTests: XCTestCase {

    func testLightEncodingAndDecoding() throws {
        let lightID = UUID().uuidString
        var light = FlatLight(id: lightID)
        light.anchor = Value<Anchor>.testConstantValue()
        light.color = Value<StyleColor>.testConstantValue()
        light.colorTransition = StyleTransition(duration: 10.0, delay: 10.0)
        light.intensity = Value<Double>.testConstantValue()
        light.intensityTransition = StyleTransition(duration: 10.0, delay: 10.0)
        light.position = Value<[Double]>.testConstantValue()
        light.positionTransition = StyleTransition(duration: 10.0, delay: 10.0)

        let data = try JSONEncoder().encode(light)
        XCTAssertFalse(data.isEmpty)

        let decodedLight = try JSONDecoder().decode(FlatLight.self, from: data)

        XCTAssertEqual(decodedLight.id, lightID)
        XCTAssertEqual(decodedLight.anchor, Value<Anchor>.testConstantValue())
        XCTAssertEqual(decodedLight.color, Value<StyleColor>.testConstantValue())
        XCTAssertEqual(decodedLight.colorTransition?.duration, 10)
        XCTAssertEqual(decodedLight.colorTransition?.delay, 10)
        XCTAssertEqual(decodedLight.intensity, Value<Double>.testConstantValue())
        XCTAssertEqual(decodedLight.intensityTransition?.duration, 10)
        XCTAssertEqual(decodedLight.intensityTransition?.delay, 10)
        XCTAssertEqual(decodedLight.position, Value<[Double]>.testConstantValue())
        XCTAssertEqual(decodedLight.positionTransition?.duration, 10)
        XCTAssertEqual(decodedLight.positionTransition?.delay, 10)
    }
}

// End of generated file
