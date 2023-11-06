import XCTest
@testable import MapboxMaps
import Foundation
import UIKit

class AttributionTests: XCTestCase {

    func testActionableAttributionParsing() {
        let attributionsHTML = """
  <a href=\"https://www.mapbox.com/about/maps/\" target=\"_blank\" title=\"Mapbox\" aria-label=\"Mapbox\" role=\"listitem\">&copy; Mapbox</a>
<a href=\"https://www.openstreetmap.org/about/\" target=\"_blank\" title=\"OpenStreetMap\" aria-label=\"OpenStreetMap\" role=\"listitem\">&copy; OpenStreetMap</a>
"""
        let parseExpectation = expectation(description: "Attributions are parsed")

        Attribution.parse([attributionsHTML]) { attributions in
            guard attributions.count == 2 else {
                XCTFail("Parsing should return 2 attributions")
                return
            }

            let attribution0 = attributions[0]
            XCTAssertEqual(attribution0.title, "Mapbox")
            XCTAssertEqual(attribution0.kind, .actionable(URL(string: "https://www.mapbox.com/about/maps/")!))

            let attribution1 = attributions[1]
            XCTAssertEqual(attribution1.title, "OpenStreetMap")
            XCTAssertEqual(attribution1.kind, .actionable(URL(string: "https://www.openstreetmap.org/about/")!))

            parseExpectation.fulfill()
        }

        wait(for: [parseExpectation], timeout: 5)
    }

    func testFeedbackAttributionParsing() throws {
        let attributionsHTML = """
<a class=\"mapbox-improve-map\" href=\"https://www.mapbox.com/\" target=\"_blank\" title=\"Improve this map\" aria-label=\"Improve this map\" role=\"listitem\">Improve this map</a>
<a class=\"mapbox-improve-map\" href=\"https://www.mapbox.com/feedback/\" target=\"_blank\" title=\"Attribution 1\" aria-label=\"Attribution 3\" role=\"listitem\">Attribution 1</a>
<a class=\"mapbox-improve-map\" href=\"https://www.mapbox.com/map-feedback/\" target=\"_blank\" title=\"Attribution 2\" aria-label=\"Attribution 2\" role=\"listitem\">Attribution 2</a>
<a class=\"mapbox-improve-map\" href=\"https://apps.mapbox.com/feedback/\" target=\"_blank\" title=\"Attribution 3\" aria-label=\"Attribution 3\" role=\"listitem\">Attribution 3</a>
"""
        let parseExpectation = expectation(description: "Attributions are parsed")

        Attribution.parse([attributionsHTML]) { attributions in

            guard attributions.count == 4 else {
                XCTFail("Parsing should return 4 attributions")
                return
            }

            let attribution0 = attributions[0]
            XCTAssertEqual(attribution0.title, "Improve this map")
            XCTAssertEqual(attribution0.kind, .feedback)

            let attribution1 = attributions[1]
            XCTAssertEqual(attribution1.title, "Attribution 1")
            XCTAssertEqual(attribution1.kind, .feedback)

            let attribution2 = attributions[2]
            XCTAssertEqual(attribution2.title, "Attribution 2")
            XCTAssertEqual(attribution2.kind, .feedback)

            let attribution3 = attributions[3]
            XCTAssertEqual(attribution3.title, "Attribution 3")
            XCTAssertEqual(attribution3.kind, .feedback)

            parseExpectation.fulfill()
        }

        wait(for: [parseExpectation], timeout: 5)
    }

    func testPlainTextAttributionParsing() throws {
        let attributionString = String.randomAlphanumeric(withLength: 10).trimmingCharacters(in: .whitespacesAndNewlines)
        let parseExpectation = expectation(description: "Attributions are parsed")

        Attribution.parse([attributionString]) { attributions in

            do {
                let attribution = try XCTUnwrap(attributions.first)
                XCTAssertEqual(attribution.title, attributionString)
                XCTAssertEqual(attribution.kind, .nonActionable)
            } catch {
                XCTFail("Parsing should result in an attribution")
            }
            parseExpectation.fulfill()
        }

        wait(for: [parseExpectation], timeout: 5)
    }

