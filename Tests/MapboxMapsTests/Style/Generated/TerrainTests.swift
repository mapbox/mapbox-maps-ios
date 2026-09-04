// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class TerrainTests: XCTestCase {

    func testTerrainProperties() {
        var instance = Terrain(sourceId: "test-terrain-source")
        instance.exaggeration = .testConstantValue()
        instance.exaggerationTransition = .testConstantValue()

        XCTAssertEqual(instance.source, "test-terrain-source")
        XCTAssertEqual(instance.exaggeration, .testConstantValue())
        XCTAssertEqual(instance.exaggerationTransition, .testConstantValue())
    }

    func testTerrainSetters() {
        let instance = Terrain(sourceId: "test-terrain-source")
            .exaggeration(Double.testConstantValue())
            .exaggerationTransition(.testConstantValue())

        XCTAssertEqual(instance.source, "test-terrain-source")
        XCTAssertEqual(instance.exaggeration, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(instance.exaggerationTransition, .testConstantValue())
    }

    func testTerrainPropertySerialization() throws {
        var instance = Terrain(sourceId: "test-terrain-source")
        instance.exaggeration = .testConstantValue()
        instance.exaggerationTransition = .testConstantValue()

        let data = try JSONEncoder().encode(instance)
        let decodedInstance = try JSONDecoder().decode(Terrain.self, from: data)

        XCTAssertEqual(decodedInstance.source, "test-terrain-source")
        XCTAssertEqual(decodedInstance.exaggeration, .testConstantValue())
        XCTAssertEqual(decodedInstance.exaggerationTransition, .testConstantValue())
    }

    func testTerrainSettersSerialization() throws {
        let instance = Terrain(sourceId: "test-terrain-source")
            .exaggeration(Double.testConstantValue())
            .exaggerationTransition(.testConstantValue())

        let data = try JSONEncoder().encode(instance)
        let decodedInstance = try JSONDecoder().decode(Terrain.self, from: data)

        XCTAssertEqual(decodedInstance.source, "test-terrain-source")
        XCTAssertEqual(decodedInstance.exaggeration, Value.constant(Double.testConstantValue()))
        XCTAssertEqual(decodedInstance.exaggerationTransition, .testConstantValue())
    }
}

// End of generated file
