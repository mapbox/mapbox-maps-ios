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
        styleURL = .randomASCII(withLength: .random(in: 0...50))
        coordinate = .random()
        minZoom = .random(in: 0..<10)
        maxZoom = .random(in: 10...20)
        // swiftlint:disable:next syntactic_sugar
        pixelRatio = Array<Float>([1.0, 2.0, 3.0]).randomElement()!
        glyphsRasterizationMode = [
            .noGlyphsRasterizedLocally,
            .ideographsRasterizedLocally,
            .allGlyphsRasterizedLocally].randomElement()!
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
