import XCTest
@testable import MapboxMaps

class OfflineRegionGeometryDefinitionTests: XCTestCase {

    var coordinate: CLLocationCoordinate2D!
    var styleUrl: String = "testurl.com"
    let minZoom: Double = 1
    let maxZoom: Double = 20
    let pixelRatio: Float = Float(UIScreen.main.scale)
    let glyphsRasterizationMode: GlyphsRasterizationMode = .noGlyphsRasterizedLocally

    override func setUp() {
        super.setUp()
        coordinate = .random()
    }

    override func tearDown() {
        coordinate = nil
        super.tearDown()
    }

    func testInitializationWithNonNilAndNonEmptyValues() throws {
        let offlineRegionGeometryDefinition = try XCTUnwrap(OfflineRegionGeometryDefinition(styleURL: styleUrl,
                                                                                            geometry: Geometry.point(Point(coordinate)),
                                                                                            minZoom: minZoom,
                                                                                            maxZoom: maxZoom,
                                                                                            pixelRatio: pixelRatio,
                                                                                            glyphsRasterizationMode: glyphsRasterizationMode))

        XCTAssertEqual(offlineRegionGeometryDefinition.__geometry.geometryType, GeometryType_Point)
    }

    func testNonNilGeometry() {
        let offlineRegionGeometryDefinition = OfflineRegionGeometryDefinition(__styleURL: styleUrl,
                                                                              geometry: MapboxCommon.Geometry(point: CGPoint(x: coordinate.latitude, y: coordinate.longitude) as NSValue),
                                                                              minZoom: minZoom,
                                                                              maxZoom: maxZoom,
                                                                              pixelRatio: pixelRatio,
                                                                              glyphsRasterizationMode: glyphsRasterizationMode)

        XCTAssertEqual(offlineRegionGeometryDefinition.geometry, .point(.init(coordinate)))
    }
}
