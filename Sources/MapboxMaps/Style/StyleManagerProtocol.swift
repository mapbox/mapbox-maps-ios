import Foundation
@_implementationOnly import MapboxCommon_Private
@_implementationOnly import MapboxCoreMaps_Private

internal protocol StyleManagerProtocol {

    func getStyleURI() -> String
    func setStyleURIForUri(_ uri: String)

    func getStyleJSON() -> String
    func setStyleJSONForJson(_ json: String)

    func getStyleDefaultCamera() -> MapboxCoreMaps.CameraOptions

    func getStyleTransition() -> MapboxCoreMaps.TransitionOptions
    func setStyleTransitionFor(_ transitionOptions: MapboxCoreMaps.TransitionOptions)

    func getStyleImports() -> [StyleObjectInfo]
    func removeStyleImport(forImportId importId: String) -> Expected<NSNull, NSString>
    func getStyleImportSchema(forImportId importId: String) -> Expected<AnyObject, NSString>
    func getStyleImportConfigProperties(forImportId importId: String) -> Expected<NSDictionary, NSString>
    func getStyleImportConfigProperty(
        forImportId importId: String,
        config: String) -> Expected<MapboxCoreMaps.StylePropertyValue, NSString>
    func setStyleImportConfigPropertiesForImportId(_ importId: String, configs: [String: Any]) -> Expected<NSNull, NSString>
    func setStyleImportConfigPropertyForImportId(_  importId: String, config: String, value: Any) -> Expected<NSNull, NSString>

    func styleLayerExists(forLayerId layerId: String) -> Bool
    func getStyleLayers() -> [MapboxCoreMaps.StyleObjectInfo]

    func getStyleLayerProperty(forLayerId layerId: String, property: String) -> MapboxCoreMaps.StylePropertyValue

    func getStyleSourceProperty(forSourceId sourceId: String, property: String) -> MapboxCoreMaps.StylePropertyValue

    func styleSourceExists(forSourceId sourceId: String) -> Bool
    func getStyleSources() -> [MapboxCoreMaps.StyleObjectInfo]

    func getStyleTerrainProperty(forProperty property: String) -> MapboxCoreMaps.StylePropertyValue
    func getStyleProjectionProperty(forProperty property: String) -> MapboxCoreMaps.StylePropertyValue

    func getStyleImage(forImageId imageId: String) -> MapboxCoreMaps.Image?
    func hasStyleImage(forImageId imageId: String) -> Bool

    func isStyleLoaded() -> Bool

    func addStyleLayer(
        forProperties properties: Any,
        layerPosition: MapboxCoreMaps.LayerPosition?) -> Expected<NSNull, NSString>

    func addStyleCustomLayer(
        forLayerId layerId: String,
        layerHost: CustomLayerHost, layerPosition: MapboxCoreMaps.LayerPosition?) -> Expected<NSNull, NSString>

    func addPersistentStyleLayer(
        forProperties properties: Any,
        layerPosition: MapboxCoreMaps.LayerPosition?) -> Expected<NSNull, NSString>

    func addPersistentStyleCustomLayer(
        forLayerId layerId: String,
        layerHost: CustomLayerHost,
        layerPosition: MapboxCoreMaps.LayerPosition?) -> Expected<NSNull, NSString>

    func isStyleLayerPersistent(forLayerId layerId: String) -> Expected<NSNumber, NSString>

    func removeStyleLayer(forLayerId layerId: String) -> Expected<NSNull, NSString>
    func moveStyleLayer(
        forLayerId layerId: String,
        layerPosition: MapboxCoreMaps.LayerPosition?
    ) -> Expected<NSNull, NSString>

    func setStyleLayerPropertyForLayerId(
        _ layerId: String,
        property: String,
        value: Any) -> Expected<NSNull, NSString>

    func getStyleLayerProperties(forLayerId layerId: String) -> Expected<AnyObject, NSString>

    func setStyleLayerPropertiesForLayerId(
        _ layerId: String,
        properties: Any) -> Expected<NSNull, NSString>

    func addStyleSource(
        forSourceId sourceId: String,
        properties: Any) -> Expected<NSNull, NSString>

