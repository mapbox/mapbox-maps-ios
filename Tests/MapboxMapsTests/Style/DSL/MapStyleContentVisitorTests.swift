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
        let line = LineLayer(id: "line", source: sourceID)
        let symbol = SymbolLayer(id: "symbol", source: sourceID)
        let circle = CircleLayer(id: "circle", source: sourceID)
        let heatmap = HeatmapLayer(id: "heatmap", source: sourceID)
        let fillExtrusion = FillExtrusionLayer(id: "fillExtrusion", source: sourceID)
        let raster = RasterLayer(id: "raster", source: sourceID)
        let hillshade = HillshadeLayer(id: "hillshade", source: sourceID)
        let model = ModelLayer(id: "model", source: sourceID)
        let background = BackgroundLayer(id: "background")
        let sky = SkyLayer(id: "sky")
        let locationIndicator = LocationIndicatorLayer(id: "locationIndicator")

        fill._visit(mapStyleContentVisitor)
        line._visit(mapStyleContentVisitor)
        symbol._visit(mapStyleContentVisitor)
        circle._visit(mapStyleContentVisitor)
        heatmap._visit(mapStyleContentVisitor)
        fillExtrusion._visit(mapStyleContentVisitor)
        raster._visit(mapStyleContentVisitor)
        hillshade._visit(mapStyleContentVisitor)
        model._visit(mapStyleContentVisitor)
        background._visit(mapStyleContentVisitor)
        sky._visit(mapStyleContentVisitor)
        locationIndicator._visit(mapStyleContentVisitor)

        XCTAssertEqual(mapStyleContentVisitor.model.layers,
                       ["fill": LayerWrapper.fill(fill),
                        "line": LayerWrapper.line(line),
                       "symbol": LayerWrapper.symbol(symbol),
                       "circle": LayerWrapper.circle(circle),
                       "heatmap": LayerWrapper.heatmap(heatmap),
                       "fillExtrusion": LayerWrapper.fillExtrusion(fillExtrusion),
                       "raster": LayerWrapper.raster(raster),
                       "hillshade": LayerWrapper.hillshade(hillshade),
                       "model": LayerWrapper.model(model),
                       "background": LayerWrapper.background(background),
                       "sky": LayerWrapper.sky(sky),
                       "locationIndicator": LayerWrapper.locationIndicator(locationIndicator)])
    }

    func testAddAllSourceTypes() {
        let vector = VectorSource(id: "vector")
        let raster = RasterSource(id: "raster")
        let rasterDem = RasterDemSource(id: "rasterDem")
        let image = ImageSource(id: "image")
        let geoJson = GeoJSONSource(id: "geoJson")

        vector._visit(mapStyleContentVisitor)
        raster._visit(mapStyleContentVisitor)
        rasterDem._visit(mapStyleContentVisitor)
        image._visit(mapStyleContentVisitor)
        geoJson._visit(mapStyleContentVisitor)

        XCTAssertEqual(mapStyleContentVisitor.model.sources,
                       ["vector": SourceWrapper.vector(vector),
                        "raster": SourceWrapper.raster(raster),
                        "rasterDem": SourceWrapper.rasterDem(rasterDem),
                        "image": SourceWrapper.image(image),
                        "geoJson": SourceWrapper.geoJson(geoJson)])
    }

    func testAddStyleImages() {
        let uiImage = UIImage()
        let image = StyleImage(id: "styleImage", image: uiImage)

        image.visit(mapStyleContentVisitor)

        XCTAssertEqual(mapStyleContentVisitor.model.images, ["styleImage": image])
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
