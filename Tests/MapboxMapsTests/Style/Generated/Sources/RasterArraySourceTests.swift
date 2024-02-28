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

    func testSetPropertyValueWithFunction() {
        let source = RasterArraySource(id: "test-source")
            .url(String.testSourceValue())
            .tiles([String].testSourceValue())
            .minzoom(Double.testSourceValue())
            .maxzoom(Double.testSourceValue())
            .tileCacheBudget(TileCacheBudgetSize.testSourceValue())

        XCTAssertEqual(source.url, String.testSourceValue())
        XCTAssertEqual(source.tiles, [String].testSourceValue())
        XCTAssertEqual(source.minzoom, Double.testSourceValue())
        XCTAssertEqual(source.maxzoom, Double.testSourceValue())
        XCTAssertEqual(source.tileCacheBudget, TileCacheBudgetSize.testSourceValue())
    }
}

// End of generated file
