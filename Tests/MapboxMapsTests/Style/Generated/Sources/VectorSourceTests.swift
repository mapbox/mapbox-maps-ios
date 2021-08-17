// This file is generated.

import XCTest
@testable import MapboxMaps
import Turf


class VectorSourceTests: XCTestCase {

    func testEncodingAndDecoding() {
        var source = VectorSource()
        source.url = String.testSourceValue()
        source.tiles = [String].testSourceValue()
        source.bounds = [Double].testSourceValue()
        source.scheme = Scheme.testSourceValue()
        source.minzoom = Double.testSourceValue()
        source.maxzoom = Double.testSourceValue()
        source.attribution = String.testSourceValue()
        source.volatile = Bool.testSourceValue()
        source.prefetchZoomDelta = Double.testSourceValue()
        source.minimumTileUpdateInterval = Double.testSourceValue()
        source.maxOverscaleFactorForParentTiles = Double.testSourceValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(source)
        } catch {
            XCTFail("Failed to encode VectorSource.")
        }

        guard let validData = data else {
            XCTFail("Failed to encode VectorSource.")
            return
        }

        do {
            let decodedSource = try JSONDecoder().decode(VectorSource.self, from: validData)
            XCTAssert(decodedSource.type == SourceType.vector)
            XCTAssert(decodedSource.url == String.testSourceValue())
            XCTAssert(decodedSource.tiles == [String].testSourceValue())
            XCTAssert(decodedSource.bounds == [Double].testSourceValue())
            XCTAssert(decodedSource.scheme == Scheme.testSourceValue())
            XCTAssert(decodedSource.minzoom == Double.testSourceValue())
            XCTAssert(decodedSource.maxzoom == Double.testSourceValue())
            XCTAssert(decodedSource.attribution == String.testSourceValue())
            XCTAssert(decodedSource.volatile == Bool.testSourceValue())
            XCTAssert(decodedSource.prefetchZoomDelta == Double.testSourceValue())
            XCTAssert(decodedSource.minimumTileUpdateInterval == Double.testSourceValue())
            XCTAssert(decodedSource.maxOverscaleFactorForParentTiles == Double.testSourceValue())
        } catch {
            XCTFail("Failed to decode VectorSource.")
        }
    }
}
// End of generated file
