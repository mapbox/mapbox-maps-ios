import XCTest
@_spi(Experimental) @testable import MapboxMaps

@available(iOS 13.0, *)
final class MapContentReconcilerTests: XCTestCase {
    var me: MapContentReconciler!
    var styleManager: MockStyleManager!
    var sourceManager: MockStyleSourceManager!
    var style: MockStyle!
    var annotationsOrchestrator: AnnotationOrchestrator!
    var orchestratorImpl: MockAnnotationOrchestatorImpl!
    var viewAnnotationsManager: ViewAnnotationManager!
    var locationManager: LocationManager!
    var circleAnnotationManager: CircleAnnotationManager!

    @TestPublished var styleIsLoaded = true

    override func setUp() {
        styleManager = MockStyleManager()
        sourceManager = MockStyleSourceManager()
        style = MockStyle()
        orchestratorImpl = MockAnnotationOrchestatorImpl()
        annotationsOrchestrator = AnnotationOrchestrator(impl: orchestratorImpl)
        viewAnnotationsManager = ViewAnnotationManager(containerView: UIView(), mapboxMap: MockMapboxMap(), displayLink: Signal(just: ()))
        locationManager = LocationManager(
            interfaceOrientationView: Ref({ nil }),
            displayLink: Signal(just: ()),
            styleManager: style,
            mapboxMap: MockMapboxMap()
        )
        circleAnnotationManager = CircleAnnotationManager(
            id: "test",
            style: style,
            layerPosition: .default,
            displayLink: Signal { _ in .empty },
            offsetCalculator: OffsetPointCalculator(mapboxMap: MockMapboxMap())
        )
        styleIsLoaded = true

        me = MapContentReconciler(styleManager: styleManager, sourceManager: sourceManager, styleIsLoaded: $styleIsLoaded)
        me.setMapContentDependencies(MapContentDependencies(
            layerAnnotations: Ref.weakRef(self, property: \.annotationsOrchestrator),
            viewAnnotations: Ref.weakRef(self, property: \.viewAnnotationsManager),
            location: Ref.weakRef(self, property: \.locationManager),
            addAnnotationViewController: { _ in },
            removeAnnotationViewController: { _ in }
        ))
    }

    override func tearDown() {
        me = nil
        sourceManager = nil
        styleManager = nil
    }

    private func setContent(@MapContentBuilder content: () -> some MapContent) {
        me.content = content()
    }

    func testReconcileMapContentOnLoad() {
        styleIsLoaded = false
        var lineLayer = LineLayer(id: "testLine", source: "testLineSource")

        setContent {
            lineLayer
        }

        styleIsLoaded = true
        styleManager.styleLayerExistsStub.defaultReturnValue = true

        lineLayer.lineColor = .constant(StyleColor.init(.brown))

        setContent {
            lineLayer
        }

        let addLayerInv = styleManager.addStyleLayerStub.invocations
        XCTAssertEqual(addLayerInv.count, 1)
        guard let layerProperties = addLayerInv.last?.parameters.properties as? [String: Any] else {
            XCTFail("Failed to get layerProperties")
            return
        }
        XCTAssertEqual(layerProperties["type"] as? String, "line")
        XCTAssertEqual(layerProperties["id"] as? String, "testLine")
        XCTAssertEqual(layerProperties["source"] as? String, "testLineSource")

        let updateLayerInv = styleManager.setStyleLayerPropertiesStub.invocations
        XCTAssertEqual(updateLayerInv.count, 1)
        guard let layer2Properties = updateLayerInv.last?.parameters.properties as? [String: Any] else {
            XCTFail("Failed to get layer properties")
            return
        }
        XCTAssertEqual(layer2Properties["type"] as? String, "line")
        XCTAssertEqual(layer2Properties["id"] as? String, "testLine")
        XCTAssertEqual(layer2Properties["source"] as? String, "testLineSource")
        guard let layer2Print = layer2Properties["paint"] as? [String: Any],
            let layer2Color = layer2Print["line-color"] as? String else {
            XCTFail("Failed to get layer color")
            return
        }
        XCTAssertEqual(layer2Color, "rgba(153.00, 102.00, 51.00, 1.00)")
    }

