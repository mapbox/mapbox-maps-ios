import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class StyleTests: XCTestCase {
    var mapClient: MockMapClient!
    var style: Style!
    var map: Map!

    override func setUpWithError() throws {
        mapClient = MockMapClient()
        map = Map(client: mapClient,
                  mapOptions: MapOptions(),
                  resourceOptions: MapboxCoreMaps.ResourceOptions(ResourceOptions(accessToken: "")))
        style = Style(with: map)
    }

    override func tearDown() {
        mapClient = nil
        style = nil
        map = nil
    }

    func testSetMapProjection() {
        XCTAssertNil(style.styleManager.getStyleProjectionProperty(forProperty: "name").value as? String)
        try? style.setMapProjection(.globe())
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").value as? String, "globe")
    }

    func testGetMapProjection() {
        style.styleManager.setStyleProjectionForProperties(["name": "mercator"])
        var projection = try? style.mapProjection()
        XCTAssertEqual(projection, .mercator())

        style.styleManager.setStyleProjectionForProperties(["name": "globe"])
        projection = try? style.mapProjection()
        XCTAssertEqual(projection, .globe())
    }
}
