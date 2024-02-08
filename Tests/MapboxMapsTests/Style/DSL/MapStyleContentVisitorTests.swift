import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class MapStyleContentVisitorTests: XCTestCase {
    var mapStyleContentVisitor: MapStyleContentVisitor!

    override func setUpWithError() throws {
        mapStyleContentVisitor = MapStyleContentVisitor()
    }

    override func tearDownWithError() throws {
        mapStyleContentVisitor = nil
    }

    func testAddAllLayerTypes() {
        let sourceID = "dummy"

        let fill = FillLayer(id: "fill", source: sourceID)
        fill._visit(mapStyleContentVisitor)

        let line = LineLayer(id: "line", source: sourceID)
        line._visit(mapStyleContentVisitor)

        let symbol = SymbolLayer(id: "symbol", source: sourceID)
        symbol._visit(mapStyleContentVisitor)

        let circle = CircleLayer(id: "circle", source: sourceID)
        circle._visit(mapStyleContentVisitor)

        let heatmap = HeatmapLayer(id: "heatmap", source: sourceID)
        heatmap._visit(mapStyleContentVisitor)

        let fillExtrusion = FillExtrusionLayer(id: "fillExtrusion", source: sourceID)
        fillExtrusion._visit(mapStyleContentVisitor)

        let raster = RasterLayer(id: "raster", source: sourceID)
        raster._visit(mapStyleContentVisitor)

        let hillshade = HillshadeLayer(id: "hillshade", source: sourceID)
        hillshade._visit(mapStyleContentVisitor)

        let model = ModelLayer(id: "model", source: sourceID)
        model._visit(mapStyleContentVisitor)

        let background = BackgroundLayer(id: "background")
        background._visit(mapStyleContentVisitor)

        let sky = SkyLayer(id: "sky")
        sky._visit(mapStyleContentVisitor)

        let locationIndicator = LocationIndicatorLayer(id: "locationIndicator")
        locationIndicator._visit(mapStyleContentVisitor)

        XCTAssertEqual(mapStyleContentVisitor.model.layers,
                       [LayerWrapper.fill(fill),
                        LayerWrapper.line(line),
                        LayerWrapper.symbol(symbol),
                        LayerWrapper.circle(circle),
                        LayerWrapper.heatmap(heatmap),
                        LayerWrapper.fillExtrusion(fillExtrusion),
                        LayerWrapper.raster(raster),
                        LayerWrapper.hillshade(hillshade),
                        LayerWrapper.model(model),
                        LayerWrapper.background(background),
                        LayerWrapper.sky(sky),
                        LayerWrapper.locationIndicator(locationIndicator)]
        )
    }

    func testAddAllSourceTypes() {
        let vector = VectorSource(id: "vector")
        vector._visit(mapStyleContentVisitor)
        XCTAssertEqual(mapStyleContentVisitor.model.sources[vector.id], SourceWrapper.vector(vector))

        let raster = RasterSource(id: "raster")
        raster._visit(mapStyleContentVisitor)
        XCTAssertEqual(mapStyleContentVisitor.model.sources[raster.id], SourceWrapper.raster(raster))

        let rasterDem = RasterDemSource(id: "rasterDem")
        rasterDem._visit(mapStyleContentVisitor)
        XCTAssertEqual(mapStyleContentVisitor.model.sources[rasterDem.id], SourceWrapper.rasterDem(rasterDem))

        let image = ImageSource(id: "image")
        image._visit(mapStyleContentVisitor)
        XCTAssertEqual(mapStyleContentVisitor.model.sources[image.id], SourceWrapper.image(image))

        let geoJson = GeoJSONSource(id: "geoJson")
        geoJson._visit(mapStyleContentVisitor)
        XCTAssertEqual(mapStyleContentVisitor.model.sources[geoJson.id], SourceWrapper.geoJson(geoJson))

    }

    func testAddStyleImages() {
        let uiImage = UIImage()
        let image = StyleImage(id: "styleImage", image: uiImage)

        image.visit(mapStyleContentVisitor)

        XCTAssertEqual(mapStyleContentVisitor.model.images, [image.id: image])
    }

    func testAddTerrain() {
        let terrain = Terrain(sourceId: "terrain")

        terrain.visit(mapStyleContentVisitor)

        XCTAssertEqual(mapStyleContentVisitor.model.terrain, terrain)
    }

    func testAddAtmosphere() {
        let atmosphere = Atmosphere()

        atmosphere.visit(mapStyleContentVisitor)

        XCTAssertEqual(mapStyleContentVisitor.model.atmosphere, atmosphere)
    }

    func testAddProjection() {
        let projection = StyleProjection(name: .globe)

        projection.visit(mapStyleContentVisitor)

        XCTAssertEqual(mapStyleContentVisitor.model.projection, projection)
    }

}