    func testReconcileMapContentWhenReload() {
        styleIsLoaded = false
        var lineLayer = LineLayer(id: "testLine", source: "testLineSource")
        setContent {
            lineLayer
        }

        styleIsLoaded = true

        lineLayer.lineColor = .constant(StyleColor.init(.brown))

        styleIsLoaded = false
        setContent {
            lineLayer
        }

        styleIsLoaded = true

        // because Standard was changed to Streets a new layer should be added rather than updated
        let addLayerInv = styleManager.addStyleLayerStub.invocations
        XCTAssertEqual(addLayerInv.count, 2)
        guard let layerProperties = addLayerInv.first?.parameters.properties as? [String: Any] else {
            XCTFail("Failed to get layerProperties")
            return
        }
        XCTAssertEqual(layerProperties["type"] as? String, "line")
        XCTAssertEqual(layerProperties["id"] as? String, "testLine")
        XCTAssertEqual(layerProperties["source"] as? String, "testLineSource")

        let updateLayerInv = styleManager.setStyleLayerPropertiesStub.invocations
        XCTAssertEqual(updateLayerInv.count, 0)

        guard let layer2Properties = addLayerInv.last?.parameters.properties as? [String: Any] else {
            XCTFail("Failed to get layer properties")
            return
        }
        XCTAssertEqual(layer2Properties["type"] as? String, "line")
        XCTAssertEqual(layer2Properties["id"] as? String, "testLine")
        XCTAssertEqual(layer2Properties["source"] as? String, "testLineSource")
        guard let layer2Print = layer2Properties["paint"] as? [String: Any],
              let layer2Color = layer2Print["line-color"] as? String else {
            XCTFail("Failed to get layer color")
            return
        }
        XCTAssertEqual(layer2Color, "rgba(153.00, 102.00, 51.00, 1.00)")
    }

    func testReconcileAddRemoveContent() {
        styleManager.styleLayerExistsStub.defaultReturnValue = true
        let terrain = Terrain(sourceId: "testTerrain")
        let atmosphere = Atmosphere()
        let symbolLayer = SymbolLayer(id: "testSymbol", source: "testSymbolSource")
        let styleImage = StyleImage(id: "testStyleImage", image: UIImage.empty)
        let projection = StyleProjection(name: .globe)

        setContent {
            terrain
            atmosphere
            symbolLayer
            styleImage
            projection
        }

        // test remove elements when base style kept the same, but map content removed
        setContent {}

        // terrain
        let setTerrainInv = styleManager.setStyleTerrainForPropertiesStub.invocations
        XCTAssertEqual(setTerrainInv.count, 2) // one for add and one for remove
        guard let terrainParameters = setTerrainInv.first?.parameters as? [String: Any] else {
            XCTFail("Failed to get terrainParameters")
            return
        }
        XCTAssertEqual(terrainParameters["source"] as? String, "testTerrain")
        guard setTerrainInv.last?.parameters is NSNull else {
            XCTFail("terrain should be null")
            return
        }

        // atmosphere
        let addAtmosphereInv = styleManager.setStyleAtmosphereForPropertiesStub.invocations
        XCTAssertEqual(addAtmosphereInv.count, 2)
        guard let atmosphereParameters = addAtmosphereInv.first?.parameters as? [String: Any] else {
            XCTFail("Failed to get atmosphereParameters")
            return
        }
        XCTAssertEqual(atmosphereParameters.count, 0)
        guard addAtmosphereInv.last?.parameters is NSNull else {
            XCTFail("atmosphere should be null")
            return
        }

        // layers
        let addLayerInv = styleManager.addStyleLayerStub.invocations
        XCTAssertEqual(addLayerInv.count, 1)
        let removeLayerInv = styleManager.removeStyleLayerStub.invocations
        XCTAssertEqual(removeLayerInv.count, 1)
        guard let removeLayerParameters = removeLayerInv.first?.parameters as? String else {
            XCTFail("Failed to get removeLayerParameters")
            return
        }
        XCTAssertEqual(removeLayerParameters, "testSymbol")

        // style image
        let addStyleImageInv = styleManager.addStyleImageStub.invocations
        XCTAssertEqual(addStyleImageInv.count, 1)
        guard let imageParameters = addStyleImageInv.first?.parameters else {
            XCTFail("Failed to get imageProperties")
            return
        }
        XCTAssertEqual(imageParameters.imageId, "testStyleImage")
        let removeStyleImageInv = styleManager.removeStyleImageStub.invocations
        XCTAssertEqual(removeStyleImageInv.count, 1)
        guard let removeImageParameters = removeStyleImageInv.first?.parameters as? String else {
            XCTFail("Failed to get removeImageParameters")
            return
        }
        XCTAssertEqual(removeImageParameters, "testStyleImage")

        // projection
        let addGlobeProjectionInv = styleManager.setStyleProjectionPropertiesStub.invocations
        XCTAssertEqual(addGlobeProjectionInv.count, 2)
        guard let projectionParameters = addGlobeProjectionInv.first?.parameters as? [String: Any] else {
            XCTFail("Failed to get projection")
            return
        }
        XCTAssertEqual(projectionParameters["name"] as? String, "globe")
        guard addGlobeProjectionInv.last?.parameters is NSNull else {
            XCTFail("Projection should be null")
            return
        }
    }

