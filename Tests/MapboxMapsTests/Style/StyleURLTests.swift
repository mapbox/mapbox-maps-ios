import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

//swiftlint:disable explicit_top_level_acl explicit_acl
class StyleURLTests: XCTestCase {

    // MARK:- Tests

    func testCustomVersions() throws {
        checkCustomStyleURL(with: "mapbox://styles/mapbox/streets-v10")
        checkCustomStyleURL(with: "mapbox://styles/mapbox/outdoors-v10")
        checkCustomStyleURL(with: "mapbox://styles/mapbox/light-v9")
        checkCustomStyleURL(with: "mapbox://styles/mapbox/dark-v9")
        checkCustomStyleURL(with: "mapbox://styles/mapbox/satellite-v8")
        checkCustomStyleURL(with: "mapbox://styles/mapbox/satellite-streets-v10")
    }

    func testDefaultStyleURLs() throws {
        checkDefaultStyleURL(with: "mapbox://styles/mapbox/streets-v11", expected: .streets)
        checkDefaultStyleURL(with: "mapbox://styles/mapbox/outdoors-v11", expected: .outdoors)
        checkDefaultStyleURL(with: "mapbox://styles/mapbox/light-v10", expected: .light)
        checkDefaultStyleURL(with: "mapbox://styles/mapbox/dark-v10", expected: .dark)
        checkDefaultStyleURL(with: "mapbox://styles/mapbox/satellite-v9", expected: .satellite)
        checkDefaultStyleURL(with: "mapbox://styles/mapbox/satellite-streets-v11", expected: .satelliteStreets)
    }

    func testInvalidStyleURLs() throws {
        checkInvalidStyleURL(with: "https:// typo/in/url")
        checkInvalidStyleURL(with: "mapbox:\\styles/mapbox/streets-v11")
        checkInvalidStyleURL(with: "//styles/mapbox/streets-v11")
        checkInvalidStyleURL(with: "mapbox/styles/mapbox/streets-v11")
    }

    // MARK:- Helpers

    private func checkCustomStyleURL(with URLString: String, line: UInt = #line) {
        guard let sourceURL = URL(string: URLString) else {
            XCTFail("Invalid URL for: \(URLString).", line: line)
            return
        }

        guard let styleURL = StyleURL(rawValue: sourceURL) else {
            XCTFail("Could not convert to StyleURL.", line: line)
            return
        }

        guard case let .custom(destURL) = styleURL else {
            XCTFail("Not a custom URL.", line: line)
            return
        }

        XCTAssertEqual(destURL, sourceURL, line: line)
        XCTAssertEqual(destURL, styleURL.url, line: line)
    }

    private func checkDefaultStyleURL(with URLString: String, expected: StyleURL, line: UInt = #line) {
        guard let sourceURL = URL(string: URLString) else {
            XCTFail("Invalid URL for: \(URLString)", line: line)
            return
        }

        guard let styleURL = StyleURL(rawValue: sourceURL) else {
            XCTFail("Could not convert to StyleURL", line: line)
            return
        }

        XCTAssertEqual(styleURL, expected, line: line)
    }

    private func checkInvalidStyleURL(with URLString: String, line: UInt = #line) {
        guard let sourceURL = URL(string: URLString) else {
            print("Invalid URL from string: \(line)")
            return
        }

        guard let _ = StyleURL(rawValue: sourceURL) else {
            print("Invalid styleURL from URL: \(line)")
            return
        }

        XCTFail("Should not convert to a StyleURL", line: line)
    }
}
