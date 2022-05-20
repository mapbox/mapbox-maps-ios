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
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").kind, .constant)
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").value as? String, "mercator")
        try style.setProjection(StyleProjection(name: .globe))
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").value as? String, "globe")
    }

    func testProjection() {
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").kind, .constant)
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").value as? String, "mercator")
        XCTAssertEqual(style.projection.name, .mercator)

        style.styleManager.setStyleProjectionForProperties(["name": "mercator"])
        XCTAssertEqual(style.projection.name, .mercator)

        style.styleManager.setStyleProjectionForProperties(["name": "globe"])
        XCTAssertEqual(style.projection.name, .globe)
    }
}
