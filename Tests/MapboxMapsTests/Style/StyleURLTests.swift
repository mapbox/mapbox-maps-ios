import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

//swiftlint:disable explicit_top_level_acl explicit_acl
class StyleURLTests: XCTestCase {

    func testSettingStyleVersions() throws {
        var style: StyleURL = .streetsVersion(10)
        guard let streets = URL(string: "mapbox://styles/mapbox/streets-v10") else { return }
        var url: URL? = style.url

        XCTAssertNotNil(url)
        XCTAssertEqual(url!, streets)

        style = .outdoorsVersion(10)
        guard let outdoors = URL(string: "mapbox://styles/mapbox/outdoors-v10") else { return }
        url = style.url
        XCTAssertEqual(url, outdoors)

        style = .darkVersion(9)
        guard let dark = URL(string: "mapbox://styles/mapbox/dark-v9") else { return }
        url = style.url
        XCTAssertEqual(url, dark)

        style = .lightVersion(9)
        guard let light = URL(string: "mapbox://styles/mapbox/light-v9") else { return }
        url = style.url
        XCTAssertEqual(url, light)

        style = .satelliteVersion(8)
        guard let satellite = URL(string: "mapbox://styles/mapbox/satellite-v8") else { return }
        url = style.url
        XCTAssertEqual(url, satellite)

        style = .satelliteStreetsVersion(10)
        guard let satelliteStreets = URL(string: "mapbox://styles/mapbox/satellite-streets-v10") else { return }
        url = style.url
        XCTAssertEqual(url, satelliteStreets)
    }

    func testInvalidVersion() throws {
        var style: StyleURL = .streetsVersion(12)
        guard let streets = URL(string: "mapbox://styles/mapbox/streets-v11") else { return }
        var url: URL? = style.url

        XCTAssertNotNil(url)
        XCTAssertEqual(url!, streets)

        style = .outdoorsVersion(12)
        guard let outdoors = URL(string: "mapbox://styles/mapbox/outdoors-v11") else { return }
        url = style.url
        XCTAssertEqual(url, outdoors)

        style = .darkVersion(12)
        guard let dark = URL(string: "mapbox://styles/mapbox/dark-v10") else { return }
        url = style.url
        XCTAssertEqual(url, dark)

        style = .lightVersion(12)
        guard let light = URL(string: "mapbox://styles/mapbox/light-v10") else { return }
        url = style.url
        XCTAssertEqual(url, light)

        style = .satelliteVersion(12)
        guard let satellite = URL(string: "mapbox://styles/mapbox/satellite-v9") else { return }
        url = style.url
        XCTAssertEqual(url, satellite)

        style = .satelliteStreetsVersion(12)
        guard let satelliteStreets = URL(string: "mapbox://styles/mapbox/satellite-streets-v11") else { return }
        url = style.url
        XCTAssertEqual(url, satelliteStreets)

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
