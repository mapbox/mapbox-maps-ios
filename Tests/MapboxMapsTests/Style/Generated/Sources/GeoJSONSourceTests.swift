// This file is generated.
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class GeoJSONSourceTests: XCTestCase {

    func testEncodingAndDecoding() {
        var source = GeoJSONSource(id: "test-source")
        source.data = GeoJSONSourceData.testSourceValue()
        source.maxzoom = Double.testSourceValue()
        source.attribution = String.testSourceValue()
        source.buffer = Double.testSourceValue()
        source.tolerance = Double.testSourceValue()
        source.cluster = Bool.testSourceValue()
        source.clusterRadius = Double.testSourceValue()
        source.clusterMaxZoom = Double.testSourceValue()
        source.clusterMinPoints = Double.testSourceValue()
        source.clusterProperties = [String: Exp].testSourceValue()
        source.lineMetrics = Bool.testSourceValue()
        source.generateId = Bool.testSourceValue()
        source.promoteId = PromoteId.testSourceValue()
        source.prefetchZoomDelta = Double.testSourceValue()
        source.tileCacheBudget = TileCacheBudgetSize.testSourceValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(source)
        } catch {
            XCTFail("Failed to encode GeoJSONSource.")
        }

        guard let validData = data else {
            XCTFail("Failed to encode GeoJSONSource.")
            return
        }

        do {
            let decodedSource = try JSONDecoder().decode(GeoJSONSource.self, from: validData)
            XCTAssert(decodedSource.type == SourceType.geoJson)
            XCTAssert(decodedSource.data == GeoJSONSourceData.testSourceValue())
            XCTAssert(decodedSource.maxzoom == Double.testSourceValue())
            XCTAssert(decodedSource.attribution == String.testSourceValue())
            XCTAssert(decodedSource.buffer == Double.testSourceValue())
            XCTAssert(decodedSource.tolerance == Double.testSourceValue())
            XCTAssert(decodedSource.cluster == Bool.testSourceValue())
            XCTAssert(decodedSource.clusterRadius == Double.testSourceValue())
            XCTAssert(decodedSource.clusterMaxZoom == Double.testSourceValue())
            XCTAssert(decodedSource.clusterMinPoints == Double.testSourceValue())
            XCTAssert(decodedSource.clusterProperties == [String: Exp].testSourceValue())
            XCTAssert(decodedSource.lineMetrics == Bool.testSourceValue())
            XCTAssert(decodedSource.generateId == Bool.testSourceValue())
            XCTAssert(decodedSource.promoteId == PromoteId.testSourceValue())
            XCTAssert(decodedSource.prefetchZoomDelta == Double.testSourceValue())
            XCTAssert(decodedSource.tileCacheBudget == TileCacheBudgetSize.testSourceValue())
        } catch {
            XCTFail("Failed to decode GeoJSONSource.")
        }
    }

    func testSetPropertyValueWithFunction() {
        let source = GeoJSONSource(id: "test-source")
            .data(GeoJSONSourceData.testSourceValue())
            .prefetchZoomDelta(Double.testSourceValue())
            .tileCacheBudget(TileCacheBudgetSize.testSourceValue())

        XCTAssertEqual(source.data, GeoJSONSourceData.testSourceValue())
        XCTAssertEqual(source.prefetchZoomDelta, Double.testSourceValue())
        XCTAssertEqual(source.tileCacheBudget, TileCacheBudgetSize.testSourceValue())
    }
}

// End of generated file
