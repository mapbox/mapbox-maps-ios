import Foundation
@testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private

final class MockStyleManager: StyleManagerType, Stubbable {

    func asStyleManager() -> StyleManager {
        fatalError()
    }

    @Stubbed var stubStyleURI: String!
    func getStyleURI() -> String {
        stubStyleURI ?? ""
    }

    func setStyleURIForUri(_ uri: String) {
        stubStyleURI = uri
    }

    @Stubbed var stubStyleJSON: String!
    func getStyleJSON() -> String {
        stubStyleJSON
    }

    func setStyleJSONForJson(_ json: String) {
        stubStyleJSON = json
    }

    @Stubbed var stubDefaultCamera: MapboxCoreMaps.CameraOptions!
    func getStyleDefaultCamera() -> MapboxCoreMaps.CameraOptions {
        stubDefaultCamera
    }

    @Stubbed var stubStyleTransition: MapboxCoreMaps.TransitionOptions!
    func getStyleTransition() -> MapboxCoreMaps.TransitionOptions {
        stubStyleTransition
    }

    func setStyleTransitionFor(_ transitionOptions: MapboxCoreMaps.TransitionOptions) {
        stubStyleTransition = transitionOptions
    }

    // MARK: Style Layers

    @Stubbed var stubStyleLayers: [MapboxCoreMaps.StyleObjectInfo] = .random(withLength: 3) {
        MapboxCoreMaps.StyleObjectInfo(
            id: .randomAlphanumeric(withLength: 12),
            type: MapboxMaps.LayerType.random().rawValue)
    }
    func styleLayerExists(forLayerId layerId: String) -> Bool {
        stubStyleLayers.contains(where: { $0.id == layerId })
    }

    func getStyleLayers() -> [MapboxCoreMaps.StyleObjectInfo] {
        stubStyleLayers
    }

    func getStyleLayerProperty(
        forLayerId layerId: String,
        property: String
    ) -> MapboxCoreMaps.StylePropertyValue {

        if let stub = mockery.stub(of: MockStyleManager.getStyleLayerProperty(forLayerId:property:)) {
            return stub.call(with: self)(layerId, property)
        } else {
            return MapboxCoreMaps.StylePropertyValue(value: "foo", kind: .undefined)
        }
    }

    // MARK: Source Info

    @Stubbed var stubStyleSources: [StyleObjectInfo] = .random(withLength: 3) {
        MapboxCoreMaps.StyleObjectInfo(
            id: .randomAlphanumeric(withLength: 12),
            type: MapboxMaps.SourceType.random().rawValue)
    }
    func getStyleSourceProperty(forSourceId sourceId: String, property: String) -> MapboxCoreMaps.StylePropertyValue {
        if let stub = mockery.stub(of: MockStyleManager.getStyleSourceProperty(forSourceId:property:)) {
            return stub.call(with: self)(sourceId, property)
        } else {
            return MapboxCoreMaps.StylePropertyValue(value: "foo", kind: .undefined)
        }
    }

    func styleSourceExists(forSourceId sourceId: String) -> Bool {
        stubStyleSources.contains(where: { $0.id == sourceId })
    }

    func getStyleSources() -> [MapboxCoreMaps.StyleObjectInfo] {
        stubStyleSources
    }

    func getStyleLightProperty(forProperty property: String) -> MapboxCoreMaps.StylePropertyValue {
        if let stub = mockery.stub(of: MockStyleManager.getStyleLightProperty(forProperty:)) {
            return stub.call(with: self)(property)
        } else {
            return MapboxCoreMaps.StylePropertyValue(value: "foo", kind: .undefined)
        }
    }

    func getStyleTerrainProperty(forProperty property: String) -> MapboxCoreMaps.StylePropertyValue {
        if let stub = mockery.stub(of: MockStyleManager.getStyleTerrainProperty(forProperty:)) {
            return stub.call(with: self)(property)
        } else {
            return MapboxCoreMaps.StylePropertyValue(value: "foo", kind: .undefined)
        }
    }

    func getStyleProjectionProperty(forProperty property: String) -> MapboxCoreMaps.StylePropertyValue {
        if let stub = mockery.stub(of: MockStyleManager.getStyleProjectionProperty(forProperty:)) {
            return stub.call(with: self)(property)
        } else {
            return MapboxCoreMaps.StylePropertyValue(value: "foo", kind: .undefined)
        }
    }

    func getStyleImage(forImageId imageId: String) -> MapboxCoreMaps.Image? {
        let stub = mockery.stub(of: MockStyleManager.getStyleImage(forImageId:))
        return stub?.call(with: self)(imageId)
    }

    func hasStyleImage(forImageId imageId: String) -> Bool {
        getStyleImage(forImageId: imageId) != nil
    }