    func testAddLayerAgainAfterStyleSwitch() {
        styleManager.styleLayerExistsStub.defaultReturnValue = false
        let lineLayer = LineLayer(id: "testLine", source: "testLineSource")

        setContent {
            lineLayer
        }

        styleManager.styleLayerExistsStub.defaultReturnValue = false

        setContent {
            lineLayer
        }

        let addLayerInv = styleManager.addStyleLayerStub.invocations
        XCTAssertEqual(addLayerInv.count, 2)
        guard let layerProperties = addLayerInv.first?.parameters.properties as? [String: Any] else {
            XCTFail("Failed to get layerProperties")
            return
        }
        XCTAssertEqual(layerProperties["type"] as? String, "line")
        XCTAssertEqual(layerProperties["id"] as? String, "testLine")
        XCTAssertEqual(layerProperties["source"] as? String, "testLineSource")

        let updateLayerInv = styleManager.setStyleLayerPropertiesStub.invocations
        XCTAssertEqual(updateLayerInv.count, 0)

        guard let layer2Properties = addLayerInv.last?.parameters.properties as? [String: Any] else {
            XCTFail("Failed to get layer properties")
            return
        }
        XCTAssertEqual(layer2Properties["type"] as? String, "line")
        XCTAssertEqual(layer2Properties["id"] as? String, "testLine")
        XCTAssertEqual(layer2Properties["source"] as? String, "testLineSource")
    }

    func testAddSources() {
        setContent {
            VectorSource(id: "vectorSource")
            RasterSource(id: "rasterSource")
            RasterDemSource(id: "rasterDemSource")
            ImageSource(id: "imageSource")
            GeoJSONSource(id: "geoJSONSource")
            RasterArraySource(id: "rasterArraySource")
        }

        XCTAssertEqual(sourceManager.addSourceStub.invocations.count, 6)

        var sourceIDs = [String]()
        for invocation in sourceManager.addSourceStub.invocations {
            sourceIDs.append(invocation.parameters.source.id)
        }

        XCTAssertTrue(sourceIDs.contains("vectorSource"))
        XCTAssertTrue(sourceIDs.contains("rasterSource"))
        XCTAssertTrue(sourceIDs.contains("rasterDemSource"))
        XCTAssertTrue(sourceIDs.contains("imageSource"))
        XCTAssertTrue(sourceIDs.contains("geoJSONSource"))
        XCTAssertTrue(sourceIDs.contains("rasterArraySource"))
    }

