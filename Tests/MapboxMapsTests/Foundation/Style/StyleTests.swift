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
        style = Style(with: styleManager)
    }

    override func tearDown() {
        styleManager = nil
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
        let stubbedStyleSources: [StyleObjectInfo] = .random(withLength: 3) {
            StyleObjectInfo(id: .randomAlphanumeric(withLength: 12), type: LayerType.random().rawValue)
        }
        styleManager.getStyleSourcesStub.defaultReturnValue = stubbedStyleSources
        XCTAssertTrue(style.allSourceIdentifiers.allSatisfy { sourceInfo in
            stubbedStyleSources.contains(where: { $0.id == sourceInfo.id && $0.type == sourceInfo.type.rawValue })
        })
    }

    func testStyleGetSourceCanFail() {
        styleManager.getStyleSourcePropertiesStub.defaultReturnValue = Expected(error: "Cannot get source properties")
        XCTAssertThrowsError(try style.source(withId: "dummy-source-id"))

        styleManager.getStyleSourcePropertiesStub.defaultReturnValue = Expected(value: NSDictionary(dictionary: ["type": "Not a valid type"]))
        XCTAssertThrowsError(try style.source(withId: "dummy-source-id"))
    }

    func testStyleCanAddStyleSource() {
        styleManager.addStyleSourceStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.addSource(withId: "dummy-source-id", properties: ["foo": "bar"]))

        styleManager.addStyleSourceStub.defaultReturnValue = Expected(error: "Cannot add style source")
        XCTAssertThrowsError(try style.addSource(withId: "dummy-source-id", properties: ["foo": "bar"]))
    }

    func testStyleCanRemoveSource() {
        styleManager.removeStyleSourceStub.defaultReturnValue = Expected(error: "Cannot remove source")
        XCTAssertThrowsError(try style.removeSource(withId: "dummy-source-id"))

        styleManager.removeStyleSourceStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try style.removeSource(withId: "dummy-source-id"))
    }

    func testStyleCanCheckIfSourceExist() {
        styleManager.styleSourceExistsStub.defaultReturnValue = true
        XCTAssertTrue(style.sourceExists(withId: "dummy-source-id"))
            styleManager.styleSourceExistsStub.defaultReturnValue = false
        XCTAssertFalse(style.sourceExists(withId: "non-exist-source-id"))
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
