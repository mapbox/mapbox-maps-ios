// This file is generated
import XCTest
@testable import MapboxMaps

final class FillLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = FillLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.fill)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = FillLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode FillLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode FillLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(FillLayer.self, from: validData)
            XCTAssertEqual(decodedLayer.id, "test-id")
            XCTAssertEqual(decodedLayer.type, LayerType.fill)
            XCTAssert(decodedLayer.source == "source")
            XCTAssertEqual(decodedLayer.minZoom, 10.0)
            XCTAssertEqual(decodedLayer.maxZoom, 20.0)
        } catch {
            XCTFail("Failed to decode FillLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = FillLayer(id: "test-id", source: "source")
        layer.visibility = .constant(.visible)
        layer.fillSortKey = Value<Double>.testConstantValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode FillLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode FillLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(FillLayer.self, from: validData)
            XCTAssert(decodedLayer.visibility == .constant(.visible))
            XCTAssertEqual(layer.fillSortKey, Value<Double>.testConstantValue())
        } catch {
            XCTFail("Failed to decode FillLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       var layer = FillLayer(id: "test-id", source: "source")
       layer.fillAntialias = Value<Bool>.testConstantValue()
       layer.fillColor = Value<StyleColor>.testConstantValue()
       layer.fillColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillEmissiveStrength = Value<Double>.testConstantValue()
       layer.fillEmissiveStrengthTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillOpacity = Value<Double>.testConstantValue()
       layer.fillOpacityTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillOutlineColor = Value<StyleColor>.testConstantValue()
       layer.fillOutlineColorTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillPattern = Value<ResolvedImage>.testConstantValue()
       layer.fillTranslate = Value<[Double]>.testConstantValue()
       layer.fillTranslateTransition = StyleTransition(duration: 10.0, delay: 10.0)
       layer.fillTranslateAnchor = Value<FillTranslateAnchor>.testConstantValue()

       var data: Data?
       do {
           data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode FillLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode FillLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(FillLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
           XCTAssertEqual(layer.fillAntialias, Value<Bool>.testConstantValue())
           XCTAssertEqual(layer.fillColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.fillEmissiveStrength, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.fillOpacity, Value<Double>.testConstantValue())
           XCTAssertEqual(layer.fillOutlineColor, Value<StyleColor>.testConstantValue())
           XCTAssertEqual(layer.fillPattern, Value<ResolvedImage>.testConstantValue())
           XCTAssertEqual(layer.fillTranslate, Value<[Double]>.testConstantValue())
           XCTAssertEqual(layer.fillTranslateAnchor, Value<FillTranslateAnchor>.testConstantValue())
       } catch {
           XCTFail("Failed to decode FillLayer")
       }
    }
}

// End of generated file