    func testAddSourcesAgainAfterStyleSwitch() {
        setContent {
            VectorSource(id: "vectorSource")
            RasterSource(id: "rasterSource")
            RasterDemSource(id: "rasterDemSource")
            ImageSource(id: "imageSource")
            GeoJSONSource(id: "geoJSONSource")
            RasterArraySource(id: "rasterArraySource")
        }

        XCTAssertEqual(sourceManager.addSourceStub.invocations.count, 6)

        sourceManager.sourceExistsStub.defaultReturnValue = false

        setContent {
            VectorSource(id: "vectorSource")
            RasterSource(id: "rasterSource")
            RasterDemSource(id: "rasterDemSource")
            ImageSource(id: "imageSource")
            GeoJSONSource(id: "geoJSONSource")
            RasterArraySource(id: "rasterArraySource")
        }

        XCTAssertEqual(sourceManager.addSourceStub.invocations.map(\.parameters.source.id), [
            "vectorSource", "rasterSource", "rasterDemSource", "imageSource", "geoJSONSource", "rasterArraySource",
            "vectorSource", "rasterSource", "rasterDemSource", "imageSource", "geoJSONSource", "rasterArraySource",
        ])
    }

    func testUpdateSources() {
        sourceManager.sourceExistsStub.defaultReturnValue = true
        var vectorSource = VectorSource(id: "vectorSource")
        var rasterSource = RasterSource(id: "rasterSource")
        var rasterDEMSource = RasterDemSource(id: "rasterDemSource")
        var imageSource = ImageSource(id: "imageSource")
        var geoJSONSource = GeoJSONSource(id: "geoJSONSource")
        var rasterArraySource = RasterArraySource(id: "rasterArraySource")

        setContent {
            vectorSource
            rasterSource
            rasterDEMSource
            imageSource
            geoJSONSource
            rasterArraySource
        }

        vectorSource.minzoom = 1
        rasterSource.minzoom = 2
        rasterDEMSource.minzoom = 3
        imageSource.url = "test"
        geoJSONSource.data = GeoJSONSourceData.testSourceValue()
        rasterArraySource.minzoom = 6

        setContent {
            vectorSource
            rasterSource
            rasterDEMSource
            imageSource
            geoJSONSource
            rasterArraySource
        }

        XCTAssertEqual(sourceManager.setSourcePropertiesForParamsStub.invocations.count, 5)
        XCTAssertEqual(sourceManager.updateGeoJSONSourceStub.invocations.count, 1)

        var sourceIDs = [String]()
        for invocation in sourceManager.setSourcePropertiesForParamsStub.invocations {
            sourceIDs.append(invocation.parameters.sourceId)
        }

        /// Test each updated
        XCTAssertTrue(sourceIDs.contains("vectorSource"))
        XCTAssertTrue(sourceIDs.contains("rasterSource"))
        XCTAssertTrue(sourceIDs.contains("rasterDemSource"))
        XCTAssertTrue(sourceIDs.contains("imageSource"))
        XCTAssertTrue(sourceIDs.contains("rasterArraySource"))
    }

    func testRemoveSource() throws {
        sourceManager.sourceExistsStub.defaultReturnValue = true
        setContent {
            VectorSource(id: "vectorSource")
        }

        XCTAssertEqual(sourceManager.addSourceStub.invocations.count, 1)

        setContent {}

        XCTAssertEqual(sourceManager.removeSourceUncheckedStub.invocations.count, 1)
        let removeSourceParameters = try XCTUnwrap(sourceManager.removeSourceUncheckedStub.invocations.first?.parameters as? String)
        XCTAssertEqual(removeSourceParameters, "vectorSource")
    }

