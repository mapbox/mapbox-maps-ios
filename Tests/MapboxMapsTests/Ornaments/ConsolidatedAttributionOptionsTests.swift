import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class ConsolidatedAttributionOptionsTests: XCTestCase {

    func testEquality() {
        let a = ConsolidatedAttributionOptions(position: .bottomLeft, margins: .zero, introExpansion: .everyLaunch)
        let b = ConsolidatedAttributionOptions(position: .bottomLeft, margins: .zero, introExpansion: .everyLaunch)
        let c = ConsolidatedAttributionOptions(position: .bottomRight, margins: .zero, introExpansion: .everyLaunch)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func testMaterialEquality() {
        let a = ConsolidatedAttributionOptions(material: .translucent)
        let b = ConsolidatedAttributionOptions(material: .translucent)
        let c = ConsolidatedAttributionOptions(material: .solid)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func testTintColorEquality() {
        let a = ConsolidatedAttributionOptions(tintColor: .systemBlue)
        let b = ConsolidatedAttributionOptions(tintColor: .systemBlue)
        let c = ConsolidatedAttributionOptions(tintColor: .systemRed)
        let none = ConsolidatedAttributionOptions()
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
        XCTAssertNotEqual(a, none)
    }

    func testOrnamentOptionsDefaultHasNoConsolidatedAttribution() {
        let options = OrnamentOptions()
        XCTAssertNil(options.consolidatedAttribution)
    }

    func testOrnamentOptionsWithConsolidatedAttribution() {
        let consolidated = ConsolidatedAttributionOptions(position: .topRight, introExpansion: .once)
        let options = OrnamentOptions(consolidatedAttribution: consolidated)
        XCTAssertEqual(options.consolidatedAttribution, consolidated)
    }
}
