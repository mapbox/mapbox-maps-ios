// This file is generated.
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class RasterDemSourceTests: XCTestCase {

    func testEncodingAndDecoding() {
        var source = RasterDemSource(id: "test-source")
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
        source.tileCacheBudget = TileCacheBudgetSize.testSourceValue()
        source.minimumTileUpdateInterval = Double.testSourceValue()
        source.maxOverscaleFactorForParentTiles = Double.testSourceValue()
        source.tileRequestsDelay = Double.testSourceValue()
        source.tileNetworkRequestsDelay = Double.testSourceValue()

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
            XCTAssert(decodedSource.tileCacheBudget == TileCacheBudgetSize.testSourceValue())
            XCTAssert(decodedSource.minimumTileUpdateInterval == Double.testSourceValue())
            XCTAssert(decodedSource.maxOverscaleFactorForParentTiles == Double.testSourceValue())
            XCTAssert(decodedSource.tileRequestsDelay == Double.testSourceValue())
            XCTAssert(decodedSource.tileNetworkRequestsDelay == Double.testSourceValue())
        } catch {
            XCTFail("Failed to decode RasterDemSource.")
        }
    }

    func testSetPropertyValueWithFunction() {
        let source = RasterDemSource(id: "test-source")
            .url(String.testSourceValue())
            .tiles([String].testSourceValue())
            .minzoom(Double.testSourceValue())
            .maxzoom(Double.testSourceValue())
            .volatile(Bool.testSourceValue())
            .prefetchZoomDelta(Double.testSourceValue())
            .tileCacheBudget(TileCacheBudgetSize.testSourceValue())
            .minimumTileUpdateInterval(Double.testSourceValue())
            .maxOverscaleFactorForParentTiles(Double.testSourceValue())
            .tileRequestsDelay(Double.testSourceValue())
            .tileNetworkRequestsDelay(Double.testSourceValue())

        XCTAssertEqual(source.url, String.testSourceValue())
        XCTAssertEqual(source.tiles, [String].testSourceValue())
        XCTAssertEqual(source.minzoom, Double.testSourceValue())
        XCTAssertEqual(source.maxzoom, Double.testSourceValue())
        XCTAssertEqual(source.volatile, Bool.testSourceValue())
        XCTAssertEqual(source.prefetchZoomDelta, Double.testSourceValue())
        XCTAssertEqual(source.tileCacheBudget, TileCacheBudgetSize.testSourceValue())
        XCTAssertEqual(source.minimumTileUpdateInterval, Double.testSourceValue())
        XCTAssertEqual(source.maxOverscaleFactorForParentTiles, Double.testSourceValue())
        XCTAssertEqual(source.tileRequestsDelay, Double.testSourceValue())
        XCTAssertEqual(source.tileNetworkRequestsDelay, Double.testSourceValue())
    }
}

// End of generated file