    func testUpdateImage() {
        styleManager.hasStyleImageStub.defaultReturnValue = true

        var styleImage = StyleImage(id: "testStyleImage", image: UIImage.empty)

        setContent {
            styleImage
        }

        XCTAssertEqual(styleManager.addStyleImageStub.invocations.count, 1)

        styleImage.sdf = true

        setContent {
            styleImage
        }

        XCTAssertEqual(styleManager.addStyleImageStub.invocations.count, 2)
        XCTAssertEqual(styleManager.addStyleImageStub.invocations.first?.parameters.sdf, false)
        XCTAssertEqual(styleManager.addStyleImageStub.invocations.first?.parameters.imageId, "testStyleImage")
        XCTAssertEqual(styleManager.addStyleImageStub.invocations.last?.parameters.sdf, true)
        XCTAssertEqual(styleManager.addStyleImageStub.invocations.last?.parameters.imageId, "testStyleImage")

        setContent {}

        XCTAssertEqual(styleManager.removeStyleImageStub.invocations.count, 1)
        XCTAssertEqual(styleManager.removeStyleImageStub.invocations.last?.parameters, "testStyleImage")
    }

    func testAddImageAgainAfterStyleSwitch() {
        let styleImage = StyleImage(id: "testStyleImage", image: UIImage.empty)

        setContent {
            styleImage
        }

        XCTAssertEqual(styleManager.addStyleImageStub.invocations.count, 1)

        styleManager.hasStyleImageStub.defaultReturnValue = false

        setContent {
            styleImage
        }

        XCTAssertEqual(styleManager.addStyleImageStub.invocations.count, 2)
        XCTAssertEqual(styleManager.addStyleImageStub.invocations.map(\.parameters.imageId), ["testStyleImage", "testStyleImage"])
    }

    func testDontUpdateSameImage() {
        styleManager.hasStyleImageStub.defaultReturnValue = true
        let styleImage = StyleImage(id: "testStyleImage", image: UIImage.empty)

        setContent {
            styleImage
        }

        XCTAssertEqual(styleManager.addStyleImageStub.invocations.count, 1)

        setContent {
            styleImage
        }

        XCTAssertEqual(styleManager.addStyleImageStub.invocations.count, 1)
        XCTAssertEqual(styleManager.addStyleImageStub.invocations.first?.parameters.imageId, "testStyleImage")

    }

    func testAddRemoveSource() {
        sourceManager.sourceExistsStub.defaultReturnValue = true

        let source = VectorSource(id: "test-source")
            .url(String.testSourceValue())
            .tiles([String].testSourceValue())

        var boolean = true

        setContent {
            if boolean {
                source
            }
        }

        XCTAssertEqual(sourceManager.addSourceStub.invocations.count, 1)

        boolean = false
        setContent {
            if boolean {
                source
            }
        }

        XCTAssertEqual(sourceManager.removeSourceUncheckedStub.invocations.count, 1)
    }

    func testAddStyleModelAgainAfterStyleSwitch() {
        let model = Model(id: "test-id", uri: .init(string: "test-URL"))

        setContent {
            model
        }

        styleManager.hasStyleModelStub.defaultReturnValue = false

        setContent {
            model
        }

        XCTAssertEqual(styleManager.addStyleModelStub.invocations.count, 2)
        XCTAssertEqual(styleManager.addStyleModelStub.invocations.map(\.parameters.modelId), ["test-id", "test-id"])
        XCTAssertEqual(styleManager.addStyleModelStub.invocations.map(\.parameters.modelUri), ["test-URL", "test-URL"])
    }

