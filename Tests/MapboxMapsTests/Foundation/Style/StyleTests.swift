import Foundation
import XCTest
@testable @_spi(Experimental) import MapboxMaps
@_implementationOnly import MapboxCommon_Private

final class StyleManagerTests: XCTestCase {
    var style: MapboxMaps.StyleManager!
    var styleManager: MockStyleManager!
    var sourceManager: MockStyleSourceManager!
    @TestSignal var onStyleLoaded: Signal<StyleDataLoaded>

    override func setUp() {
        styleManager = MockStyleManager()
        sourceManager = MockStyleSourceManager()
        style = StyleManager(with: styleManager, sourceManager: sourceManager)
    }

    override func tearDown() {
        resetAllStubs()
        styleManager = nil
        sourceManager = nil
        style = nil
    }

    func testSetProjection() throws {
        let projectionName = StyleProjectionName.random()
        let projection = StyleProjection(name: projectionName)

        try style.setProjection(projection)

        XCTAssertEqual(styleManager.setStyleProjectionPropertiesStub.invocations.count, 1)
        XCTAssertEqual(
            styleManager.setStyleProjectionPropertiesStub.invocations.first?.parameters as? [String: String],
            ["name": projectionName.rawValue]
        )
    }

    func testProjection() {
        let projectionName = StyleProjectionName.random()
        styleManager.getStyleProjectionPropertyStub.defaultReturnValue = StylePropertyValue(
            value: projectionName.rawValue,
            kind: .constant
        )

        XCTAssertEqual(style.projection?.name, projectionName)

        styleManager.getStyleProjectionPropertyStub.defaultReturnValue = StylePropertyValue(
            value: projectionName.rawValue,
            kind: .undefined
        )

        XCTAssertNil(style.projection?.name)
    }

    func testStyleIsLoaded() {
        let isStyleLoaded = Bool.random()
        styleManager.isStyleLoadedStub.defaultReturnValue = isStyleLoaded
        XCTAssertEqual(style.isStyleLoaded, isStyleLoaded)
    }

    func testGetStyleURI() {
        // Empty URI
        XCTAssertNil(style.styleURI)

        // Valid URL
        styleManager.getStyleURIStub.defaultReturnValue = "test://testStyle"
        XCTAssertNotNil(style.styleURI)
    }

    func testSetStyleURI() throws {
        styleManager.setStyleURIStub.defaultSideEffect = {
            self.styleManager.getStyleURIStub.defaultReturnValue = $0.parameters.value
        }
        // Invalid (nil) URI -> will not update StyleURI
        style.styleURI = StyleURI(rawValue: "Not A Valid Style URL")
        XCTAssertNotEqual(style.styleURI?.rawValue, "Not A Valid Style URL")

        // Valid URI
        let validURI = StyleURI(rawValue: "test://newTestStyle")
        style.styleURI = validURI
        let params = try XCTUnwrap(styleManager.setStyleURIStub.invocations.last).parameters
        XCTAssertEqual(params.value, validURI?.rawValue)
        XCTAssertEqual(style.styleURI, validURI)
    }

    func testGetSetStyleJSON() {
        styleManager.setStyleJSONStub.defaultSideEffect = {
            self.styleManager.getStyleJSONStub.defaultReturnValue = $0.parameters.value
        }

        let json = """
        {"foo": "bar"}
        """
        style.styleJSON = json
        XCTAssertEqual(style.styleJSON, json)
        XCTAssertEqual(styleManager.setStyleJSONStub.invocations.last?.parameters.value, json)
    }

    func testDefaultCamera() {
        let stubCamera = MapboxMaps.CameraOptions.random()
        styleManager.getStyleDefaultCameraStub.defaultReturnValue = CoreCameraOptions(stubCamera)

        XCTAssertEqual(style.styleDefaultCamera, stubCamera)
    }

    func testGetStyleTransition() {
        let stubTransition = TransitionOptions(
            duration: .random(in: 0...300),
            delay: .random(in: 0...300),
            enablePlacementTransitions: .random())
        styleManager.getStyleTransitionStub.defaultReturnValue = stubTransition.coreOptions

        XCTAssertEqual(style.styleTransition, stubTransition)
    }

