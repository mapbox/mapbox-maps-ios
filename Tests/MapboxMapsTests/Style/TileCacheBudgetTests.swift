import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class TileCacheBudgetTests: XCTestCase {

    func testCoreTileCacheBudgetTiles() {
        let testBudgetSize = 13
        let tileCacheBudget: TileCacheBudgetSize = .tiles(testBudgetSize)
        XCTAssertEqual(tileCacheBudget.coreTileCacheBudget.type, .tileCacheBudgetInTiles)
        XCTAssertEqual(tileCacheBudget.coreTileCacheBudget.isTileCacheBudgetInTiles(), true)
        XCTAssertEqual(tileCacheBudget.coreTileCacheBudget.isTileCacheBudgetInMegabytes(), false)
        XCTAssertEqual(tileCacheBudget.coreTileCacheBudget.getInTiles().size, UInt64(testBudgetSize))
    }

    func testCoreTileCacheBudgetMegabytes() {
        let testBudgetSize = 5
        let tileCacheBudget: TileCacheBudgetSize = .megabytes(testBudgetSize)
        XCTAssertEqual(tileCacheBudget.coreTileCacheBudget.type, .tileCacheBudgetInMegabytes)
        XCTAssertEqual(tileCacheBudget.coreTileCacheBudget.isTileCacheBudgetInTiles(), false)
        XCTAssertEqual(tileCacheBudget.coreTileCacheBudget.isTileCacheBudgetInMegabytes(), true)
        XCTAssertEqual(tileCacheBudget.coreTileCacheBudget.getInMegabytes().size, UInt64(testBudgetSize))
    }

    func testConversionError() {
        let invalidJson = Data("""
            {
                "tiles": 42,
                "megabytes": 74
            }
        """.utf8)

        do {
            _ = try JSONDecoder().decode(TileCacheBudgetSize.self, from: invalidJson)
            XCTFail("Expected type conversion error.")
        } catch {
            XCTAssertNotNil(error)
            XCTAssertTrue(error is TypeConversionError)
        }
    }
}
