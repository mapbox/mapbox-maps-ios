import Foundation
import XCTest
@testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private

final class StyleTests: XCTestCase {
    var style: Style!
    var styleManager: MockStyleManager!
    var sourceManager: MockStyleSourceManager!

    override func setUp() {
        styleManager = MockStyleManager()
        sourceManager = MockStyleSourceManager()
        style = Style(with: styleManager, sourceManager: sourceManager)
    }

    override func tearDown() {
        styleManager = nil
        sourceManager = nil
        style = nil
    }

    func testSetProjection() throws {
        let projectionName = StyleProjectionName.allCases.randomElement()!

        try style.setProjection(StyleProjection(name: projectionName))

        XCTAssertEqual(styleManager.setStyleProjectionPropertyStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleProjectionPropertyStub.invocations.first?.parameters.property, "name")
        XCTAssertEqual(styleManager.setStyleProjectionPropertyStub.invocations.first?.parameters.value as? String, projectionName.rawValue)
    }

    func testProjection() {
        let projectionName = StyleProjectionName.allCases.randomElement()!
        styleManager.getStyleProjectionPropertyStub.defaultReturnValue = StylePropertyValue(
            value: projectionName.rawValue,
            kind: .constant
        )

        XCTAssertEqual(style.projection.name, projectionName)

        styleManager.getStyleProjectionPropertyStub.defaultReturnValue = StylePropertyValue(
            value: projectionName.rawValue,
            kind: .undefined
        )

        XCTAssertEqual(style.projection.name, .mercator)
    }

    func testStyleIsLoaded() {
        let isStyleLoaded = Bool.random()
        styleManager.isStyleLoadedStub.defaultReturnValue = isStyleLoaded
        XCTAssertEqual(style.isLoaded, isStyleLoaded)
    }

    func testGetStyleURI() {
        // Empty URI
        XCTAssertNil(style.uri)

        // Valid URL
        styleManager.getStyleURIStub.defaultReturnValue = "test://testStyle"
        XCTAssertNotNil(style.uri)
    }

    func testSetStyleURI() {
        // Invalid (nil) URI -> will not update StyleURI
        style.uri = StyleURI(rawValue: "Not A Valid Style URL")
        XCTAssertNotEqual(style.uri?.rawValue, "Not A Valid Style URL")

        // Valid URI
        style.uri = StyleURI(rawValue: "test://newTestStyle")
        XCTAssertEqual(styleManager.setStyleURIForUriStub.invocations.last!.parameters, "test://newTestStyle")
    }

    func testGetSetStyleJSON() {
        styleManager.getStyleJSONStub.defaultReturnValue = "{\"foo\":\"bar\"}"
        XCTAssertEqual(style.JSON, "{\"foo\":\"bar\"}")

        style.JSON = "{\"foo\":\"foo\"}"
        XCTAssertEqual(styleManager.setStyleJSONForJsonStub.invocations.last?.parameters, "{\"foo\":\"foo\"}")
    }

    func testDefaultCamera() {
        let stubCamera = MapboxMaps.CameraOptions.random()
        styleManager.getStyleDefaultCameraStub.defaultReturnValue = MapboxCoreMaps.CameraOptions(stubCamera)

        XCTAssertEqual(style.defaultCamera, stubCamera)
    }

    func testGetStyleTransition() {
        let stubTransition = MapboxCoreMaps.TransitionOptions(
            duration: .random(in: 0...300),
            delay: .random(in: 0...300),
            enablePlacementTransitions: .random())
        styleManager.getStyleTransitionStub.defaultReturnValue = stubTransition

        XCTAssertEqual(style.transition, stubTransition)
    }

    func testSetStyleTransition() {
        let stubTransition = MapboxCoreMaps.TransitionOptions(
            duration: .random(in: 0...300),
            delay: .random(in: 0...300),
            enablePlacementTransitions: .random())
        style.transition = stubTransition

        XCTAssertEqual(styleManager.setStyleTransitionStub.invocations.last?.parameters, stubTransition)
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
        let source = GeoJSONSource()
        sourceManager.sourceStub.defaultReturnValue = source

        let returnedSource = try style.source(withId: id)

        XCTAssertEqual(sourceManager.sourceStub.invocations.count, 1)
        XCTAssertEqual(sourceManager.sourceStub.invocations.first?.parameters, id)
        XCTAssertEqual(source.type, returnedSource.type)
    }

    func testStyleTypedGetSource() throws {
        let id = "foo"
        sourceManager.typedSourceStub.defaultReturnValue = GeoJSONSource()

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
        let source = try type.sourceType.init(jsonObject: ["type": type.rawValue])

        try style.addSource(source, id: id)

        XCTAssertEqual(sourceManager.addSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(sourceManager.addSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.id, id)
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

        try style.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject)

        XCTAssertEqual(sourceManager.updateGeoJSONSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(sourceManager.updateGeoJSONSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.id, id)
        XCTAssertEqual(params.geoJSON, geoJSONObject)
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
        styleManager.setStyleLightForPropertiesStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.setLight(properties: ["foo": "bar"]))

        styleManager.setStyleLightForPropertiesStub.defaultReturnValue = Expected(error: "Cannot set light source properties")
        XCTAssertThrowsError(try style.setLight(properties: ["foo": "bar"]))
    }

    // MARK: Terrain

    func testStyleCanSetTerrainSourceProperties() {
        styleManager.setStyleTerrainForPropertiesStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.setTerrain(properties: ["foo": "bar"]))

        styleManager.setStyleTerrainForPropertiesStub.defaultReturnValue = Expected(error: "Cannot set light source properties")
        XCTAssertThrowsError(try style.setTerrain(properties: ["foo": "bar"]))
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
}
