import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class MapboxStyleTests: XCTestCase {

    // TODO: Reenable tests
//    func testSetURL() throws {
//        let mapView = MapView()
//        let style = StyleManager(with: mapView.map)
//
//        let streets = URL(string: "mapbox://styles/mapbox/streets-v11")!
//
//        XCTAssertEqual(style.styleURL.url, streets)
//
//        style.styleURL = .dark
//        let dark = URL(string: "mapbox://styles/mapbox/dark-v10")!
//        XCTAssertEqual(style.styleURL.url, dark)
//
//        let url = URL(string: "test.url")!
//        style.styleURL = .custom(url: url)
//        XCTAssertEqual(style.styleURL.url, url)
//
//    }

}
