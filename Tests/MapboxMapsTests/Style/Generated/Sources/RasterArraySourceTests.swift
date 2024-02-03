// This file is generated.
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class RasterArraySourceTests: XCTestCase {

    func testEncodingAndDecoding() {
        var source = RasterArraySource(id: "test-source")
        source.url = String.testSourceValue()
        source.tiles = [String].testSourceValue()
        source.minzoom = Double.testSourceValue()
        source.maxzoom = Double.testSourceValue()
        source.tileCacheBudget = TileCacheBudgetSize.testSourceValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(source)
        } catch {
            XCTFail("Failed to encode RasterArraySource.")
        }

        guard let validData = data else {
            XCTFail("Failed to encode RasterArraySource.")
            return
        }

        do {
            let decodedSource = try JSONDecoder().decode(RasterArraySource.self, from: validData)
            XCTAssert(decodedSource.type == SourceType.rasterArray)
            XCTAssert(decodedSource.url == String.testSourceValue())
            XCTAssert(decodedSource.tiles == [String].testSourceValue())
            XCTAssert(decodedSource.minzoom == Double.testSourceValue())
            XCTAssert(decodedSource.maxzoom == Double.testSourceValue())
            XCTAssert(decodedSource.tileCacheBudget == TileCacheBudgetSize.testSourceValue())
        } catch {
            XCTFail("Failed to decode RasterArraySource.")
        }
    }
}

// End of generated file
