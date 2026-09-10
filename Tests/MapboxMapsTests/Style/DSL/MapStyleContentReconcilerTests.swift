import XCTest
@_spi(Experimental) @_spi(Internal) @testable import MapboxMaps
import Combine
import SwiftUI

final class MapContentReconcilerTests: XCTestCase {
    var me: MapContentReconciler!
    var styleManager: MockStyleManager!
    var sourceManager: MockStyleSourceManager!
    var harness: AnnotationManagerTestingHarness!
    var style: MockStyle { harness.style }
    var annotationsOrchestrator: AnnotationOrchestrator!
    var viewAnnotationsManager: ViewAnnotationManager!
    var locationManager: LocationManager!
    var map: MockMapboxMap!
    var realMap: MapboxMap!
    var mapClient: MockMapClient!

    @TestPublished var styleIsLoaded = true

    override func setUp() {
        styleManager = MockStyleManager()
        sourceManager = MockStyleSourceManager()
        harness = AnnotationManagerTestingHarness()
        annotationsOrchestrator = AnnotationOrchestrator(deps: harness.makeDeps())
        map = MockMapboxMap()
        let mapSize = CGSize(width: 100, height: 100)
        mapClient = MockMapClient()
        mapClient.getMetalViewStub.defaultReturnValue = MetalView(frame: CGRect(origin: .zero, size: mapSize), device: nil)
        realMap = MapboxMap(
            map: CoreMap(client: mapClient, mapOptions: MapInitOptions(mapOptions: MapOptions(size: mapSize)).mapOptions),
            events: MapEvents(makeGenericSubject: { _ in .init() })
        )
        viewAnnotationsManager = ViewAnnotationManager(containerView: UIView(), mapboxMap: map, displayLink: Signal(just: ()))
        locationManager = LocationManager(
            interfaceOrientationView: Ref({ nil }),
            styleManager: style,
            mapboxMap: MockMapboxMap(),
            displayLink: Signal(just: ()),
            dataModel: LocationDataModel(location: Empty<[Location], Never>().eraseToAnyPublisher()),
            nowTimestamp: .now
        )
        styleIsLoaded = true

        me = MapContentReconciler(styleManager: styleManager, sourceManager: sourceManager, styleIsLoaded: $styleIsLoaded)
        me.setMapContentDependencies(MapContentDependencies(
            layerAnnotations: Ref.weakRef(self, property: \.annotationsOrchestrator),
            viewAnnotations: Ref.weakRef(self, property: \.viewAnnotationsManager),
            location: Ref.weakRef(self, property: \.locationManager),
            mapboxMap: Ref { [weak self] in self?.realMap },
            addAnnotationViewController: { _ in },
            removeAnnotationViewController: { _ in }
        ))
    }

