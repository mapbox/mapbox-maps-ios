import Foundation
import XCTest
@testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private

final class StyleTests: XCTestCase {
    var mapClient: MockMapClient!
    var style: Style!
    var map: Map!

    override func setUpWithError() throws {
        mapClient = MockMapClient()
        map = Map(
            client: mapClient,
            mapOptions: MapOptions(),
            resourceOptions: MapboxCoreMaps.ResourceOptions(ResourceOptions(accessToken: "")))
        style = Style(with: map)
    }

    override func tearDown() {
        mapClient = nil
        style = nil
        map = nil
    }

    func testSetProjection() throws {
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").kind, .undefined)
        try style.setProjection(StyleProjection(name: .globe))
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").value as? String, "globe")
    }

    func testProjection() {
        // defaults to mercator if it's undefined
        XCTAssertEqual(style.styleManager.getStyleProjectionProperty(forProperty: "name").kind, .undefined)
        XCTAssertEqual(style.projection.name, .mercator)

        style.styleManager.setStyleProjectionForProperties(["name": "mercator"])
        XCTAssertEqual(style.projection.name, .mercator)

        style.styleManager.setStyleProjectionForProperties(["name": "globe"])
        XCTAssertEqual(style.projection.name, .globe)
    }

    func testStyleIsLoaded() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        let isStyleLoaded = Bool.random()
        mockStyleManager.isStyleLoadedStub.defaultReturnValue = isStyleLoaded
        XCTAssertEqual(sut.isLoaded, isStyleLoaded)
    }

    func testGetStyleURI() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        // Empty URI
        XCTAssertNil(sut.uri)

        // Valid URL
        mockStyleManager.getStyleURIStub.defaultReturnValue = "test://testStyle"
        XCTAssertNotNil(sut.uri)
    }

    func testSetStyleURI() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        // Invalid (nil) URI -> will not update StyleURI
        sut.uri = StyleURI(rawValue: "Not A Valid Style URL")
        XCTAssertNotEqual(sut.uri?.rawValue, "Not A Valid Style URL")

        // Valid URI
        sut.uri = StyleURI(rawValue: "test://newTestStyle")
        XCTAssertEqual(mockStyleManager.setStyleURIForUriStub.invocations.last!.parameters, "test://newTestStyle")
    }

    func testGetSetStyleJSON() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        mockStyleManager.getStyleJSONStub.defaultReturnValue = "{\"foo\":\"bar\"}"
        XCTAssertEqual(sut.JSON, "{\"foo\":\"bar\"}")

        sut.JSON = "{\"foo\":\"foo\"}"
        XCTAssertEqual(mockStyleManager.setStyleJSONForJsonStub.invocations.last?.parameters, "{\"foo\":\"foo\"}")
    }

    func testDefaultCamera() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        let stubCamera = MapboxMaps.CameraOptions.random()
        mockStyleManager.getStyleDefaultCameraStub.defaultReturnValue = MapboxCoreMaps.CameraOptions(stubCamera)

        XCTAssertEqual(sut.defaultCamera, stubCamera)
    }

    func testGetStyleTransition() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        let stubTransition = MapboxCoreMaps.TransitionOptions(
            duration: .random(in: 0...300),
            delay: .random(in: 0...300),
            enablePlacementTransitions: .random())
        mockStyleManager.getStyleTransitionStub.defaultReturnValue = stubTransition

        XCTAssertEqual(sut.transition, stubTransition)
    }

    func testSetStyleTransition() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        let stubTransition = MapboxCoreMaps.TransitionOptions(
            duration: .random(in: 0...300),
            delay: .random(in: 0...300),
            enablePlacementTransitions: .random())
        sut.transition = stubTransition

        XCTAssertEqual(mockStyleManager.setStyleTransitionStub.invocations.last?.parameters, stubTransition)
    }

    // MARK: Layer

    func testStyleLayerExistence() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        let layerID = String.randomAlphanumeric(withLength: 12)
        XCTAssertEqual(sut.layerExists(withId: layerID), mockStyleManager.styleLayerExists(forLayerId: layerID))
    }

    func testGetAllLayerIdentifiers() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        XCTAssertTrue(sut.allLayerIdentifiers.allSatisfy { layerInfo in
            mockStyleManager.getStyleLayers().contains(where: { $0.id == layerInfo.id && $0.type == layerInfo.type.rawValue })
        })
    }

    func testStyleCanAddLayer() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        XCTAssertThrowsError(try sut.addLayer(NonEncodableLayer()))

        mockStyleManager.addStyleLayerStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try sut.addLayer(with: ["foo": "bar"], layerPosition: .at(0)))

        mockStyleManager.addStyleLayerStub.defaultReturnValue = Expected(error: "Cannot add style layer")
        XCTAssertThrowsError(try sut.addLayer(with: ["foo": "bar"], layerPosition: .at(0)))
    }

    func testStyleCanAddPersistentLayer() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        XCTAssertThrowsError(try sut.addPersistentLayer(NonEncodableLayer(), layerPosition: .at(0)))

        mockStyleManager.addPersistentStyleLayerStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try sut.addPersistentLayer(with: ["foo": "bar"], layerPosition: .at(0)))

        mockStyleManager.addPersistentStyleLayerStub.defaultReturnValue = Expected(error: "Cannot add style layer")
        XCTAssertThrowsError(try sut.addPersistentLayer(with: ["foo": "bar"], layerPosition: .at(0)))
    }

    func testStyleGetLayerCanFail() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        mockStyleManager.getStyleLayerPropertiesStub.defaultReturnValue = Expected(error: "Cannot get layer properties")
        XCTAssertThrowsError(try sut.layer(withId: "dummy-style-id"))

        mockStyleManager.getStyleLayerPropertiesStub.defaultReturnValue = Expected(value: NSDictionary(dictionary: ["type": "Not a valid type"]))
        XCTAssertThrowsError(try sut.layer(withId: "dummy-style-id"))
    }

    // MARK: Source

    func testGetAllSourceIdentifiers() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        let stubbedStyleSources: [StyleObjectInfo] = .random(withLength: 3) {
            StyleObjectInfo(id: .randomAlphanumeric(withLength: 12), type: LayerType.random().rawValue)
        }
        mockStyleManager.getStyleSourcesStub.defaultReturnValue = stubbedStyleSources
        XCTAssertTrue(sut.allSourceIdentifiers.allSatisfy { sourceInfo in
            stubbedStyleSources.contains(where: { $0.id == sourceInfo.id && $0.type == sourceInfo.type.rawValue })
        })
    }

    func testStyleGetSourceCanFail() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        mockStyleManager.getStyleSourcePropertiesStub.defaultReturnValue = Expected(error: "Cannot get source properties")
        XCTAssertThrowsError(try sut.source(withId: "dummy-source-id"))

        mockStyleManager.getStyleSourcePropertiesStub.defaultReturnValue = Expected(value: NSDictionary(dictionary: ["type": "Not a valid type"]))
        XCTAssertThrowsError(try sut.source(withId: "dummy-source-id"))
    }

    func testStyleCanAddStyleSource() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        mockStyleManager.addStyleSourceStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try sut.addSource(withId: "dummy-source-id", properties: ["foo": "bar"]))

        mockStyleManager.addStyleSourceStub.defaultReturnValue = Expected(error: "Cannot add style source")
        XCTAssertThrowsError(try sut.addSource(withId: "dummy-source-id", properties: ["foo": "bar"]))
    }

    func testStyleCanRemoveSource() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        mockStyleManager.removeStyleSourceStub.defaultReturnValue = Expected(error: "Cannot remove source")
        XCTAssertThrowsError(try sut.removeSource(withId: "dummy-source-id"))

        mockStyleManager.removeStyleSourceStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try sut.removeSource(withId: "dummy-source-id"))
    }

    func testStyleCanCheckIfSourceExist() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        mockStyleManager.styleSourceExistsStub.defaultReturnValue = true
        XCTAssertTrue(sut.sourceExists(withId: "dummy-source-id"))
            mockStyleManager.styleSourceExistsStub.defaultReturnValue = false
        XCTAssertFalse(sut.sourceExists(withId: "non-exist-source-id"))
    }

    // MARK: Light

    func testStyleCanSetLightSourceProperties() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        mockStyleManager.setStyleLightForPropertiesStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try sut.setLight(properties: ["foo": "bar"]))

        mockStyleManager.setStyleLightForPropertiesStub.defaultReturnValue = Expected(error: "Cannot set light source properties")
        XCTAssertThrowsError(try sut.setLight(properties: ["foo": "bar"]))
    }

    // MARK: Terrain

    func testStyleCanSetTerrainSourceProperties() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        mockStyleManager.setStyleTerrainForPropertiesStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try sut.setTerrain(properties: ["foo": "bar"]))

        mockStyleManager.setStyleTerrainForPropertiesStub.defaultReturnValue = Expected(error: "Cannot set light source properties")
        XCTAssertThrowsError(try sut.setTerrain(properties: ["foo": "bar"]))
    }

    // MARK: Custom Geometry

    func testStyleCanAddCustomGeometrySource() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        let options = CustomGeometrySourceOptions(
            fetchTileFunction: { _ in },
            cancelTileFunction: { _ in },
            tileOptions: TileOptions(tolerance: 0, tileSize: 0, buffer: 0, clip: .random(), wrap: .random()))

        mockStyleManager.addStyleCustomGeometrySourceStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try sut.addCustomGeometrySource(withId: "dummy-custom-geometry-source-id", options: options))

        mockStyleManager.addStyleCustomGeometrySourceStub.defaultReturnValue = Expected(error: "Cannot add style custom geometry source")
        XCTAssertThrowsError(try sut.addCustomGeometrySource(withId: "dummy-custom-geometry-source-id", options: options))
    }

    func testStyleCanSetCustomGeometrySourceTileData() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        mockStyleManager.setStyleCustomGeometrySourceTileDataStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try sut.setCustomGeometrySourceTileData(
            forSourceId: "dummy-source-id",
            tileId: CanonicalTileID(z: 0, x: 0, y: 0),
            features: [])
        )

        mockStyleManager.setStyleCustomGeometrySourceTileDataStub.defaultReturnValue = Expected(error: "Cannot set custom geometry source tile data")
        XCTAssertThrowsError(try sut.setCustomGeometrySourceTileData(
            forSourceId: "dummy-source-id",
            tileId: CanonicalTileID(z: 0, x: 0, y: 0),
            features: [])
        )
    }

    func testStyleCanInvalidateCustomGeometrySourceTile() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        mockStyleManager.invalidateStyleCustomGeometrySourceTileStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try sut.invalidateCustomGeometrySourceTile(
            forSourceId: "dummy-source-id",
            tileId: CanonicalTileID(z: 0, x: 0, y: 0))
        )

        mockStyleManager.invalidateStyleCustomGeometrySourceTileStub.defaultReturnValue = Expected(error: "Cannot invalidate custom geometry source tile")
        XCTAssertThrowsError(try sut.invalidateCustomGeometrySourceTile(
            forSourceId: "dummy-source-id",
            tileId: CanonicalTileID(z: 0, x: 0, y: 0))
        )
    }

    func testStyleCanInvalidateCustomGeometrySourceRegion() {
        let mockStyleManager = MockStyleManager()
        let sut = Style(with: mockStyleManager)

        mockStyleManager.invalidateStyleCustomGeometrySourceRegionStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try sut.invalidateCustomGeometrySourceRegion(
            forSourceId: "dummy-source-id",
            bounds: CoordinateBounds(southwest: .random(), northeast: .random()))
        )

        mockStyleManager.invalidateStyleCustomGeometrySourceRegionStub.defaultReturnValue = Expected(error: "Cannot invalidate custom geometry source tile")
        XCTAssertThrowsError(try sut.invalidateCustomGeometrySourceRegion(
            forSourceId: "dummy-source-id",
            bounds: CoordinateBounds(southwest: .random(), northeast: .random()))
        )
    }
}
