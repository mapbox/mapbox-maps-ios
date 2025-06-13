import XCTest
@testable import MapboxMaps

final class PromoteIdTests: XCTestCase {
    @available(*, deprecated)
    func testVectorSourcePromoteIdGlobalConversion() {
        let constant = "property_name"
        let globalPromoteId = VectorSourcePromoteId.global(.constant(constant))

        let promoteId = PromoteId(from: globalPromoteId)
        XCTAssertEqual(promoteId, .string(constant))

        let roundTrip = VectorSourcePromoteId(from: promoteId)
        XCTAssertEqual(roundTrip, globalPromoteId)
    }

    @available(*, deprecated)
    func testVectorSourcePromoteIdByLayerConversion() {
        let layerToPropertyMap = [
            "layer1": Value<String>.constant("property1"),
            "layer2": Value<String>.constant("property2")
        ]
        let byLayerPromoteId = VectorSourcePromoteId.byLayer(layerToPropertyMap)

        let promoteId = PromoteId(from: byLayerPromoteId)
        XCTAssertEqual(promoteId, .object(["layer1": "property1", "layer2": "property2"]))

        let roundTrip = VectorSourcePromoteId(from: promoteId)
        XCTAssertEqual(roundTrip, byLayerPromoteId)
    }

    @available(*, deprecated)
    func testVectorSourcePromoteIdWithExpression() {
        let expression = Exp(.get, "dynamic_property")
        let globalPromoteIdWithExp = VectorSourcePromoteId.global(.expression(expression))

        let promoteId = PromoteId(from: globalPromoteIdWithExp)
        XCTAssertNil(promoteId)

        let layerToExpressionMap = [
            "layer1": Value<String>.expression(Exp(.get, "dynamic_property1")),
            "layer2": Value<String>.constant("static_property")
        ]
        let byLayerPromoteIdWithExp = VectorSourcePromoteId.byLayer(layerToExpressionMap)

        let byLayerPromoteId = PromoteId(from: byLayerPromoteIdWithExp)
        XCTAssertEqual(byLayerPromoteId, .object(["layer2": "static_property"]))
    }

    @available(*, deprecated)
    func testPromoteIdStringToVectorSourcePromoteId() {
        let stringPromoteId = PromoteId.string("property_id")

        let vectorPromoteId = VectorSourcePromoteId(from: stringPromoteId)
        XCTAssertEqual(vectorPromoteId, .global(.constant("property_id")))
    }

    @available(*, deprecated)
    func testPromoteIdObjectToVectorSourcePromoteId() {
        let dict = ["layer1": "property1", "layer2": "property2"]
        let objectPromoteId = PromoteId.object(dict)

        let vectorPromoteId = VectorSourcePromoteId(from: objectPromoteId)
        XCTAssertEqual(vectorPromoteId, .byLayer([
            "layer1": .constant("property1"),
            "layer2": .constant("property2")
        ]))
    }

    @available(*, deprecated)
    func testVectorSourcePromoteIdInVectorSource() {
        var source = VectorSource(id: "test-source")
        let promoteId = VectorSourcePromoteId.global(.constant("property_id"))
        source.promoteId2 = promoteId

        XCTAssertEqual(source.promoteId2, promoteId)

        XCTAssertEqual(source.promoteId, .string("property_id"))

        let newPromoteId = PromoteId.object(["layer": "layer_prop"])
        source.promoteId = newPromoteId

        XCTAssertEqual(source.promoteId2, .byLayer(["layer": .constant("layer_prop")]))
    }

    func testVectorSourcePromoteIdEncoding() throws {
        let globalPromoteId = VectorSourcePromoteId.global(.constant("property_name"))
        let globalData = try JSONEncoder().encode(globalPromoteId)
        let globalString = String(data: globalData, encoding: .utf8)
        XCTAssertEqual(globalString, "\"property_name\"")

        let expressionValue = Exp(.get, "dynamic_property")
        let byLayerPromoteId = VectorSourcePromoteId.byLayer([
            "layer1": .constant("property1"),
            "layer2": .expression(expressionValue)
        ])
        let byLayerData = try JSONEncoder().encode(byLayerPromoteId)

        struct JSONDictionary: Decodable {
            let layer1: String
            let layer2: [String]
        }

        let decoded = try JSONDecoder().decode(JSONDictionary.self, from: byLayerData)

        XCTAssertEqual(decoded.layer1, "property1")
        XCTAssertEqual(decoded.layer2, ["get", "dynamic_property"])
    }

    func testVectorSourcePromoteIdDecoding() throws {
        let globalJson = "\"property_name\""
        let globalData = globalJson.data(using: .utf8)!
        let globalDecoded = try JSONDecoder().decode(VectorSourcePromoteId.self, from: globalData)

        XCTAssertEqual(globalDecoded, .global(.constant("property_name")))

        let byLayerJson = """
        {
            "layer1": "property1",
            "layer2": ["get", "dynamic_property"]
        }
        """
        let byLayerData = byLayerJson.data(using: .utf8)!
        let byLayerDecoded = try JSONDecoder().decode(VectorSourcePromoteId.self, from: byLayerData)

        let expectedExpression = Exp(.get, "dynamic_property")
        let expectedDecoded = VectorSourcePromoteId.byLayer([
            "layer1": .constant("property1"),
            "layer2": .expression(expectedExpression)
        ])
        XCTAssertEqual(byLayerDecoded, expectedDecoded)
    }

    @available(*, deprecated)
    func testPromoteIdInGeoJSONSource() {
        var source = GeoJSONSource(id: "test-source")
        let promoteId = PromoteId.string("foo")
        source.promoteId = promoteId

        XCTAssertEqual(source.promoteId, promoteId)
        XCTAssertEqual(source.promoteId2, .constant("foo"))

        source.promoteId2 = .constant("bar")
        XCTAssertEqual(source.promoteId, .string("bar"))

        // Ignore by-layer values as geojson source doesn't have data layers.
        source.promoteId = .object(["baz": "qux"])
        XCTAssertEqual(source.promoteId2, nil)
        XCTAssertEqual(source.promoteId, nil)
    }
}