    func isStyleLoaded() -> Bool {
        let stub = mockery.stub(of: MockStyleManager.isStyleLoaded)
        return stub?.call(with: self)() ?? false
    }

    // MARK: Layers

    func addStyleLayer(
        forProperties properties: Any,
        layerPosition: MapboxCoreMaps.LayerPosition?
    ) -> Expected<NSNull, NSString> {

        if let stub = mockery.stub(of: MockStyleManager.addStyleLayer(forProperties:layerPosition:)) {
            return stub.call(with: self)(properties, layerPosition)
        } else {
            return Expected(value: NSNull())
        }
    }

    func addStyleCustomLayer(
        forLayerId layerId: String,
        layerHost: CustomLayerHost,
        layerPosition: MapboxCoreMaps.LayerPosition?
    ) -> Expected<NSNull, NSString> {

        let stub = mockery.stub(of: MockStyleManager.addStyleCustomLayer(forLayerId:layerHost:layerPosition:))!
        return stub.call(with: self)(layerId, layerHost, layerPosition)
    }

    @objc func addPersistentStyleLayer(
        forProperties properties: Any,
        layerPosition: MapboxCoreMaps.LayerPosition?
    ) -> Expected<NSNull, NSString> {

        if let stub = mockery.stub(of: MockStyleManager.addPersistentStyleLayer(forProperties:layerPosition:)) {
            return stub.call(with: self)(properties, layerPosition)
        } else {
            return Expected(value: NSNull())
        }
    }

    func addPersistentStyleCustomLayer(
        forLayerId layerId: String,
        layerHost: CustomLayerHost,
        layerPosition: MapboxCoreMaps.LayerPosition?
    ) -> Expected<NSNull, NSString> {

        let stub = mockery.stub(of: MockStyleManager.addPersistentStyleCustomLayer(forLayerId:layerHost:layerPosition:))!
        return stub.call(with: self)(layerId, layerHost, layerPosition)
    }

    func isStyleLayerPersistent(forLayerId layerId: String) -> Expected<NSNumber, NSString> {
        if let stub = mockery.stub(of: MockStyleManager.isStyleLayerPersistent(forLayerId:)) {
            return stub.call(with: self)(layerId)
        } else {
            return Expected(value: NSNumber(value: false))
        }
    }

    func removeStyleLayer(forLayerId layerId: String) -> Expected<NSNull, NSString> {
        if let stub = mockery.stub(of: MockStyleManager.removeStyleLayer(forLayerId:)) {
            return stub.call(with: self)(layerId)
        } else {
            return Expected(value: NSNull())
        }
    }

    func setStyleLayerPropertyForLayerId(_ layerId: String, property: String, value: Any) -> Expected<NSNull, NSString> {
        let stub = mockery.stub(of: MockStyleManager.setStyleLayerPropertyForLayerId(_:property:value:))!
        return stub.call(with: self)(layerId, property, value)
    }

    func getStyleLayerProperties(forLayerId layerId: String) -> Expected<AnyObject, NSString> {
        if let stub = mockery.stub(of: MockStyleManager.getStyleLayerProperties(forLayerId:)) {
            return stub.call(with: self)(layerId)
        } else {
            return Expected(value: NSDictionary(dictionary: ["foo": "bar"]))
        }
    }

    func setStyleLayerPropertiesForLayerId(_ layerId: String, properties: Any) -> Expected<NSNull, NSString> {
        let stub = mockery.stub(of: MockStyleManager.setStyleLayerPropertiesForLayerId(_:properties:))!
        return stub.call(with: self)(layerId, properties)
    }

    func addStyleSource(forSourceId sourceId: String, properties: Any) -> Expected<NSNull, NSString> {
        let stub = mockery.stub(of: MockStyleManager.addStyleSource(forSourceId:properties:))!
        return stub.call(with: self)(sourceId, properties)
    }

    func setStyleSourcePropertyForSourceId(_ sourceId: String, property: String, value: Any) -> Expected<NSNull, NSString> {
        let stub = mockery.stub(of: MockStyleManager.setStyleSourcePropertyForSourceId(_:property:value:))!
        return stub.call(with: self)(sourceId, property, value)
    }

    func getStyleSourceProperties(forSourceId sourceId: String) -> Expected<AnyObject, NSString> {
        let stub = mockery.stub(of: MockStyleManager.getStyleSourceProperties(forSourceId:))!
        return stub.call(with: self)(sourceId)
    }

    func setStyleSourcePropertiesForSourceId(_ sourceId: String, properties: Any) -> Expected<NSNull, NSString> {
        let stub = mockery.stub(of: MockStyleManager.setStyleSourcePropertiesForSourceId(_:properties:))!
        return stub.call(with: self)(sourceId, properties)
    }

