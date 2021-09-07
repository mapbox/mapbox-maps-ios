// This file is generated.
import XCTest
@testable import MapboxMaps

final class RasterDemSourceTests: XCTestCase {

    func testEncodingAndDecoding() {
        var source = RasterDemSource()
        source.url = String.testSourceValue()
        source.tiles = [String].testSourceValue()
        source.bounds = [Double].testSourceValue()
        source.minzoom = Double.testSourceValue()
        source.maxzoom = Double.testSourceValue()
        source.tileSize = Double.testSourceValue()
        source.attribution = String.testSourceValue()
        source.encoding = Encoding.testSourceValue()
        source.volatile = Bool.testSourceValue()
        source.prefetchZoomDelta = Double.testSourceValue()
        source.minimumTileUpdateInterval = Double.testSourceValue()
        source.maxOverscaleFactorForParentTiles = Double.testSourceValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(source)
        } catch {
            XCTFail("Failed to encode RasterDemSource.")
        }

        guard let validData = data else {
            XCTFail("Failed to encode RasterDemSource.")
            return
        }

        do {
            let decodedSource = try JSONDecoder().decode(RasterDemSource.self, from: validData)
            XCTAssert(decodedSource.type == SourceType.rasterDem)
            XCTAssert(decodedSource.url == String.testSourceValue())
            XCTAssert(decodedSource.tiles == [String].testSourceValue())
            XCTAssert(decodedSource.bounds == [Double].testSourceValue())
            XCTAssert(decodedSource.minzoom == Double.testSourceValue())
            XCTAssert(decodedSource.maxzoom == Double.testSourceValue())
            XCTAssert(decodedSource.tileSize == Double.testSourceValue())
            XCTAssert(decodedSource.attribution == String.testSourceValue())
            XCTAssert(decodedSource.encoding == Encoding.testSourceValue())
            XCTAssert(decodedSource.volatile == Bool.testSourceValue())
            XCTAssert(decodedSource.prefetchZoomDelta == Double.testSourceValue())
            XCTAssert(decodedSource.minimumTileUpdateInterval == Double.testSourceValue())
            XCTAssert(decodedSource.maxOverscaleFactorForParentTiles == Double.testSourceValue())
        } catch {
            XCTFail("Failed to decode RasterDemSource.")
        }
    }
}

// End of generated file
