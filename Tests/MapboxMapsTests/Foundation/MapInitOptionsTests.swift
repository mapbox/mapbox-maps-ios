import XCTest
@testable @_spi(Restricted) import MapboxMaps

class MapInitOptionsTests: XCTestCase {

    func testDefaultStyleURIAndCamera() {
        let mapInitOptions = MapInitOptions()
        XCTAssert(mapInitOptions.styleURI == .standard)
        XCTAssertNil(mapInitOptions.cameraOptions)
    }

    func testEquality() {
        let a = MapInitOptions()
        let b = MapInitOptions()
        XCTAssertEqual(a, b)

        let c = MapInitOptions(mapOptions: MapOptions(constrainMode: .widthAndHeight))
        XCTAssertNotEqual(a, c)
    }

    func testDefaultUIFrameworkIsUIKit() {
        XCTAssertEqual(MapInitOptions().uiFramework, UIFramework.uiKit)
    }

    func testResolvedPreservesUIFramework() {
        let options = MapInitOptions(mapStyle: nil, uiFramework: .swiftUI)

        let resolved = options.resolved(in: CGRect(x: 0, y: 0, width: 100, height: 100), overridingStyleURI: nil)

        XCTAssertEqual(resolved.uiFramework, UIFramework.swiftUI)
    }

    func testHashable() {
        var set = Set<MapInitOptions>()

        let a = MapInitOptions()
        set.insert(a)

        let b = MapInitOptions()
        set.insert(b)

        XCTAssert(set.count == 1)
    }

    func testStyleURI() {
        var me = MapInitOptions(styleURI: .standardSatellite)
        XCTAssertEqual(me.styleURI, .standardSatellite)
        XCTAssertEqual(me.mapStyle, MapStyle.standardSatellite)

        me = MapInitOptions(mapStyle: .streets)
        XCTAssertEqual(me.styleURI, .streets)
        XCTAssertEqual(me.mapStyle, MapStyle.streets)
    }

    func testStyleJSON() {
        let json = "{}"
        var me = MapInitOptions(styleJSON: json)
        XCTAssertEqual(me.styleURI, nil)
        XCTAssertEqual(me.styleJSON, json)
        XCTAssertEqual(me.mapStyle, MapStyle(json: json))

        me = MapInitOptions(mapStyle: MapStyle(json: json))
        XCTAssertEqual(me.styleURI, nil)
        XCTAssertEqual(me.styleJSON, json)
        XCTAssertEqual(me.mapStyle, MapStyle(json: json))
    }
}