    func testUpdateStyleModel() {
        styleManager.hasStyleModelStub.defaultReturnValue = true

        var model = Model(id: "test-id", uri: .init(string: "test-URL"))
        setContent {
            model
        }

        XCTAssertEqual(styleManager.addStyleModelStub.invocations.count, 1)
        XCTAssertEqual(styleManager.addStyleModelStub.invocations.first?.parameters.modelId, "test-id")
        XCTAssertEqual(styleManager.addStyleModelStub.invocations.first?.parameters.modelUri, "test-URL")

        model.position = .testSourceValue()

        setContent {
            model
        }

        XCTAssertEqual(styleManager.addStyleModelStub.invocations.count, 2)
        XCTAssertEqual(styleManager.addStyleModelStub.invocations.last?.parameters.modelId, "test-id")
        XCTAssertEqual(styleManager.addStyleModelStub.invocations.last?.parameters.modelUri, "test-URL")

        setContent {}

        XCTAssertEqual(styleManager.removeStyleModelStub.invocations.count, 1)
        XCTAssertEqual(styleManager.removeStyleModelStub.invocations.last?.parameters.modelId, "test-id")
    }

    func testForEvery() {
        styleManager.hasStyleModelStub.defaultReturnValue = true

        setContent {
            ForEvery([1, 2], id: \.self) { id in
                Model(id: "test-id-\(id)", uri: .init(string: "test-URL-\(id)"))
            }
        }

        XCTAssertEqual(styleManager.addStyleModelStub.invocations.map(\.parameters.modelId), ["test-id-1", "test-id-2"])
        XCTAssertEqual(styleManager.removeStyleModelStub.invocations.map(\.parameters.modelId), [])

        setContent {
            ForEvery([1, 3, 2], id: \.self) { id in
                Model(id: "test-id-\(id)", uri: .init(string: "test-URL-\(id)"))
            }
        }

        XCTAssertEqual(styleManager.addStyleModelStub.invocations.map(\.parameters.modelId), ["test-id-1", "test-id-2", "test-id-3"])
        XCTAssertEqual(styleManager.removeStyleModelStub.invocations.map(\.parameters.modelId), [])

        setContent {
            ForEvery([2], id: \.self) { id in
                Model(id: "test-id-\(id)", uri: .init(string: "test-URL-\(id)"))
            }
        }

        XCTAssertEqual(styleManager.addStyleModelStub.invocations.map(\.parameters.modelId), ["test-id-1", "test-id-2", "test-id-3"])
        let removedModels = styleManager.removeStyleModelStub.invocations.map(\.parameters.modelId)
        XCTAssertTrue(removedModels.contains("test-id-1"))
        XCTAssertTrue(removedModels.contains("test-id-3"))
    }

