import XCTest
@testable import MapboxMaps

final class StyleTests: XCTestCase {
    var mapClient: MockMapClient!
    var style: Style!
    var map: Map!

    override func setUpWithError() throws {
        mapClient = MockMapClient()
        map = Map(
            client: mapClient,
            mapOptions: MapOptions(),
            resourceOptions: MapboxCoreMaps.ResourceOptions(ResourceOptions(accessToken: "")))
        style = Style(with: map)
    }

    override func tearDown() {
        mapClient = nil
        style = nil
        map = nil
    }

    func testSetProjection() throws {
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").kind, .undefined)
        try style.setProjection(StyleProjection(name: .globe))
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").value as? String, "globe")
    }

    func testSetProjectionError() throws {
        XCTAssertThrowsError(try style.setProjection(StyleProjection(name: StyleProjectionName(rawValue: "not a supported name")))) { error in
            XCTAssertTrue(error is StyleError)
        }
    }

    func testProjection() {
        // defaults to mercator if it's undefined
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").kind, .undefined)
        XCTAssertEqual(style.projection.name, .mercator)

        style.styleManager.setStyleProjectionForProperties(["name": "mercator"])
        XCTAssertEqual(style.projection.name, .mercator)

        style.styleManager.setStyleProjectionForProperties(["name": "globe"])
        XCTAssertEqual(style.projection.name, .globe)
    }
}
