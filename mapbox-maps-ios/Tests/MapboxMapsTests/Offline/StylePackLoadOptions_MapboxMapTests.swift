import XCTest
@testable import MapboxMaps

class StylePackLoadOptionsTests: XCTestCase {

    func testInitilization() throws {
        let allGlyphsRasterizationMode: [GlyphsRasterizationMode] = [
            .noGlyphsRasterizedLocally,
            .ideographsRasterizedLocally,
            .allGlyphsRasterizedLocally
        ]

        let glyphsRasterizationMode = GlyphsRasterizationMode?.random(allGlyphsRasterizationMode.randomElement()!)
        let metadata: [Int]? = .random(Array.random(withLength: 5, generator: { Int.random(in: 0...9) }))
        let acceptExpired = Bool.random()
        let extraOptions: [Int]? = .random(Array.random(withLength: 5, generator: { Int.random(in: 0...9) }))

        let stylePackLoadOptions = try XCTUnwrap(StylePackLoadOptions(
            glyphsRasterizationMode: glyphsRasterizationMode,
            metadata: metadata,
            acceptExpired: acceptExpired,
            extraOptions: extraOptions))

        XCTAssertEqual(stylePackLoadOptions.glyphsRasterizationMode, glyphsRasterizationMode)
        XCTAssertEqual(stylePackLoadOptions.metadata as? [Int], metadata)
        XCTAssertEqual(stylePackLoadOptions.acceptExpired, acceptExpired)
        XCTAssertEqual(stylePackLoadOptions.extraOptions as? [Int], extraOptions)
    }

    func testInitializationWithInvalidMetadata() {
        let stylePackLoadOptions = StylePackLoadOptions(glyphsRasterizationMode: nil, metadata: "not a valid JSON")
        XCTAssertNil(stylePackLoadOptions)
    }

    func testInitializationWithInvalidExtraOptions() throws {
        let stylePackLoadOptions = try XCTUnwrap(StylePackLoadOptions(
            glyphsRasterizationMode: nil,
            extraOptions: "not a valid JSON"))
        XCTAssertNil(stylePackLoadOptions.extraOptions)
    }
}