    func setStyleSourcePropertyForSourceId(
        _ sourceId: String,
        property: String,
        value: Any) -> Expected<NSNull, NSString>

    func getStyleSourceProperties(forSourceId sourceId: String) -> Expected<AnyObject, NSString>

    func setStyleSourcePropertiesForSourceId(
        _ sourceId: String,
        properties: Any) -> Expected<NSNull, NSString>

    func updateStyleImageSourceImage(
        forSourceId sourceId: String,
        image: Image) -> Expected<NSNull, NSString>

    func removeStyleSource(forSourceId sourceId: String) -> Expected<NSNull, NSString>

    // 3D Light
    func getStyleLights() -> [StyleObjectInfo]
    func setStyleLightsForLights(_ lights: Any) -> Expected<NSNull, NSString>
    func getStyleLightProperty(forId id: String, property: String) -> StylePropertyValue
    func setStyleLightPropertyForId(_ id: String, property: String, value: Any) -> Expected<NSNull, NSString>

    @discardableResult
    func setStyleTerrainForProperties(_ properties: Any) -> Expected<NSNull, NSString>

    func setStyleTerrainPropertyForProperty(
        _ property: String,
        value: Any) -> Expected<NSNull, NSString>

    func setStyleProjectionForProperties(_ properties: Any) -> Expected<NSNull, NSString>

    func setStyleProjectionPropertyForProperty(
        _ property: String,
        value: Any) -> Expected<NSNull, NSString>

    // Style Model API
    func addStyleModel(forModelId modelId: String, modelUri: String) -> Expected<NSNull, NSString>
    func removeStyleModel(forModelId modelId: String) -> Expected<NSNull, NSString>
    func hasStyleModel(forModelId modelId: String) -> Bool

    // swiftlint:disable:next function_parameter_count
    func addStyleImage(
        forImageId imageId: String,
        scale: Float,
        image: Image,
        sdf: Bool,
        stretchX: [ImageStretches],
        stretchY: [ImageStretches],
        content: ImageContent?) -> Expected<NSNull, NSString>

    func removeStyleImage(forImageId imageId: String) -> Expected<NSNull, NSString>

    func addStyleCustomGeometrySource(
        forSourceId sourceId: String,
        options: CustomGeometrySourceOptions) -> Expected<NSNull, NSString>

    func setStyleCustomGeometrySourceTileDataForSourceId(
        _ sourceId: String,
        tileId: CanonicalTileID,
        featureCollection: [MapboxCommon.Feature]) -> Expected<NSNull, NSString>

    func invalidateStyleCustomGeometrySourceTile(
        forSourceId sourceId: String,
        tileId: CanonicalTileID) -> Expected<NSNull, NSString>

    func invalidateStyleCustomGeometrySourceRegion(
        forSourceId sourceId: String,
        bounds: CoordinateBounds) -> Expected<NSNull, NSString>

    func __setStyleGeoJSONSourceDataForSourceId(
        _ sourceId: String,
        dataId: String,
        data: MapboxCoreMaps.GeoJSONSourceData
    ) -> Expected<NSNull, NSString>

    func setStyleAtmosphereForProperties(_ properties: Any) -> Expected<NSNull, NSString>

    func setStyleAtmospherePropertyForProperty(_ property: String, value: Any) -> Expected<NSNull, NSString>

    func getStyleAtmosphereProperty(forProperty: String) -> StylePropertyValue
    func addGeoJSONSourceFeatures(forSourceId sourceId: String,
                                  dataId: String,
                                  features: [MapboxCommon.Feature]) -> Expected<NSNull, NSString>
    func updateGeoJSONSourceFeatures(forSourceId sourceId: String,
                                     dataId: String,
                                     features: [MapboxCommon.Feature]) -> Expected<NSNull, NSString>
    func removeGeoJSONSourceFeatures(forSourceId sourceId: String,
                                     dataId: String,
                                     featureIds: [String]) -> Expected<NSNull, NSString>
}

// MARK: Conformance

extension MapboxCoreMaps.StyleManager: StyleManagerProtocol {}
