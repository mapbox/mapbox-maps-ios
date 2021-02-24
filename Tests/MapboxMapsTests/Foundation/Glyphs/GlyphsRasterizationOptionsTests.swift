import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

// swiftlint:disable explicit_top_level_acl explicit_acl
class GlyphsRasterizationOptionsTests: XCTestCase {

    func testDefaults() {
        let options = GlyphsRasterizationOptions.default

        XCTAssert(options.rasterizationMode == .ideographsRasterizedLocally)
        XCTAssertEqual(options.fontFamily, GlyphsRasterizationOptions.fallbackFontFamilyName)
    }

    func testConvenienceInitializerWithEmptyFontFamily() {
        let options = GlyphsRasterizationOptions(rasterizationMode: .ideographsRasterizedLocally, fontFamilies: [])

        XCTAssert(options.rasterizationMode == .ideographsRasterizedLocally)
        XCTAssertEqual(options.fontFamily, GlyphsRasterizationOptions.fallbackFontFamilyName)
    }

    func testIdeographsRasterizedLocallyWithNilFontFamily() {
        let options = GlyphsRasterizationOptions(rasterizationMode: .ideographsRasterizedLocally, fontFamily: nil)

        XCTAssert(options.rasterizationMode == .ideographsRasterizedLocally)

        // Designated initializer will not provide a default font. At runtime, this will log an error.
        XCTAssertNil(options.fontFamily)
    }

    func testMultipleFonts() {
        let options = GlyphsRasterizationOptions(rasterizationMode: .ideographsRasterizedLocally, fontFamilies: ["test1", "test2", "test3"])
        XCTAssertEqual(options.fontFamily, "test1\ntest2\ntest3")
    }
}
