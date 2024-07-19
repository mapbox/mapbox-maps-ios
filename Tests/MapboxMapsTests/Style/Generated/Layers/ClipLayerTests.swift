// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class ClipLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = ClipLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.clip)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = ClipLayer(id: "test-id", source: "source")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode ClipLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode ClipLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(ClipLayer.self, from: validData)
            XCTAssertEqual(decodedLayer.id, "test-id")
            XCTAssertEqual(decodedLayer.type, LayerType.clip)
            XCTAssert(decodedLayer.source == "source")
            XCTAssertEqual(decodedLayer.minZoom, 10.0)
            XCTAssertEqual(decodedLayer.maxZoom, 20.0)
            XCTAssertEqual(layer.slot, Slot.testConstantValue())
        } catch {
            XCTFail("Failed to decode ClipLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = ClipLayer(id: "test-id", source: "source")
        layer.visibility = .constant(.visible)
        layer.clipLayerTypes = Value<[ClipLayerTypes]>.testConstantValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode ClipLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode ClipLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(ClipLayer.self, from: validData)
            XCTAssert(decodedLayer.visibility == .constant(.visible))
            XCTAssertEqual(layer.clipLayerTypes, Value<[ClipLayerTypes]>.testConstantValue())
        } catch {
            XCTFail("Failed to decode ClipLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       let layer = ClipLayer(id: "test-id", source: "source")

       var data: Data?
       do {
           data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode ClipLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode ClipLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(ClipLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       } catch {
           XCTFail("Failed to decode ClipLayer")
       }
    }

    func testSetPropertyValueWithFunction() {
        let layer = ClipLayer(id: "test-id", source: "source")
            .filter(Exp.testConstantValue())
            .source(String.testConstantValue())
            .sourceLayer(String.testConstantValue())
            .slot(Slot.testConstantValue())
            .minZoom(Double.testConstantValue())
            .maxZoom(Double.testConstantValue())
            .clipLayerTypes([ClipLayerTypes].testConstantValue())

        XCTAssertEqual(layer.filter, Exp.testConstantValue())
        XCTAssertEqual(layer.source, String.testConstantValue())
        XCTAssertEqual(layer.sourceLayer, String.testConstantValue())
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
        XCTAssertEqual(layer.minZoom, Double.testConstantValue())
        XCTAssertEqual(layer.maxZoom, Double.testConstantValue())
        XCTAssertEqual(layer.clipLayerTypes, Value.constant([ClipLayerTypes].testConstantValue()))
    }
}

// End of generated file