    func testComponent() throws {
        sourceManager.sourceExistsStub.defaultReturnValue = true
        styleManager.styleLayerExistsStub.defaultReturnValue = true
        orchestratorImpl.makeCircleAnnotationManagerStub.defaultReturnValue = circleAnnotationManager
        let route1 = MapContentFixture.Route(json: "foo")
        var component = MapContentFixture(id: "foo", route: route1, condition: true)

        setContent { component }

        XCTAssertEqual(styleManager.addStyleLayerStub.invocations.map(\.parameters.layerId), ["foo", "condition-true"])
        XCTAssertEqual(sourceManager.addSourceStub.invocations.map(\.parameters.source.id), ["route"])
        let addedSource = try XCTUnwrap(sourceManager.addSourceStub.invocations.last?.parameters.source) as? GeoJSONSource
        XCTAssertEqual(addedSource?.data, .string("foo"))
        XCTAssertEqual(viewAnnotationsManager.allAnnotations.count, 1)
        verifyAnnotationOptions(viewAnnotationsManager.allAnnotations.first, component.mapViewAnnotation)
        XCTAssertEqual(circleAnnotationManager.annotations, [
            CircleAnnotation(id: "1", point: Point(LocationCoordinate2D(latitude: 10, longitude: 10))),
            CircleAnnotation(id: "2", point: Point(LocationCoordinate2D(latitude: 20, longitude: 20)))
        ])
        XCTAssertEqual(orchestratorImpl.removeAnnotationManagerStub.invocations.map(\.parameters), [])
        XCTAssertEqual(orchestratorImpl.makeCircleAnnotationManagerStub.invocations.map(\.parameters), [
            .init(id: "circle-test", layerPosition: .at(0))
        ])
        XCTAssertEqual(locationManager.options, LocationOptions(
            puckType: .puck3D(Puck3DConfiguration(model: Model(), layerPosition: .above("circle-test"))),
            puckBearing: .heading,
            puckBearingEnabled: false
        ))

        component = MapContentFixture(id: "foo", route: route1, condition: false)
        setContent { component }

        XCTAssertEqual(styleManager.addStyleLayerStub.invocations.count, 3)
        XCTAssertEqual(styleManager.addStyleLayerStub.invocations.last?.parameters.layerId, "condition-false")
        XCTAssertEqual(styleManager.removeStyleLayerStub.invocations.count, 1)
        XCTAssertEqual(styleManager.removeStyleLayerStub.invocations.last?.parameters, "condition-true")
        XCTAssertEqual(viewAnnotationsManager.allAnnotations.count, 1)
        verifyAnnotationOptions(viewAnnotationsManager.allAnnotations.first, component.mapViewAnnotation)
        XCTAssertEqual(circleAnnotationManager.annotations, [
            CircleAnnotation(id: "1", point: Point(LocationCoordinate2D(latitude: 10, longitude: 10))),
            CircleAnnotation(id: "2", point: Point(LocationCoordinate2D(latitude: 20, longitude: 20)))
        ])
        XCTAssertEqual(orchestratorImpl.removeAnnotationManagerStub.invocations.map(\.parameters), [
            "circle-test"
        ])
        XCTAssertEqual(orchestratorImpl.makeCircleAnnotationManagerStub.invocations.map(\.parameters), [
            .init(id: "circle-test", layerPosition: .at(0)),
            .init(id: "circle-test", layerPosition: .at(0))
        ])
        XCTAssertEqual(locationManager.options, LocationOptions(
            puckType: .puck3D(Puck3DConfiguration(model: Model(), layerPosition: .above("circle-test"))),
            puckBearing: .heading,
            puckBearingEnabled: false
        ))

        component = MapContentFixture(id: "foo", route: route1, optional: "optional", condition: false)
        setContent { component }

        XCTAssertEqual(styleManager.addStyleLayerStub.invocations.count, 4)
        XCTAssertEqual(styleManager.addStyleLayerStub.invocations.last?.parameters.layerId, "optional")

        XCTAssertEqual(sourceManager.addSourceStub.invocations.count, 1)
        XCTAssertEqual(sourceManager.updateGeoJSONSourceStub.invocations.count, 0)
        XCTAssertEqual(viewAnnotationsManager.allAnnotations.count, 1)
        verifyAnnotationOptions(viewAnnotationsManager.allAnnotations.first, component.mapViewAnnotation)
        XCTAssertEqual(circleAnnotationManager.annotations, [
            CircleAnnotation(id: "1", point: Point(LocationCoordinate2D(latitude: 10, longitude: 10))),
            CircleAnnotation(id: "2", point: Point(LocationCoordinate2D(latitude: 20, longitude: 20)))
        ])
        XCTAssertEqual(orchestratorImpl.removeAnnotationManagerStub.invocations.map(\.parameters), [
            "circle-test",
            "circle-test"
        ])
        XCTAssertEqual(orchestratorImpl.makeCircleAnnotationManagerStub.invocations.map(\.parameters), [
            .init(id: "circle-test", layerPosition: .at(0)),
            .init(id: "circle-test", layerPosition: .at(0)),
            .init(id: "circle-test", layerPosition: .at(0))
        ])
        XCTAssertEqual(locationManager.options, LocationOptions(
            puckType: .puck3D(Puck3DConfiguration(model: Model(), layerPosition: .above("circle-test"))),
            puckBearing: .heading,
            puckBearingEnabled: false
        ))

        let route2 = MapContentFixture.Route(json: "bar")
        style.styleRootLoaded.toggle()
        style.styleRootLoaded.toggle()
        component = MapContentFixture(id: "foo", route: route2, optional: "optional", condition: false)

        setContent { component}

        XCTAssertEqual(sourceManager.addSourceStub.invocations.count, 1)
        XCTAssertEqual(sourceManager.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(sourceManager.updateGeoJSONSourceStub.invocations.last?.parameters.id, "route")
        XCTAssertEqual(sourceManager.updateGeoJSONSourceStub.invocations.last?.parameters.data, .string("bar"))

        XCTAssertEqual(styleManager.addStyleLayerStub.invocations.count, 4)
        XCTAssertEqual(styleManager.getStyleLayerPropertiesStub.invocations.count, 0)
        XCTAssertEqual(styleManager.removeStyleLayerStub.invocations.count, 1)
        XCTAssertEqual(viewAnnotationsManager.allAnnotations.count, 1)
        verifyAnnotationOptions(viewAnnotationsManager.allAnnotations.first, component.mapViewAnnotation)
        XCTAssertEqual(circleAnnotationManager.annotations, [
            CircleAnnotation(id: "1", point: Point(LocationCoordinate2D(latitude: 10, longitude: 10))),
            CircleAnnotation(id: "2", point: Point(LocationCoordinate2D(latitude: 20, longitude: 20)))
        ])
        XCTAssertEqual(orchestratorImpl.removeAnnotationManagerStub.invocations.map(\.parameters), [
            "circle-test",
            "circle-test",
            "circle-test"
        ])
        XCTAssertEqual(orchestratorImpl.makeCircleAnnotationManagerStub.invocations.map(\.parameters), [
            .init(id: "circle-test", layerPosition: .at(0)),
            .init(id: "circle-test", layerPosition: .at(0)),
            .init(id: "circle-test", layerPosition: .at(0)),
            .init(id: "circle-test", layerPosition: .at(0))
        ])
        XCTAssertEqual(locationManager.options, LocationOptions(
            puckType: .puck3D(Puck3DConfiguration(model: Model(), layerPosition: .above("circle-test"))),
            puckBearing: .heading,
            puckBearingEnabled: false
        ))

        setContent {}

        XCTAssertEqual(styleManager.addStyleLayerStub.invocations.count, 4)
        XCTAssertEqual(styleManager.removeStyleLayerStub.invocations.count, 4)
        XCTAssertEqual(sourceManager.removeSourceUncheckedStub.invocations.count, 1)
        XCTAssertEqual(sourceManager.removeSourceUncheckedStub.invocations.last?.parameters, "route")
        XCTAssertEqual(viewAnnotationsManager.allAnnotations.count, 0)
        XCTAssertEqual(orchestratorImpl.removeAnnotationManagerStub.invocations.map(\.parameters), [
            "circle-test",
            "circle-test",
            "circle-test",
            "circle-test"
        ])
        XCTAssertEqual(orchestratorImpl.makeCircleAnnotationManagerStub.invocations.map(\.parameters), [
            .init(id: "circle-test", layerPosition: .at(0)),
            .init(id: "circle-test", layerPosition: .at(0)),
            .init(id: "circle-test", layerPosition: .at(0)),
            .init(id: "circle-test", layerPosition: .at(0))
        ])
        XCTAssertEqual(locationManager.options, LocationOptions())

    }
}

@available(iOS 13.0, *)
func verifyAnnotationOptions(
    _ annotation: ViewAnnotation?,
    _ mapViewAnnotation: MapViewAnnotation
) {
    XCTAssertEqual(annotation?.annotatedFeature, mapViewAnnotation.annotatedFeature)
    XCTAssertEqual(annotation?.allowOverlap, mapViewAnnotation.allowOverlap)
    XCTAssertEqual(annotation?.visible, mapViewAnnotation.visible)
    XCTAssertEqual(annotation?.selected, mapViewAnnotation.selected)
    XCTAssertEqual(annotation?.variableAnchors, mapViewAnnotation.variableAnchors)
}
