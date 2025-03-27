import XCTest
@testable import MapboxMaps

@available(*, deprecated)
final class OfflineRegionGeometryDefinitionTests: XCTestCase {

    var styleURL: String!
    var coordinate: CLLocationCoordinate2D!
    var minZoom: Double!
    var maxZoom: Double!
    var pixelRatio: Float!
    var glyphsRasterizationMode: GlyphsRasterizationMode!

    override func setUp() {
        super.setUp()
        styleURL = .testConstantASCII(withLength: 50)
        coordinate = .testConstantValue()
        minZoom = 9
        maxZoom = 15
        pixelRatio = 2.0
        glyphsRasterizationMode = .allGlyphsRasterizedLocally
    }

    override func tearDown() {
        glyphsRasterizationMode = nil
        pixelRatio = nil
        maxZoom = nil
        minZoom = nil
        coordinate = nil
        styleURL = nil
        super.tearDown()
    }

    func testInitialization() {
        let offlineRegionGeometryDefinition = OfflineRegionGeometryDefinition(
            styleURL: styleURL,
            geometry: .point(Point(coordinate)),
            minZoom: minZoom,
            maxZoom: maxZoom,
            pixelRatio: pixelRatio,
            glyphsRasterizationMode: glyphsRasterizationMode)

        XCTAssertEqual(offlineRegionGeometryDefinition.styleURL, styleURL)
        XCTAssertEqual(offlineRegionGeometryDefinition.__geometry.geometryType, GeometryType_Point)
        XCTAssertEqual(offlineRegionGeometryDefinition.__geometry.extractLocations()?.coordinateValue(), coordinate)
        XCTAssertEqual(offlineRegionGeometryDefinition.minZoom, minZoom)
        XCTAssertEqual(offlineRegionGeometryDefinition.maxZoom, maxZoom)
        XCTAssertEqual(offlineRegionGeometryDefinition.pixelRatio, pixelRatio)
        XCTAssertEqual(offlineRegionGeometryDefinition.glyphsRasterizationMode, glyphsRasterizationMode)
    }

    func testGeometry() {
        let offlineRegionGeometryDefinition = OfflineRegionGeometryDefinition(
            __styleURL: styleURL,
            geometry: MapboxCommon.Geometry(point: coordinate.toValue()),
            minZoom: minZoom,
            maxZoom: maxZoom,
            pixelRatio: pixelRatio,
            glyphsRasterizationMode: glyphsRasterizationMode)

        XCTAssertEqual(offlineRegionGeometryDefinition.geometry, .point(Point(coordinate)))
    }
}