    func testDuplicateAttributionParsing() {
        let attributionsHTML = """
  <a href=\"https://www.mapbox.com/about/maps/\" target=\"_blank\" title=\"Mapbox\" aria-label=\"Mapbox\" role=\"listitem\">&copy; Mapbox</a>
  <a href=\"https://www.mapbox.com/about/maps/\" target=\"_blank\" title=\"Mapbox\" aria-label=\"Mapbox\" role=\"listitem\">&copy; Mapbox</a>
"""
        let parseExpectation = expectation(description: "Attributions are parsed")

        Attribution.parse([attributionsHTML]) { attributions in

            guard attributions.count == 1 else {
                XCTFail("Parsing should return 1 attribution")
                return
            }

            let attribution0 = attributions[0]
            XCTAssertEqual(attribution0.title, "Mapbox")
            XCTAssertEqual(attribution0.kind, .actionable(URL(string: "https://www.mapbox.com/about/maps/")!))

            parseExpectation.fulfill()
        }

        wait(for: [parseExpectation], timeout: 5)
    }

    func testAttributionAbbreviation() {
        let attributionsHTML = """
  <a href=\"https://www.mapbox.com/about/maps/\" target=\"_blank\" title=\"Mapbox\" aria-label=\"Mapbox\" role=\"listitem\">&copy; Mapbox</a> <a href=\"https://www.openstreetmap.org/about/\" target=\"_blank\" title=\"OpenStreetMap\" aria-label=\"OpenStreetMap\" role=\"listitem\">&copy; OpenStreetMap</a>
"""
        let parseExpectation = expectation(description: "Attributions are parsed")

        Attribution.parse([attributionsHTML]) { attributions in

            guard attributions.count == 2 else {
                XCTFail("Parsing should return 2 attributions")
                return
            }

            let attribution0 = attributions[0]
            XCTAssertEqual(attribution0.titleAbbreviation, "Mapbox")

            let attribution1 = attributions[1]
            XCTAssertEqual(attribution1.titleAbbreviation, "OSM")

            parseExpectation.fulfill()
        }

        wait(for: [parseExpectation], timeout: 5)
    }

    func testFeedbackSnapshotTitle() {
        let attribution = Attribution(title: "Improve this map", url: URL(string: "http://mapbox.com/")!)

        XCTAssertEqual(attribution.kind, .feedback)

        Attribution.Style.allCases.forEach { style in
            XCTAssertNil(attribution.snapshotTitle(for: style))
        }
    }

    func testOSMSnapshotTitle() {
        let url = URL(string: "http://mapbox.com/")!
        let attribution = Attribution(title: "OpenStreetMap", url: url)

        XCTAssertEqual(attribution.kind, .actionable(url))

        XCTAssertEqual(attribution.snapshotTitle(for: .regular), "OpenStreetMap")
        XCTAssertEqual(attribution.snapshotTitle(for: .abbreviated), "OSM")
        XCTAssertNil(attribution.snapshotTitle(for: .none))
    }

    func testNonOSMSnapshotTitle() {
        let attributionTitle = String.randomASCII(withLength: 10)
        let attribution = Attribution(title: attributionTitle, url: nil)

        XCTAssertEqual(attribution.kind, .nonActionable)

        XCTAssertEqual(attribution.snapshotTitle(for: .regular), attributionTitle)
        XCTAssertEqual(attribution.snapshotTitle(for: .abbreviated), attributionTitle)
        XCTAssertNil(attribution.snapshotTitle(for: .none))
    }

    func testAttributionFeedbackURL() throws {
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 1, longitude: 2), zoom: 3, bearing: 4, pitch: 5)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions)
        let metadataPath = Bundle.mapboxMaps.url(forResource: "MapboxMaps", withExtension: "json")!
        let data = try! Data(contentsOf: metadataPath)
        let metadata = try! JSONDecoder().decode(MapboxMapsMetadata.self, from: data)
        let expectedURL = try XCTUnwrap(URL(string: "https://apps.mapbox.com/feedback/?referrer=\(Bundle.main.bundleIdentifier!)&owner=mapbox&id=standard&access_token=test-token&map_sdk_version=\(metadata.version)#/2.00000/1.00000/3.00/4.0/5"))

        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        let url = mapView.mapboxFeedbackURL(accessToken: "test-token")

        XCTAssertEqual(expectedURL, url)
    }
}
