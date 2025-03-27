import XCTest
@testable import MapboxMaps

class StylePackLoadOptionsTests: XCTestCase {

    func testInitilization() throws {
        let glyphsRasterizationMode = GlyphsRasterizationMode.ideographsRasterizedLocally
        let metadata: [Int] = [8, 3, 2, 5, 20]
        let acceptExpired = Bool.testConstantValue()
        let extraOptions: [Int] = [18, 33, 52, 65, 0]

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
