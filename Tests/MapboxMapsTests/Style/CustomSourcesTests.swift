import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class CustomSourcesSourceTests: XCTestCase {

    func testRasterEncodingAndDecoding() {
        let testCustomRasterSourceOptions = CustomRasterSourceOptions(fetchTileFunction: { _ in }, cancelTileFunction: { _ in })

        var source = CustomRasterSource(id: "test-source", options: testCustomRasterSourceOptions)
        source.tileCacheBudget = TileCacheBudgetSize.testSourceValue(TileCacheBudgetSize.megabytes(7))

        var data: Data?
        do {
            data = try JSONEncoder().encode(source)
        } catch {
            XCTFail("Failed to encode CustomRasterSource.")
        }

        guard let validData = data else {
            XCTFail("Failed to encode CustomRasterSource.")
            return
        }

        do {
            let decodedSource = try JSONDecoder().decode(CustomRasterSource.self, from: validData)
            XCTAssert(decodedSource.type == SourceType.customRaster)
            XCTAssert(decodedSource.id == "test-source")
            XCTAssert(decodedSource.tileCacheBudget == TileCacheBudgetSize.testSourceValue(TileCacheBudgetSize.megabytes(7)))
            XCTAssertNil(decodedSource.options)
        } catch {
            XCTFail("Failed to decode CustomRasterSource.")
        }
    }

    func testGeometryEncodingAndDecoding() {
        let testCustomGeometrySourceOptions = CustomGeometrySourceOptions(fetchTileFunction: { _ in }, cancelTileFunction: { _ in }, tileOptions: TileOptions())

        var source = CustomGeometrySource(id: "test-source", options: testCustomGeometrySourceOptions)
        source.tileCacheBudget = TileCacheBudgetSize.testSourceValue()

        var data: Data?
        do {
            data = try JSONEncoder().encode(source)
        } catch {
            XCTFail("Failed to encode CustomRasterSource.")
        }

        guard let validData = data else {
            XCTFail("Failed to encode CustomRasterSource.")
            return
        }

        do {
            let decodedSource = try JSONDecoder().decode(CustomGeometrySource.self, from: validData)
            XCTAssert(decodedSource.type == SourceType.customGeometry)
            XCTAssert(decodedSource.id == "test-source")
            XCTAssert(decodedSource.tileCacheBudget == TileCacheBudgetSize.testSourceValue())
            XCTAssertNil(decodedSource.options)
        } catch {
            XCTFail("Failed to decode CustomRasterSource.")
        }
    }
}