    func testSetStyleTransition() throws {
        let stubTransition = TransitionOptions(
            duration: .random(in: 0...300),
            delay: .random(in: 0...300),
            enablePlacementTransitions: .random())
        style.styleTransition = stubTransition

        let coreTransitionOptions = try XCTUnwrap(styleManager.setStyleTransitionStub.invocations.last?.parameters)
        XCTAssertEqual(TransitionOptions(coreTransitionOptions), stubTransition)
    }

    // MARK: Layer

    func testStyleLayerExistence() {
        let layerID = String.randomAlphanumeric(withLength: 12)
        XCTAssertEqual(style.layerExists(withId: layerID), styleManager.styleLayerExists(forLayerId: layerID))
    }

    func testGetAllLayerIdentifiers() {
        XCTAssertTrue(style.allLayerIdentifiers.allSatisfy { layerInfo in
            styleManager.getStyleLayers().contains(where: { $0.id == layerInfo.id && $0.type == layerInfo.type.rawValue })
        })
    }

    func testStyleCanAddLayer() {
        XCTAssertThrowsError(try style.addLayer(NonEncodableLayer()))

        styleManager.addStyleLayerStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.addLayer(with: ["foo": "bar"], layerPosition: .at(0)))

        styleManager.addStyleLayerStub.defaultReturnValue = Expected(error: "Cannot add style layer")
        XCTAssertThrowsError(try style.addLayer(with: ["foo": "bar"], layerPosition: .at(0)))
    }

    func testStyleCanAddPersistentLayer() {
        XCTAssertThrowsError(try style.addPersistentLayer(NonEncodableLayer(), layerPosition: .at(0)))

        styleManager.addPersistentStyleLayerStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.addPersistentLayer(with: ["foo": "bar"], layerPosition: .at(0)))

        styleManager.addPersistentStyleLayerStub.defaultReturnValue = Expected(error: "Cannot add style layer")
        XCTAssertThrowsError(try style.addPersistentLayer(with: ["foo": "bar"], layerPosition: .at(0)))
    }

    func testStyleCanMoveLayer() {
        styleManager.moveStyleLayerStub.defaultReturnValue = .init(value: NSNull())
        XCTAssertNoThrow(try style.moveLayer(withId: "foo", to: .default))

        styleManager.moveStyleLayerStub.defaultReturnValue = .init(error: "Cannot move layer")
        XCTAssertThrowsError(try style.moveLayer(withId: "foo", to: .default))
    }

    func testStyleGetLayerCanFail() {
        styleManager.getStyleLayerPropertiesStub.defaultReturnValue = Expected(error: "Cannot get layer properties")
        XCTAssertThrowsError(try style.layer(withId: "dummy-style-id"))

        styleManager.getStyleLayerPropertiesStub.defaultReturnValue = Expected(value: NSDictionary(dictionary: ["type": "Not a valid type"]))
        XCTAssertThrowsError(try style.layer(withId: "dummy-style-id"))
    }

    // MARK: Source

    func testGetAllSourceIdentifiers() {
        let stubbedStyleSources: [SourceInfo] = .random(withLength: 3) {
            SourceInfo(id: .randomAlphanumeric(withLength: 12), type: .random())
        }
        sourceManager.$allSourceIdentifiers.getStub.defaultReturnValue = stubbedStyleSources

        let identifiers = style.allSourceIdentifiers

        XCTAssertEqual(sourceManager.$allSourceIdentifiers.getStub.invocations.count, 1)
        XCTAssertTrue(identifiers.allSatisfy { sourceInfo in
            stubbedStyleSources.contains(where: { $0.id == sourceInfo.id && $0.type == sourceInfo.type })
        })
    }

    func testStyleGetSource() throws {
        let id = "foo"
        let source = GeoJSONSource(id: id)
        sourceManager.sourceStub.defaultReturnValue = source

        let returnedSource = try style.source(withId: id)

        XCTAssertEqual(sourceManager.sourceStub.invocations.count, 1)
        XCTAssertEqual(sourceManager.sourceStub.invocations.first?.parameters, id)
        XCTAssertEqual(source.type, returnedSource.type)
    }

    func testStyleTypedGetSource() throws {
        let id = "foo"
        sourceManager.typedSourceStub.defaultReturnValue = GeoJSONSource(id: id)

        let source = try style.source(withId: id, type: GeoJSONSource.self)

        XCTAssertEqual(sourceManager.typedSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(sourceManager.typedSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.id, id)
        XCTAssertTrue(params.type is GeoJSONSource.Type)
        XCTAssertEqual(source.type, .geoJson)
    }

    func testStyleCanAddStyleSource() throws {
        let id = "dummy-source-id"
        let properties = ["foo": "bar"]

        try style.addSource(withId: id, properties: properties)

        XCTAssertEqual(sourceManager.addSourceUntypedStub.invocations.count, 1)
        let params = try XCTUnwrap(sourceManager.addSourceUntypedStub.invocations.first?.parameters)
        XCTAssertEqual(params.id, id)
        XCTAssertEqual(params.properties as? [String: String], properties)
    }

    func testStyleCanAddTypedStyleSource() throws {
        let id = "dummy-source-id"
        let type = SourceType.random()
        guard let source = try type.sourceType?.init(jsonObject: ["type": type.rawValue, "id": id]) else {
            XCTFail("Expected to return a valid source")
            return
        }

        try style.addSource(source)

        XCTAssertEqual(sourceManager.addSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(sourceManager.addSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.source.id, id)
        XCTAssertEqual(params.source.type, type)
    }

    func testStyleCanRemoveSource() throws {
        let id = "dummy-source-id"

        try style.removeSource(withId: id)

        XCTAssertEqual(sourceManager.removeSourceStub.invocations.count, 1)
        XCTAssertEqual(sourceManager.removeSourceStub.invocations.first?.parameters, id)
    }

    func testStyleCanCheckIfSourceExist() {
        let sourceExists = Bool.random()
        let id = String.randomASCII(withLength: 10)
        sourceManager.sourceExistsStub.defaultReturnValue = sourceExists

        let returnedSourceExists = style.sourceExists(withId: id)

        XCTAssertEqual(sourceManager.sourceExistsStub.invocations.count, 1)
        XCTAssertEqual(sourceManager.sourceExistsStub.invocations.first?.parameters, id)
        XCTAssertEqual(returnedSourceExists, sourceExists)
    }

    func testUpdateGeoJSONSource() throws {
        let id = String.randomASCII(withLength: 10)
        let geoJSONObject = GeoJSONObject.featureCollection(FeatureCollection(features: []))

        style.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject)

        XCTAssertEqual(sourceManager.updateGeoJSONSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(sourceManager.updateGeoJSONSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.id, id)
        XCTAssertEqual(params.data, geoJSONObject.sourceData)
    }

    func testUpdateGeoJSONSourceWithDataID() throws {
        let id = "TestSourceID"
        let geoJSONObject = GeoJSONObject.featureCollection(FeatureCollection(features: []))
        let dataId = "TestdataId"

        style.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject, dataId: dataId)

        XCTAssertEqual(sourceManager.updateGeoJSONSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(sourceManager.updateGeoJSONSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.id, id)
        let data = params.data
        let data2 = geoJSONObject.sourceData
        XCTAssertEqual(data, data2)
        XCTAssertEqual(params.dataId, dataId)
    }

    func testGetSourceProperty() throws {
        let id = String.randomASCII(withLength: 10)
        let property = String.randomASCII(withLength: 10)
        let value = StylePropertyValue(value: "foo", kind: .constant)
        sourceManager.sourcePropertyForStub.defaultReturnValue = value

        let returnedValue = style.sourceProperty(for: id, property: property)

        XCTAssertEqual(sourceManager.sourcePropertyForStub.invocations.count, 1)
        let params = try XCTUnwrap(sourceManager.sourcePropertyForStub.invocations.first?.parameters)
        XCTAssertEqual(params.sourceId, id)
        XCTAssertEqual(params.property, property)
        XCTAssertEqual(value, returnedValue)
    }

    func testGetSourceProperties() throws {
        let id = String.randomASCII(withLength: 10)
        let value = ["foo": "bar"]
        sourceManager.sourcePropertiesForStub.defaultReturnValue = value

        let returnedValue = try style.sourceProperties(for: id)

        XCTAssertEqual(sourceManager.sourcePropertiesForStub.invocations.count, 1)
        let returnedId = try XCTUnwrap(sourceManager.sourcePropertiesForStub.invocations.first?.parameters)
        XCTAssertEqual(returnedId, id)
        XCTAssertEqual(value, returnedValue as? [String: String])
    }

    func testSetSourceProperty() throws {
        let id = String.randomASCII(withLength: 19)
        let property = String.randomASCII(withLength: 19)
        let value = String.randomASCII(withLength: 19)

        try style.setSourceProperty(for: id, property: property, value: value)

        XCTAssertEqual(sourceManager.setSourcePropertyForParamsStub.invocations.count, 1)
        let params = try XCTUnwrap(sourceManager.setSourcePropertyForParamsStub.invocations.first?.parameters)
        XCTAssertEqual(params.sourceId, id)
        XCTAssertEqual(params.property, property)
        XCTAssertEqual(params.value as? String, value)
    }

    func testSetSourceProperties() throws {
        let id = String.randomASCII(withLength: 19)
        let properties = [String.randomASCII(withLength: 19): String.randomASCII(withLength: 19)]

        try style.setSourceProperties(for: id, properties: properties)

        XCTAssertEqual(sourceManager.setSourcePropertiesForParamsStub.invocations.count, 1)
        let params = try XCTUnwrap(sourceManager.setSourcePropertiesForParamsStub.invocations.first?.parameters)
        XCTAssertEqual(params.sourceId, id)
        XCTAssertEqual(params.properties as? [String: String], properties)
    }

    // MARK: Light

    func testStyleCanSetLightSourceProperties() {
        styleManager.setStyleLightPropertyForIdStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.setLightProperty(for: "id", property: "foo", value: "bar"))

        styleManager.setStyleLightPropertyForIdStub.defaultReturnValue = Expected(error: "Cannot set light source properties")
        XCTAssertThrowsError(try style.setLightProperty(for: "id", property: "foo", value: "bar"))
    }

    // MARK: Terrain

    func testStyleCanSetTerrainSourceProperties() {
        styleManager.setStyleTerrainForPropertiesStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.setTerrain(properties: ["foo": "bar"]))

        styleManager.setStyleTerrainForPropertiesStub.defaultReturnValue = Expected(error: "Cannot set terrain source properties")
        XCTAssertThrowsError(try style.setTerrain(properties: ["foo": "bar"]))
    }

    func testStyleCanSetTerrainSourceProperty() {
        styleManager.setStyleTerrainPropertyStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.setTerrainProperty("foo", value: "bar"))

        styleManager.setStyleTerrainPropertyStub.defaultReturnValue = Expected(error: "Cannot set terrain source property")
        XCTAssertThrowsError(try style.setTerrainProperty("foo", value: "bar"))
    }

    // MARK: Custom Geometry

    func testStyleCanAddCustomGeometrySource() {
        let options = CustomGeometrySourceOptions(
            fetchTileFunction: { _ in },
            cancelTileFunction: { _ in },
            tileOptions: TileOptions(tolerance: 0, tileSize: 0, buffer: 0, clip: .random(), wrap: .random()))

        styleManager.addStyleCustomGeometrySourceStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.addCustomGeometrySource(withId: "dummy-custom-geometry-source-id", options: options))

        styleManager.addStyleCustomGeometrySourceStub.defaultReturnValue = Expected(error: "Cannot add style custom geometry source")
        XCTAssertThrowsError(try style.addCustomGeometrySource(withId: "dummy-custom-geometry-source-id", options: options))
    }

    func testStyleCanSetCustomGeometrySourceTileData() {
        styleManager.setStyleCustomGeometrySourceTileDataStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.setCustomGeometrySourceTileData(
            forSourceId: "dummy-source-id",
            tileId: CanonicalTileID(z: 0, x: 0, y: 0),
            features: [])
        )

        styleManager.setStyleCustomGeometrySourceTileDataStub.defaultReturnValue = Expected(error: "Cannot set custom geometry source tile data")
        XCTAssertThrowsError(try style.setCustomGeometrySourceTileData(
            forSourceId: "dummy-source-id",
            tileId: CanonicalTileID(z: 0, x: 0, y: 0),
            features: [])
        )
    }

    func testStyleCanInvalidateCustomGeometrySourceTile() {
        styleManager.invalidateStyleCustomGeometrySourceTileStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.invalidateCustomGeometrySourceTile(
            forSourceId: "dummy-source-id",
            tileId: CanonicalTileID(z: 0, x: 0, y: 0))
        )

        styleManager.invalidateStyleCustomGeometrySourceTileStub.defaultReturnValue = Expected(error: "Cannot invalidate custom geometry source tile")
        XCTAssertThrowsError(try style.invalidateCustomGeometrySourceTile(
            forSourceId: "dummy-source-id",
            tileId: CanonicalTileID(z: 0, x: 0, y: 0))
        )
    }

    func testStyleCanInvalidateCustomGeometrySourceRegion() {
        styleManager.invalidateStyleCustomGeometrySourceRegionStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.invalidateCustomGeometrySourceRegion(
            forSourceId: "dummy-source-id",
            bounds: CoordinateBounds(southwest: .random(), northeast: .random()))
        )

        styleManager.invalidateStyleCustomGeometrySourceRegionStub.defaultReturnValue = Expected(error: "Cannot invalidate custom geometry source tile")
        XCTAssertThrowsError(try style.invalidateCustomGeometrySourceRegion(
            forSourceId: "dummy-source-id",
            bounds: CoordinateBounds(southwest: .random(), northeast: .random()))
        )
    }

    func testStyleCanAddCustomRasterSource() {
        let options = CustomRasterSourceOptions(
            clientCallback: CustomRasterSourceClient.fromCustomRasterSourceTileStatusChangedCallback { _, _ in }
        )

        styleManager.addStyleCustomRasterSourceStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.addCustomRasterSource(
            forSourceId: "dummy-source-id",
            options: options)
        )

        styleManager.addStyleCustomRasterSourceStub.defaultReturnValue = Expected(error: "Cannot add custom raster source")
        XCTAssertThrowsError(try style.addCustomRasterSource(
            forSourceId: "dummy-source-id",
            options: options)
        )
    }

    func testStyleCanSetCustomRasterSourceTileData() {
        styleManager.setStyleCustomRasterSourceTileDataStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.setCustomRasterSourceTileData(
            forSourceId: "dummy-source-id",
            tiles: [])
        )

        styleManager.setStyleCustomRasterSourceTileDataStub.defaultReturnValue = Expected(error: "Cannot set custom raster source tile data")
        XCTAssertThrowsError(try style.setCustomRasterSourceTileData(
            forSourceId: "dummy-source-id",
            tiles: [])
        )
    }

    func testStyleCanUpdateLayer() throws {
        styleManager.getStyleLayerPropertiesStub.defaultReturnValue = Expected(value: NSDictionary(dictionary: [
            "id": "dummy-layer-id",
            "type": "background",
            "minzoom": 1,
            "maxzoom": 10,
            "paint": [
                "background-opacity-transition": ["delay": 1, "duration": 100],
            ],
            "layout": [
                "visibility": "visible",
            ],
        ]))
        try style.updateLayer(
            withId: "dummy-layer-id",
            type: BackgroundLayer.self) { layer in
                layer.minZoom = nil
                layer.maxZoom = 12
                layer.backgroundOpacityTransition = nil
                layer.backgroundOpacity = nil
            }

        let rootProperties = try XCTUnwrap(styleManager.setStyleLayerPropertiesStub.invocations.last!.parameters.properties as? [String: Any])
        XCTAssertEqual(rootProperties["id"] as? String, "dummy-layer-id", "id should always be presented")
        XCTAssertTrue(rootProperties.keys.contains("minzoom"), "minzoom is reset and should be presented")
        XCTAssertEqual(rootProperties["maxzoom"] as? Double, 12, "maxzoom is updated and should be presented")

        let paintProperties = try XCTUnwrap(rootProperties["paint"] as? [String: Any])
        XCTAssertTrue(paintProperties.keys.contains("background-opacity-transition"), "background-opacity-transition is reset and should be presented")
        XCTAssertFalse(paintProperties.keys.contains("background-opacity"), "background-opacity is newly added and should be presented")

        let layoutProperties = try XCTUnwrap(rootProperties["layout"] as? [String: Any])
        XCTAssertEqual(layoutProperties["visibility"] as? String, "visible", "visibility is not reset and should keep old value")
    }

    func testAddImageWithStretches() throws {
        let image = UIImage.empty
        let id = UUID().uuidString
        let sdf = Bool.random()
        let stretchX = [ImageStretches(first: .random(in: 1...100), second: .random(in: 1...100))]
        let stretchY = [ImageStretches(first: .random(in: 1...100), second: .random(in: 1...100))]
        let content = ImageContent(
            left: .random(in: 1...100),
            top: .random(in: 1...100),
            right: .random(in: 1...100),
            bottom: .random(in: 1...100)
        )

        try style.addImage(image, id: id, sdf: sdf, stretchX: stretchX, stretchY: stretchY, content: content)

        XCTAssertEqual(styleManager.addStyleImageStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.addStyleImageStub.invocations.first?.parameters)
        XCTAssertEqual(params.imageId, id)
        XCTAssertEqual(params.sdf, sdf)
        XCTAssertEqual(params.stretchX, stretchX)
        XCTAssertEqual(params.stretchY, stretchY)
        XCTAssertEqual(params.content, content)
    }

    func testAddImageWithInsets() throws {
        let image = UIImage.empty
        let id = UUID().uuidString
        let sdf = Bool.random()
        let insets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 2)

        try style.addImage(image, id: id, sdf: sdf, contentInsets: insets)

        XCTAssertEqual(styleManager.addStyleImageStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.addStyleImageStub.invocations.first?.parameters)
        XCTAssertEqual(params.imageId, id)
        XCTAssertEqual(params.sdf, sdf)
        XCTAssertEqual(params.stretchX, [ImageStretches(first: 0, second: 1)])
        XCTAssertEqual(params.stretchY, [ImageStretches(first: 0, second: 1)])
    }

    func testSet3DLights() throws {
        let ambientLight = AmbientLight(id: UUID().uuidString)
        let directionalLight = DirectionalLight(id: UUID().uuidString)

        styleManager.setStyleLightsStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.setLights(ambient: ambientLight, directional: directionalLight))
        let lights = try XCTUnwrap(styleManager.setStyleLightsStub.invocations.last?.parameters as? [[String: Any]])
        XCTAssertTrue(lights.contains(where: { $0["id"] as? String == ambientLight.id && $0["type"] as? String == "ambient" }))
        XCTAssertTrue(lights.contains(where: { $0["id"] as? String == directionalLight.id && $0["type"] as? String == "directional" }))

        styleManager.setStyleLightsStub.reset()
        styleManager.setStyleLightsStub.defaultReturnValue = Expected(error: "Cannot add 3D lights")
        XCTAssertThrowsError(try style.setLights(ambient: ambientLight, directional: directionalLight))
    }

    func testGet3DLights() {
        styleManager.getStyleLightsStub.defaultReturnValue = [
            .init(id: "default-directional-light", type: "directional"),
            .init(id: "default-ambient-light", type: "ambient")
        ]
        let lights = style.allLightIdentifiers
        XCTAssertEqual(styleManager.getStyleLightsStub.invocations.count, 1)
        XCTAssertEqual(lights.map(\.id), ["default-directional-light", "default-ambient-light"])
    }

    func testSet3DLightProperty() throws {
        let id = UUID().uuidString
        let property = String.randomASCII(withLength: 19)
        let value = String.randomASCII(withLength: 19)

        styleManager.setStyleLightPropertyForIdStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.setLightProperty(for: id, property: property, value: value))
        let invocation = try XCTUnwrap(styleManager.setStyleLightPropertyForIdStub.invocations.last)
        XCTAssertEqual(invocation.parameters.id, id)
        XCTAssertEqual(invocation.parameters.property, property)
        XCTAssertEqual(invocation.parameters.value as? String, value)

        styleManager.setStyleLightPropertyForIdStub.defaultReturnValue = Expected(error: "Cannot set property for 3D light")
        XCTAssertThrowsError(try style.setLightProperty(for: id, property: property, value: value))
    }

    func testGet3DLightProperty() throws {
        let id = UUID().uuidString
        let property = String.randomASCII(withLength: 19)
        let stringValue = String.randomASCII(withLength: 19)

        styleManager.getStyleLightPropertyForIdStub.defaultReturnValue = .init(value: stringValue, kind: .constant)
        let propertyValue = style.lightProperty(for: id, property: property)
        let invocation = try XCTUnwrap(styleManager.getStyleLightPropertyForIdStub.invocations.last)
        XCTAssertEqual(invocation.parameters.id, id)
        XCTAssertEqual(invocation.parameters.property, property)
        XCTAssertEqual(propertyValue as? String, stringValue)
    }

    func testAddStyleModel() {
        let modelId = UUID().uuidString
        let modelUri = UUID().uuidString

        XCTAssertNoThrow(try style.addStyleModel(modelId: modelId, modelUri: modelUri))
        XCTAssertEqual(styleManager.addStyleModelStub.invocations.count, 1)
        XCTAssertEqual(styleManager.addStyleModelStub.invocations.first?.parameters.modelId, modelId)
        XCTAssertEqual(styleManager.addStyleModelStub.invocations.first?.parameters.modelUri, modelUri)
    }

    func testRemoveStyleModel() throws {
        let modelId = UUID().uuidString

        try style.removeStyleModel(modelId: modelId)
        XCTAssertEqual(styleManager.removeStyleModelStub.invocations.count, 1)
        XCTAssertEqual(styleManager.removeStyleModelStub.invocations.first?.parameters.modelId, modelId)
    }

    func testHasStyleModel() throws {
        let modelId = UUID().uuidString

        _ = style.hasStyleModel(modelId: modelId)
        XCTAssertEqual(styleManager.hasStyleModelStub.invocations.count, 1)
        XCTAssertEqual(styleManager.hasStyleModelStub.invocations.first?.parameters.modelId, modelId)
    }

    func testAddGeoJSONSourceFeatures() throws {
        // given
        let sourceId = String.randomASCII(withLength: 10)
        let dataId = String.randomASCII(withLength: 11)
        let point = Point(.random())
        let featureIdentifier = Double.random(in: 0...1000)
        var feature = Feature.init(geometry: point.geometry)
        feature.identifier = .number(featureIdentifier)

        // when
        style.addGeoJSONSourceFeatures(forSourceId: sourceId, features: [feature], dataId: dataId)

        // then
        XCTAssertEqual(sourceManager.addGeoJSONSourceFeaturesStub.invocations.count, 1)
        let parameters = try XCTUnwrap(sourceManager.addGeoJSONSourceFeaturesStub.invocations.first?.parameters)
        XCTAssertEqual(parameters.sourceId, sourceId)
        XCTAssertEqual(parameters.features, [feature])
        XCTAssertEqual(parameters.dataId, dataId)
    }

    func testUpdateGeoJSONSourceFeatures() throws {
        // given
        let sourceId = String.randomASCII(withLength: 10)
        let dataId = String.randomASCII(withLength: 11)
        let point = Point(.random())
        let featureIdentifier = Double.random(in: 0...1000)
        var feature = Feature.init(geometry: point.geometry)
        feature.identifier = .number(featureIdentifier)

        // when
        style.updateGeoJSONSourceFeatures(forSourceId: sourceId, features: [feature], dataId: dataId)

        // then
        XCTAssertEqual(sourceManager.updateGeoJSONSourceFeaturesStub.invocations.count, 1)
        let parameters = try XCTUnwrap(sourceManager.updateGeoJSONSourceFeaturesStub.invocations.first?.parameters)
        XCTAssertEqual(parameters.sourceId, sourceId)
        XCTAssertEqual(parameters.features, [feature])
        XCTAssertEqual(parameters.dataId, dataId)
    }

    func testRemoveGeoJSONSourceFeatures() throws {
        // given
        let sourceId = String.randomASCII(withLength: 10)
        let dataId = String.randomASCII(withLength: 11)
        let featureIdentifiers = (0...10).map { String.randomASCII(withLength: $0) }

        // when
        style.removeGeoJSONSourceFeatures(forSourceId: sourceId, featureIds: featureIdentifiers, dataId: dataId)

        // then
        XCTAssertEqual(sourceManager.removeGeoJSONSourceFeaturesStub.invocations.count, 1)
        let parameters = try XCTUnwrap(sourceManager.removeGeoJSONSourceFeaturesStub.invocations.first?.parameters)
        XCTAssertEqual(parameters.sourceId, sourceId)
        XCTAssertEqual(parameters.featureIds, featureIdentifiers)
        XCTAssertEqual(parameters.dataId, dataId)
    }

    // MARK: Style Imports
    func testGetStyleImports() {
        _ = style.styleImports
        XCTAssertEqual(styleManager.getStyleImportsStub.invocations.count, 1)
    }

    func testRemoveStyleImport() {
        let importId = UUID().uuidString

        try? style.removeStyleImport(withId: importId)
        XCTAssertEqual(styleManager.removeStyleImportStub.invocations.count, 1)
        XCTAssertEqual(styleManager.removeStyleImportStub.invocations.first?.parameters.importId, importId)
    }

    func testGetStyleImportSchema() {
        let importId = UUID().uuidString

        let importSchema = try? style.getStyleImportSchema(for: importId)
        XCTAssertEqual(styleManager.getStyleImportSchemaStub.invocations.count, 1)
        XCTAssertEqual(styleManager.getStyleImportSchemaStub.invocations.first?.parameters.importId, importId)
        XCTAssertEqual(importSchema as? NSDictionary, NSDictionary(dictionary: ["stub": "stub"]))
    }

    func testGetStyleImportConfigProperties() {
        let importId = UUID().uuidString

        let importConfigProperties = try? style.getStyleImportConfigProperties(for: importId)
        XCTAssertEqual(styleManager.getStyleImportConfigPropertiesStub.invocations.count, 1)
        XCTAssertEqual(styleManager.getStyleImportConfigPropertiesStub.invocations.first?.parameters.importId, importId)
        XCTAssertEqual(importConfigProperties?.first?.key, "stub")
        XCTAssertEqual(importConfigProperties?.first?.value.value as? String, "stub")
        XCTAssertEqual(importConfigProperties?.first?.value.kind, .undefined)
    }

    func testGetStyleImportConfigProperty() {
        let importId = UUID().uuidString
        let config = UUID().uuidString

        let importConfig = try? style.getStyleImportConfigProperty(for: importId, config: config)
        XCTAssertEqual(styleManager.getStyleImportConfigPropertyStub.invocations.count, 1)
        XCTAssertEqual(styleManager.getStyleImportConfigPropertyStub.invocations.first?.parameters.importId, importId)
        XCTAssertEqual(styleManager.getStyleImportConfigPropertyStub.invocations.first?.parameters.config, config)
        XCTAssertEqual(importConfig?.value as? String, "stub")
        XCTAssertEqual(importConfig?.kind, .undefined)
    }

    func testSetStyleImportConfigProperties() {
        let importId = UUID().uuidString
        let configs = [UUID().uuidString: UUID().uuidString]

        try? style.setStyleImportConfigProperties(for: importId, configs: configs)
        XCTAssertEqual(styleManager.setStyleImportConfigPropertiesForImportIdStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleImportConfigPropertiesForImportIdStub.invocations.first?.parameters.importId, importId)
        XCTAssertEqual(styleManager.setStyleImportConfigPropertiesForImportIdStub.invocations.first?.parameters.configs as? [String: String], configs)
    }

    func testSetStyleImportConfigProperty() {
        let importId = UUID().uuidString
        let config = UUID().uuidString
        let value = UUID().uuidString

        try? style.setStyleImportConfigProperty(for: importId, config: config, value: value)
        XCTAssertEqual(styleManager.setStyleImportConfigPropertyForImportIdStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleImportConfigPropertyForImportIdStub.invocations.first?.parameters.importId, importId)
        XCTAssertEqual(styleManager.setStyleImportConfigPropertyForImportIdStub.invocations.first?.parameters.config, config)
        XCTAssertEqual(styleManager.setStyleImportConfigPropertyForImportIdStub.invocations.first?.parameters.value as? String, value)
    }
}