    override func tearDown() {
        map = nil
        realMap = nil
        mapClient = nil
        me = nil
        sourceManager = nil
        styleManager = nil
        harness = nil
        annotationsOrchestrator = nil

        super.tearDown()
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

    func testForEveryDuplicatedIds() {
        styleManager.hasStyleModelStub.defaultReturnValue = true

        setContent {
            ForEvery([1, 2, 1], id: \.self) { id in
                Model(id: "test-id-\(id)", uri: .init(string: "test-URL-\(id)"))
            }
        }

        XCTAssertEqual(styleManager.addStyleModelStub.invocations.map(\.parameters.modelId), ["test-id-1", "test-id-2", "test-id-1"])
        XCTAssertEqual(styleManager.removeStyleModelStub.invocations.map(\.parameters.modelId), [])

        setContent {
            ForEvery([1, 2, 3], id: \.self) { id in
                Model(id: "test-id-\(id)", uri: .init(string: "test-URL-\(id)"))
            }
        }

        XCTAssertEqual(styleManager.addStyleModelStub.invocations.map(\.parameters.modelId), ["test-id-1", "test-id-2", "test-id-1", "test-id-3"])
        XCTAssertEqual(styleManager.removeStyleModelStub.invocations.map(\.parameters.modelId), [])
    }

    func testComponent() throws {
        sourceManager.sourceExistsStub.defaultReturnValue = true
        styleManager.styleLayerExistsStub.defaultReturnValue = true
        let route1 = MapContentFixture.Route(json: "foo")
        var component = MapContentFixture(id: "foo", route: route1, condition: true)

        setContent { component }

        XCTAssertEqual(styleManager.addStyleLayerStub.invocations.map(\.parameters.layerId), ["foo", "condition-true"])
        XCTAssertEqual(sourceManager.addSourceStub.invocations.map(\.parameters.source.id), ["route"])
        let addedSource = try XCTUnwrap(sourceManager.addSourceStub.invocations.last?.parameters.source) as? GeoJSONSource
        XCTAssertEqual(addedSource?.data, .string("foo"))
        XCTAssertEqual(viewAnnotationsManager.allAnnotations.count, 1)
        verifyAnnotationOptions(viewAnnotationsManager.allAnnotations.first, component.mapViewAnnotation)

        let manager = try XCTUnwrap( annotationsOrchestrator.annotationManagersById["circle-test"] as? CircleAnnotationManager)

        XCTAssertEqual(manager.annotations, [
            CircleAnnotation(id: "1", point: Point(LocationCoordinate2D(latitude: 10, longitude: 10))),
            CircleAnnotation(id: "2", point: Point(LocationCoordinate2D(latitude: 20, longitude: 20)))
        ])
        XCTAssertEqual(manager.impl.layerPosition, .at(0))

        XCTAssertEqual(locationManager.options, LocationOptions(
            puckType: .puck3D(Puck3DConfiguration(model: Model(id: "3d-puck"), layerPosition: .above("circle-test"))),
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

        let manager2 = try XCTUnwrap( annotationsOrchestrator.annotationManagersById["circle-test"] as? CircleAnnotationManager)
        XCTAssertIdentical(manager, manager2)

        XCTAssertEqual(manager2.annotations, [
            CircleAnnotation(id: "1", point: Point(LocationCoordinate2D(latitude: 10, longitude: 10))),
            CircleAnnotation(id: "2", point: Point(LocationCoordinate2D(latitude: 20, longitude: 20)))
        ])
        XCTAssertEqual(locationManager.options, LocationOptions(
            puckType: .puck3D(Puck3DConfiguration(model: Model(id: "3d-puck"), layerPosition: .above("circle-test"))),
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

        let route2 = MapContentFixture.Route(json: "bar")
        style.styleRootLoaded.toggle()
        style.styleRootLoaded.toggle()
        component = MapContentFixture(id: "foo", route: route2, optional: "optional", condition: false)

        setContent { component }

        XCTAssertEqual(sourceManager.addSourceStub.invocations.count, 1)
        XCTAssertEqual(sourceManager.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(sourceManager.updateGeoJSONSourceStub.invocations.last?.parameters.id, "route")
        XCTAssertEqual(sourceManager.updateGeoJSONSourceStub.invocations.last?.parameters.data, .string("bar"))

        XCTAssertEqual(styleManager.addStyleLayerStub.invocations.count, 4)
        XCTAssertEqual(styleManager.getStyleLayerPropertiesStub.invocations.count, 0)
        XCTAssertEqual(styleManager.removeStyleLayerStub.invocations.count, 1)
        XCTAssertEqual(viewAnnotationsManager.allAnnotations.count, 1)
        verifyAnnotationOptions(viewAnnotationsManager.allAnnotations.first, component.mapViewAnnotation)

        let manager3 = try XCTUnwrap( annotationsOrchestrator.annotationManagersById["circle-test"] as? CircleAnnotationManager)
        XCTAssertIdentical(manager2, manager3)

        XCTAssertEqual(locationManager.options, LocationOptions(
            puckType: .puck3D(Puck3DConfiguration(model: Model(id: "3d-puck"), layerPosition: .above("circle-test"))),
            puckBearing: .heading,
            puckBearingEnabled: false
        ))

        XCTAssertEqual(locationManager.options, LocationOptions(
            puckType: .puck3D(Puck3DConfiguration(model: Model(id: "3d-puck"), layerPosition: .above("circle-test"))),
            puckBearing: .heading,
            puckBearingEnabled: false
        ))

        setContent {}

        XCTAssertEqual(styleManager.addStyleLayerStub.invocations.count, 4)
        XCTAssertEqual(styleManager.removeStyleLayerStub.invocations.count, 4)
        XCTAssertEqual(sourceManager.removeSourceUncheckedStub.invocations.count, 1)
        XCTAssertEqual(sourceManager.removeSourceUncheckedStub.invocations.last?.parameters, "route")
        XCTAssertEqual(viewAnnotationsManager.allAnnotations.count, 0)

        XCTAssertEqual(annotationsOrchestrator.annotationManagersById.count, 0)
        XCTAssertEqual(locationManager.options, LocationOptions())

    }

    /// Before the style loads, assigning content must still evaluate its body (so SwiftUI registers
    /// `@State`/`@Binding` reads) while leaving the style untouched; on style load it's applied normally.
    func testFirstMountPrimesBodyWithoutTouchingStyle() {
        styleIsLoaded = false

        var bodyEvaluations = 0
        setContent {
            BodyCountingContent(onBody: { bodyEvaluations += 1 })
        }

        XCTAssertEqual(bodyEvaluations, 1, "priming walk must evaluate the body before the style loads")
        XCTAssertEqual(styleManager.addStyleLayerStub.invocations.count, 0, "priming must not touch the style")
        XCTAssertEqual(styleManager.addPersistentStyleLayerStub.invocations.count, 0, "priming must not touch the style")

        styleIsLoaded = true
        XCTAssertEqual(bodyEvaluations, 2, "style load walk applies the content")
        XCTAssertEqual(styleManager.addStyleLayerStub.invocations.count, 1)
    }

    /// Same, but the probe sits inside a `MapViewAnnotation` view closure — the priming walk must reach it
    /// too (the closure runs eagerly in `MapViewAnnotation.init` during the body walk).
    func testFirstMountPrimesViewAnnotationContent() {
        styleIsLoaded = false

        var contentEvaluations = 0
        setContent {
            AnnotationProbeContent(onContentEval: { contentEvaluations += 1 })
        }

        XCTAssertEqual(contentEvaluations, 1, "priming walk must evaluate the view annotation content closure")
    }

    /// SwiftUI counterpart of `testCollisionBoxesReportsCorrectFrameInUIKit`
    func testCollisionBoxesReportsCorrectFrameInSwiftUI() throws {
        @TestSignal var testDisplayLink: Signal<Void>
        let localViewAnnotationsManager = ViewAnnotationManager(containerView: UIView(), mapboxMap: map, displayLink: testDisplayLink)
        me.setMapContentDependencies(MapContentDependencies(
            layerAnnotations: Ref.weakRef(self, property: \.annotationsOrchestrator),
            viewAnnotations: Ref<ViewAnnotationManager?> { localViewAnnotationsManager },
            location: Ref.weakRef(self, property: \.locationManager),
            mapboxMap: Ref { [weak self] in self?.map },
            addAnnotationViewController: { _ in },
            removeAnnotationViewController: { _ in }
        ))

        setContent {
            MapViewAnnotation(coordinate: .init(latitude: 0, longitude: 0)) {
                VStack(spacing: 0) {
                    Color.red.frame(width: 30, height: 30)
                        .mbxViewAnnotationCollisionBox()
                    Color.blue.frame(width: 50, height: 20)
                }
                .fixedSize()
            }
        }

        let annotation = try XCTUnwrap(localViewAnnotationsManager.allAnnotations.first)

        // First snapshot, taken synchronously by ViewAnnotation.bind(): SwiftUI hasn't rendered yet.
        let addedOptions = try XCTUnwrap(map.addViewAnnotationStub.invocations.last).parameters.options
        XCTAssertNil(addedOptions.collisionBoxes)

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        let rootViewController = UIViewController()
        window.rootViewController = rootViewController
        rootViewController.view.addSubview(annotation.view)
        window.makeKeyAndVisible()
        annotation.view.frame = window.bounds
        annotation.view.layoutIfNeeded()

        // SwiftUI reports boxes asynchronously; wait for the value, not for a fixed delay.
        let boxesReported = expectation(description: "SwiftUI reported collision boxes")
        let poll = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            guard annotation.view.overrideCollisionBoxes != nil else { return }
            timer.invalidate()
            boxesReported.fulfill()
        }
        wait(for: [boxesReported], timeout: 5)
        poll.invalidate()

        $testDisplayLink.send()

        let updatedOptions = try XCTUnwrap(map.updateViewAnnotationStub.invocations.last).parameters.options
        XCTAssertEqual(updatedOptions.collisionBoxes?.first?.size, CGSize(width: 30, height: 30))
    }

    // MARK: - MapContentAttachment

    func testAttachmentAttachesOnceAndDetachesOnRemoval() {
        let spy = AttachmentSpy()

        setContent {
            CustomMapContent(attachment: spy)
        }

        XCTAssertEqual(spy.events, [.attached])
        XCTAssertIdentical(spy.attachedMap, realMap)

        setContent {}

        XCTAssertEqual(spy.events, [.attached, .detached])
    }

    func testAttachmentSurvivesContentUpdates() {
        let spy = AttachmentSpy()

        for _ in 0..<3 {
            setContent {
                CustomMapContent(attachment: spy)
                LineLayer(id: "line", source: "source")
            }
        }

        XCTAssertEqual(spy.events, [.attached])
    }

    func testAttachmentRetriesWhenNoMapIsAvailable() {
        let spy = AttachmentSpy()
        let map = realMap
        realMap = nil

        setContent {
            CustomMapContent(attachment: spy)
        }

        XCTAssertEqual(spy.events, [], "there is nothing to attach to yet")

        realMap = map
        setContent {
            CustomMapContent(attachment: spy)
        }

        // Identity alone would keep the failed mount, and the attachment would never get its map.
        XCTAssertEqual(spy.events, [.attached])
        XCTAssertIdentical(spy.attachedMap, realMap)
    }

    func testNestedAttachmentSurvivesSkippedUpdatesAndDetachesWithItsSubtree() {
        let spy = AttachmentSpy()

        setContent {
            AttachmentWrapper(attachment: spy)
        }
        // Unchanged parameters make the reconciler skip the wrapper's body: the attachment stays mounted.
        setContent {
            AttachmentWrapper(attachment: spy)
        }

        XCTAssertEqual(spy.events, [.attached])

        setContent {}

        XCTAssertEqual(spy.events, [.attached, .detached])
    }

    func testNestedAttachmentDetachesOnMapTeardown() {
        let spy = AttachmentSpy()

        setContent {
            AttachmentWrapper(attachment: spy)
        }

        me = nil

        XCTAssertEqual(spy.events, [.attached, .detached], "the teardown walk must reach nested attachments")
    }

    func testAttachmentDetachesWhenTheMapGoesAway() {
        let spy = AttachmentSpy()

        setContent {
            CustomMapContent(attachment: spy)
        }

        // Nothing unmounts the content tree on teardown, so the reconciler has to detach on its own.
        me = nil

        XCTAssertEqual(spy.events, [.attached, .detached])
    }

    func testReplacingAttachmentDetachesThePreviousOne() {
        let first = AttachmentSpy()
        let second = AttachmentSpy()

        setContent {
            CustomMapContent(attachment: first)
        }
        setContent {
            CustomMapContent(attachment: second)
        }

        XCTAssertEqual(first.events, [.attached, .detached])
        XCTAssertEqual(second.events, [.attached])
    }

    func testAttachmentWaitsForStyleLoad() {
        let spy = AttachmentSpy()
        styleIsLoaded = false

        setContent {
            CustomMapContent(attachment: spy)
        }

        XCTAssertEqual(spy.events, [], "the priming walk must not attach")

        styleIsLoaded = true

        XCTAssertEqual(spy.events, [.attached])
    }

    func testSameAttachmentTwiceInOneTreeAttachesOnce() {
        let spy = AttachmentSpy()

        setContent {
            CustomMapContent(attachment: spy)
            CustomMapContent(attachment: spy)
        }

        XCTAssertEqual(spy.events, [.attached], "the second mount must be refused")

        setContent {}

        XCTAssertEqual(spy.events, [.attached, .detached], "a refused mount has nothing to detach")
    }

    func testSameAttachmentInTwoMapsAttachesToTheFirstOnly() {
        let spy = AttachmentSpy()
        let other = makeOtherReconciler()

        setContent {
            CustomMapContent(attachment: spy)
        }
        other.content = CustomMapContent(attachment: spy)

        XCTAssertEqual(spy.events, [.attached])
        XCTAssertIdentical(spy.attachedMap, realMap)
    }

    func testRefusedAttachmentAttachesOnceTheFirstMountLetsGo() {
        let spy = AttachmentSpy()
        let other = makeOtherReconciler()

        setContent {
            CustomMapContent(attachment: spy)
        }
        other.content = CustomMapContent(attachment: spy)
        setContent {}

        XCTAssertEqual(spy.events, [.attached, .detached])

        // The refused mount is retried on the other map's next content walk.
        other.content = CustomMapContent(attachment: spy)

        XCTAssertEqual(spy.events, [.attached, .detached, .attached])
        XCTAssertIdentical(spy.attachedMap, realMap)
    }

    /// A second reconciler standing in for a second `Map`, sharing the same map instance for simplicity.
    private func makeOtherReconciler() -> MapContentReconciler {
        let other = MapContentReconciler(styleManager: MockStyleManager(), sourceManager: MockStyleSourceManager(), styleIsLoaded: $styleIsLoaded)
        other.setMapContentDependencies(MapContentDependencies(
            layerAnnotations: Ref.weakRef(self, property: \.annotationsOrchestrator),
            viewAnnotations: Ref.weakRef(self, property: \.viewAnnotationsManager),
            location: Ref.weakRef(self, property: \.locationManager),
            mapboxMap: Ref { [weak self] in self?.realMap },
            addAnnotationViewController: { _ in },
            removeAnnotationViewController: { _ in }
        ))
        return other
    }
}

private final class AttachmentSpy: MapContentAttachment {
    enum Event: Equatable {
        case attached
        case detached
    }

    private(set) var events: [Event] = []
    private(set) weak var attachedMap: MapboxMap?

    func attached(to map: MapboxMap) {
        events.append(.attached)
        attachedMap = map
    }

    func detached() {
        events.append(.detached)
    }
}

/// Stands in for the content type a consumer wraps around its own controller.
private struct AttachmentWrapper: MapContent {
    let attachment: any MapContentAttachment

    var body: some MapContent {
        CustomMapContent(attachment: attachment)
    }
}

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

/// Calls `onBody` every time its `body` is evaluated — lets tests count body evaluations.
private struct BodyCountingContent: MapContent {
    let onBody: () -> Void

    var body: some MapContent {
        LineLayer(id: countedId(), source: "bodyCountingSource")
    }

    private func countedId() -> String {
        onBody()
        return "bodyCounting"
    }
}

/// Calls `onContentEval` every time its view annotation content closure is evaluated.
private struct AnnotationProbeContent: MapContent {
    let onContentEval: () -> Void

    var body: some MapContent {
        MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)) {
            probeText()
        }
    }

    private func probeText() -> Text {
        onContentEval()
        return Text("probe")
    }
}
