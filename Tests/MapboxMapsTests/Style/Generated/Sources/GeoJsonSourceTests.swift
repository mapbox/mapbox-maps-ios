// This file is generated.

import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
import Turf
#endif

class GeoJSONSourceTests: XCTestCase {
    
    func testEncodingAndDecoding() {
        var source = GeoJSONSource()
        source.data = GeoJSONSourceData.testSourceValue()
        source.maxzoom = Double.testSourceValue()
        source.attribution = String.testSourceValue()
        source.buffer = Double.testSourceValue()
        source.tolerance = Double.testSourceValue()
        source.cluster = Bool.testSourceValue()
        source.clusterRadius = Double.testSourceValue()
        source.clusterMaxZoom = Double.testSourceValue()
        source.lineMetrics = Bool.testSourceValue()
        source.generateId = Bool.testSourceValue()
        source.prefetchZoomDelta = Double.testSourceValue()

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
            XCTAssert(decodedSource.lineMetrics == Bool.testSourceValue())
            XCTAssert(decodedSource.generateId == Bool.testSourceValue())
            XCTAssert(decodedSource.prefetchZoomDelta == Double.testSourceValue())
        } catch {
            XCTFail("Failed to decode GeoJSONSource.")
        }
    }
}
// End of generated file