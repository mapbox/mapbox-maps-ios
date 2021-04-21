import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

//swiftlint:disable explicit_top_level_acl explicit_acl
class StyleURITests: XCTestCase {

    // MARK: - Tests

    func testCustomVersions() throws {
        checkCustomStyleURI(with: "mapbox://styles/mapbox/streets-v10")
        checkCustomStyleURI(with: "mapbox://styles/mapbox/outdoors-v10")
        checkCustomStyleURI(with: "mapbox://styles/mapbox/light-v9")
        checkCustomStyleURI(with: "mapbox://styles/mapbox/dark-v9")
        checkCustomStyleURI(with: "mapbox://styles/mapbox/satellite-v8")
        checkCustomStyleURI(with: "mapbox://styles/mapbox/satellite-streets-v10")
    }

    func testDefaultStyleURIs() throws {
        checkDefaultStyleURI(with: "mapbox://styles/mapbox/streets-v11", expected: .streets)
        checkDefaultStyleURI(with: "mapbox://styles/mapbox/outdoors-v11", expected: .outdoors)
        checkDefaultStyleURI(with: "mapbox://styles/mapbox/light-v10", expected: .light)
        checkDefaultStyleURI(with: "mapbox://styles/mapbox/dark-v10", expected: .dark)
        checkDefaultStyleURI(with: "mapbox://styles/mapbox/satellite-v9", expected: .satellite)
        checkDefaultStyleURI(with: "mapbox://styles/mapbox/satellite-streets-v11", expected: .satelliteStreets)
    }

    func testInvalidStyleURIs() throws {
        checkInvalidStyleURI(with: "https:// typo/in/url")
        checkInvalidStyleURI(with: "mapbox:\\styles/mapbox/streets-v11")
        checkInvalidStyleURI(with: "//styles/mapbox/streets-v11")
        checkInvalidStyleURI(with: "mapbox/styles/mapbox/streets-v11")
    }

    // MARK: - Helpers

    private func checkCustomStyleURI(with string: String, line: UInt = #line) {
        guard let styleURI = StyleURI(rawValue: string) else {
            XCTFail("Could not convert to StyleURI.", line: line)
            return
        }

        XCTAssertEqual(styleURI.rawValue, string, line: line)
    }

    private func checkDefaultStyleURI(with string: String, expected: StyleURI, line: UInt = #line) {
        guard let styleURI = StyleURI(rawValue: string) else {
            XCTFail("Could not convert to StyleURI", line: line)
            return
        }

        XCTAssertEqual(styleURI, expected, line: line)
    }

    private func checkInvalidStyleURI(with string: String, line: UInt = #line) {
        guard nil != StyleURI(rawValue: string) else {
            print("Invalid styleURI from URL: \(line)")
            return
        }

        XCTFail("Should not convert to a StyleURI", line: line)
    }
}
