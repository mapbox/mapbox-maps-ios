import XCTest
@_spi(Experimental) @testable import MapboxMaps

class CustomLayerTestCase: XCTestCase {
    let renderer = EmptyCustomRenderer()

    func testDefaultValues() {
        let layer = CustomLayer(id: "test", renderer: renderer)

        XCTAssertEqual(layer.type, .custom)
        XCTAssertEqual(layer.visibility, .constant(.visible))
    }

    func testCustomInitializer() {
        let customLayer = buildCustomLayer()

        XCTAssertEqual(customLayer.id, "test")
        XCTAssertTrue(customLayer.renderer === renderer)
        XCTAssertEqual(customLayer.slot, "test-slot")
        XCTAssertEqual(customLayer.minZoom, 10)
        XCTAssertEqual(customLayer.maxZoom, 13)
        XCTAssertEqual(customLayer.visibility, .constant(.none))
    }

    func testCodableSupport() throws {
        let customLayer = buildCustomLayer()

        let data = try JSONEncoder().encode(customLayer)
        let decodedCustomLayer = try JSONDecoder().decode(CustomLayer.self, from: data)

        XCTAssertEqual(decodedCustomLayer.id, customLayer.id)
        XCTAssertEqual(decodedCustomLayer.slot, customLayer.slot)
        XCTAssertEqual(decodedCustomLayer.minZoom, customLayer.minZoom)
        XCTAssertEqual(decodedCustomLayer.maxZoom, customLayer.maxZoom)
        XCTAssertEqual(decodedCustomLayer.visibility, customLayer.visibility)

        XCTAssertTrue(decodedCustomLayer.renderer is EmptyCustomRenderer)
        XCTAssertFalse(decodedCustomLayer.renderer === customLayer.renderer)
    }

    func testSetPropertyValueWithFunction() {
        let buildCustomLayer = buildCustomLayer()

        let constructCustomLayer = CustomLayer(id: "test", renderer: renderer)
            .slot("test-slot")
            .minZoom(10)
            .maxZoom(13)
            .visibility(.constant(.none))
            .renderer(renderer)

        XCTAssertEqual(constructCustomLayer.slot, "test-slot")
        XCTAssertEqual(constructCustomLayer.minZoom, 10)
        XCTAssertEqual(constructCustomLayer.maxZoom, 13)
        XCTAssertEqual(constructCustomLayer.visibility, .constant(.none))
        XCTAssertEqual(constructCustomLayer.renderer as? EmptyCustomRenderer, renderer)
        XCTAssertEqual(buildCustomLayer, constructCustomLayer)
    }
}

extension CustomLayerTestCase {
    func buildCustomLayer() -> CustomLayer {
        CustomLayer(
            id: "test",
            renderer: renderer,
            slot: "test-slot",
            minZoom: 10,
            maxZoom: 13,
            visibility: .constant(.none)
        )
    }
}
