// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class SlotLayerTests: XCTestCase {

    func testLayerProtocolMembers() {

        var layer = SlotLayer(id: "test-id")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        XCTAssertEqual(layer.id, "test-id")
        XCTAssertEqual(layer.type, LayerType.slot)
        XCTAssertEqual(layer.minZoom, 10.0)
        XCTAssertEqual(layer.maxZoom, 20.0)
        XCTAssertEqual(layer.slot, Slot.testConstantValue())
    }

    func testEncodingAndDecodingOfLayerProtocolProperties() {
        var layer = SlotLayer(id: "test-id")
        layer.minZoom = 10.0
        layer.maxZoom = 20.0
        layer.slot = .testConstantValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode SlotLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode SlotLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(SlotLayer.self, from: validData)
            XCTAssertEqual(decodedLayer.id, "test-id")
            XCTAssertEqual(decodedLayer.type, LayerType.slot)
            XCTAssertEqual(layer.slot, Slot.testConstantValue())
        } catch {
            XCTFail("Failed to decode SlotLayer")
        }
    }

    func testEncodingAndDecodingOfLayoutProperties() {
        var layer = SlotLayer(id: "test-id")
        layer.visibility = .constant(.visible)

        var data: Data?
        do {
            data = try JSONEncoder().encode(layer)
        } catch {
            XCTFail("Failed to encode SlotLayer")
        }

        guard let validData = data else {
            XCTFail("Failed to encode SlotLayer")
            return
        }

        do {
            let decodedLayer = try JSONDecoder().decode(SlotLayer.self, from: validData)
            XCTAssert(decodedLayer.visibility == .constant(.visible))
        } catch {
            XCTFail("Failed to decode SlotLayer")
        }
    }

    func testEncodingAndDecodingOfPaintProperties() {
       let layer = SlotLayer(id: "test-id")

       var data: Data?
       do {
           data = try JSONEncoder().encode(layer)
       } catch {
           XCTFail("Failed to encode SlotLayer")
       }

       guard let validData = data else {
           XCTFail("Failed to encode SlotLayer")
           return
       }

       do {
           let decodedLayer = try JSONDecoder().decode(SlotLayer.self, from: validData)
           XCTAssert(decodedLayer.visibility == .constant(.visible))
       } catch {
           XCTFail("Failed to decode SlotLayer")
       }
    }

    func testSetPropertyValueWithFunction() {
        let layer = SlotLayer(id: "test-id")
            .slot(Slot.testConstantValue())

        XCTAssertEqual(layer.slot, Slot.testConstantValue())
    }
}

// End of generated file
