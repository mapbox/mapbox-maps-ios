import XCTest
@testable import MapboxMaps
import Foundation
import UIKit

class AttributionTests: XCTestCase {

    let sdkVersion = Bundle.mapboxMapsMetadata.version

    override func setUp() {
        super.setUp()
        Bundle.mapboxMapsMetadata.version = "AttributionTests"
    }

    override func tearDown() {
        super.tearDown()
        Bundle.mapboxMapsMetadata.version = sdkVersion
    }

    func testAttribution() {
        let a1 = Attribution(title: "Hello World", url: URL(string: "https://example.com")!)
        XCTAssertEqual(a1.title, "Hello World")
        XCTAssertEqual(a1.titleAbbreviation, "Hello World")
        XCTAssertFalse(a1.isFeedbackURL)

        let a2 = Attribution(title: Attribution.OSM, url: URL(string: "https://example.com")!)
        XCTAssertEqual(a2.title, Attribution.OSM)
        XCTAssertEqual(a2.titleAbbreviation, Attribution.OSMAbbr)

        for urlString in Attribution.improveMapURLs {
            let a3 = Attribution(title: "Don't Improve this map", url: URL(string: urlString)!)
            XCTAssert(a3.isFeedbackURL)
        }

        let a4 = Attribution(title: "Improve this map", url: URL(string: "https://example.com")!)
        XCTAssert(a4.isFeedbackURL)
    }

    func testAttributionFeedbackURL() throws {
        let resourceOptions = ResourceOptions(accessToken: "test-token")
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 1, longitude: 2), zoom: 3, bearing: 4, pitch: 5)
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions, cameraOptions: cameraOptions)

        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions)
        let url = mapView.mapboxFeedbackURL()

        let expectedURL = try XCTUnwrap(URL(string: "https://apps.mapbox.com/feedback/?referrer=com.apple.dt.xctest.tool&owner=mapbox&id=streets-v11&access_token=test-token&map_sdk_version=AttributionTests#/2.00000/1.00000/3.00/4.0/5"))
        XCTAssertEqual(expectedURL, url)
    }
}
