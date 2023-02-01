import XCTest
@testable import MapboxMapsSwiftUI

@available(iOS 13.0, *)
final class SwiftStyleTests: XCTestCase {
    var applier = MockStyleApplier()

    func testAddition() throws {
        let oldTree = StyleTree(layers: [], sources: [:])
        let newTree = StyleTree(layers: [
            SymbolLayer(id: "symb-1"),
            SymbolLayer(id: "symb-2")
        ], sources: [
            "json": GeoJSONSource(),
            "dem": RasterDemSource()
        ])

        try applyStyle(oldTree, newTree: newTree, style: applier)
        XCTAssertEqual(applier.layerAdditions, ["symb-1", "symb-2"])
        XCTAssertEqual(applier.sourcesAdditions, ["json", "dem"])
    }

    func testReplace() throws {
        let oldTree = StyleTree(layers: [
            SymbolLayer(id: "symb-1"),
        ], sources: [
            "json-1": GeoJSONSource()
        ])
        let newTree = StyleTree(layers: [
            SymbolLayer(id: "symb-2")
        ], sources: [
            "json-2": GeoJSONSource()
        ])

        try applyStyle(oldTree, newTree: newTree, style: applier)
        XCTAssertEqual(applier.layerAdditions, ["symb-2"])
        XCTAssertEqual(applier.layerRemovals, ["symb-1"])
        XCTAssertEqual(applier.sourcesAdditions, ["json-2"])
        XCTAssertEqual(applier.sourcesRemovals, ["json-1"])
    }

    func testSame() throws {
        let oldTree = StyleTree(layers: [
            SymbolLayer(id: "symb-1"),
        ], sources: [
            "json-1": GeoJSONSource()
        ])
        let newTree = StyleTree(layers: [
            SymbolLayer(id: "symb-1")
        ], sources: [
            "json-1": GeoJSONSource()
        ])

        try applyStyle(oldTree, newTree: newTree, style: applier)
        XCTAssert(applier.layerAdditions.isEmpty)
        XCTAssert(applier.layerRemovals.isEmpty)
        XCTAssert(applier.sourcesAdditions.isEmpty)
    }
}

class MockStyleApplier: StyleApplier {
    var layerAdditions = Set<String>()
    var layerRemovals = Set<String>()
    
    var sourcesAdditions = Set<String>()
    var sourcesRemovals = Set<String>()

    func addLayer(_ layer: Layer) throws {
        layerAdditions.insert(layer.id)
    }

    func removeLayer(withId id: String) throws {
        layerRemovals.insert(id)
    }

    func addSource(_ source: Source, id: String) throws {
        sourcesAdditions.insert(id)
    }

    func removeSource(withId id: String) throws {
        sourcesRemovals.insert(id)
    }
}
