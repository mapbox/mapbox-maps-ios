import XCTest
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsSnapshot
#endif

//swiftlint:disable explicit_top_level_acl explicit_acl
class MapboxMapsSnapshotTests: XCTestCase {
    func testLocalFontFamilyNameFromMainBundle() {
        let fontName = MapSnapshotOptions.localFontFamilyNameFromMainBundle()

        XCTAssertNotNil(fontName)
    }
}