    func updateStyleImageSourceImage(forSourceId sourceId: String, image: Image) -> Expected<NSNull, NSString> {
        let stub = mockery.stub(of: MockStyleManager.updateStyleImageSourceImage(forSourceId:image:))!
        return stub.call(with: self)(sourceId, image)
    }

    func removeStyleSource(forSourceId sourceId: String) -> Expected<NSNull, NSString> {
        let stub = mockery.stub(of: MockStyleManager.removeStyleSource(forSourceId:))!
        return stub.call(with: self)(sourceId)
    }

    func setStyleLightForProperties(_ properties: Any) -> Expected<NSNull, NSString> {
        let stub = mockery.stub(of: MockStyleManager.setStyleLightForProperties(_:))!
        return stub.call(with: self)(properties)
    }

    func setStyleLightPropertyForProperty(_ property: String, value: Any) -> Expected<NSNull, NSString> {
        let stub = mockery.stub(of: MockStyleManager.setStyleLightPropertyForProperty(_:value:))!
        return stub.call(with: self)(property, value)
    }

    func setStyleTerrainForProperties(_ properties: Any) -> Expected<NSNull, NSString> {
        let stub = mockery.stub(of: MockStyleManager.setStyleTerrainForProperties(_:))!
        return stub.call(with: self)(properties)
    }

    func setStyleTerrainPropertyForProperty(_ property: String, value: Any) -> Expected<NSNull, NSString> {
        let stub = mockery.stub(of: MockStyleManager.setStyleTerrainPropertyForProperty(_:value:))!
        return stub.call(with: self)(property, value)
    }

    func setStyleProjectionForProperties(_ properties: Any) -> Expected<NSNull, NSString> {
        let stub = mockery.stub(of: MockStyleManager.setStyleProjectionForProperties(_:))!
        return stub.call(with: self)(properties)
    }

    func setStyleProjectionPropertyForProperty(_ property: String, value: Any) -> Expected<NSNull, NSString> {
        let stub = mockery.stub(of: MockStyleManager.setStyleProjectionPropertyForProperty(_:value:))!
        return stub.call(with: self)(property, value)
    }

    // swiftlint:disable:next function_parameter_count
    func addStyleImage(
        forImageId imageId: String,
        scale: Float,
        image: Image,
        sdf: Bool,
        stretchX: [ImageStretches],
        stretchY: [ImageStretches],
        content: ImageContent?
    ) -> Expected<NSNull, NSString> {

        let stub = mockery.stub(of: MockStyleManager.addStyleImage(forImageId:scale:image:sdf:stretchX:stretchY:content:))!
        return stub.call(with: self)(imageId, scale, image, sdf, stretchX, stretchY, content)
    }

    func removeStyleImage(forImageId imageId: String) -> Expected<NSNull, NSString> {
        let stub = mockery.stub(of: MockStyleManager.removeStyleImage(forImageId:))!
        return stub.call(with: self)(imageId)
    }

    func addStyleCustomGeometrySource(
        forSourceId sourceId: String,
        options: CustomGeometrySourceOptions
    ) -> Expected<NSNull, NSString> {

        let stub = mockery.stub(of: MockStyleManager.addStyleCustomGeometrySource(forSourceId:options:))!
        return stub.call(with: self)(sourceId, options)
    }

    func setStyleCustomGeometrySourceTileDataForSourceId(
        _ sourceId: String,
        tileId: CanonicalTileID,
        featureCollection: [MapboxCommon.Feature]
    ) -> Expected<NSNull, NSString> {

        let stub = mockery.stub(of: MockStyleManager.setStyleCustomGeometrySourceTileDataForSourceId(_:tileId:featureCollection:))!
        return stub.call(with: self)(sourceId, tileId, featureCollection)
    }

    func invalidateStyleCustomGeometrySourceTile(
        forSourceId sourceId: String,
        tileId: CanonicalTileID
    ) -> Expected<NSNull, NSString> {

        let stub = mockery.stub(of: MockStyleManager.invalidateStyleCustomGeometrySourceTile(forSourceId:tileId:))!
        return stub.call(with: self)(sourceId, tileId)
    }

    @objc func invalidateStyleCustomGeometrySourceRegion(
        forSourceId sourceId: String,
        bounds: CoordinateBounds
    ) -> Expected<NSNull, NSString> {

        let stub = mockery.stub(of: MockStyleManager.invalidateStyleCustomGeometrySourceRegion(forSourceId:bounds:))!
        return stub.call(with: self)(sourceId, bounds)
    }
}

struct NonEncodableLayer: Layer {
    var id: String = "dummy-non-encodable-layer-id"
    var type: LayerType = .random()
    var filter: Expression?
    var source: String?
    var sourceLayer: String?
    var minZoom: Double?
    var maxZoom: Double?

    init() {}

    func encode(to encoder: Encoder) throws {
        throw MockError()
    }
}
