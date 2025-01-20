import Foundation
@_implementationOnly import MapboxCommon_Private

struct RuntimeStylingCallbacks {
    typealias Action = () -> Void
    var sources: Action?
    var layers: Action?
    var images: Action?
    var completed: Action?
    var cancelled: Action?
    var error: ((StyleError) -> Void)?
}

internal protocol StyleManagerProtocol {

    func getStyleURI() -> String
    func setStyleURIForUri(_ uri: String)

    func getStyleJSON() -> String
    func setStyleJSONForJson(_ json: String)

    func setStyleURI(_ uri: String, callbacks: RuntimeStylingCallbacks)
    func setStyleJSON(_ json: String, callbacks: RuntimeStylingCallbacks)

    func getStyleDefaultCamera() -> CoreCameraOptions

    func getStyleTransition() -> MapboxCoreMaps.TransitionOptions
    func setStyleTransitionFor(_ transitionOptions: MapboxCoreMaps.TransitionOptions)

    func getStyleImportSchema(forImportId importId: String) -> Expected<AnyObject, NSString>
    func getStyleImportConfigProperties(forImportId importId: String) -> Expected<NSDictionary, NSString>
    func getStyleImportConfigProperty(
        forImportId importId: String,
        config: String) -> Expected<MapboxCoreMaps.StylePropertyValue, NSString>
    func setStyleImportConfigPropertiesForImportId(_ importId: String, configs: [String: Any]) -> Expected<NSNull, NSString>
    func setStyleImportConfigPropertyForImportId(_  importId: String, config: String, value: Any) -> Expected<NSNull, NSString>

    func getStyleImports() -> [StyleObjectInfo]
    func addStyleImportFromJSON(forImportId: String, json: String, config: [String: Any]?, importPosition: CoreImportPosition?) -> Expected<NSNull, NSString>
    func addStyleImportFromURI(forImportId: String, uri: String, config: [String: Any]?, importPosition: CoreImportPosition?) -> Expected<NSNull, NSString>
    func updateStyleImportWithURI(forImportId: String, uri: String, config: [String: Any]?) -> Expected<NSNull, NSString>
    func updateStyleImportWithJSON(forImportId: String, json: String, config: [String: Any]?) -> Expected<NSNull, NSString>
    func moveStyleImport(forImportId: String, importPosition: CoreImportPosition?) -> Expected<NSNull, NSString>
    func removeStyleImport(forImportId importId: String) -> Expected<NSNull, NSString>

    func styleLayerExists(forLayerId layerId: String) -> Bool
    func getStyleLayers() -> [MapboxCoreMaps.StyleObjectInfo]
    func getStyleSlots() -> [String]

    func getStyleLayerProperty(forLayerId layerId: String, property: String) -> MapboxCoreMaps.StylePropertyValue

    func getStyleSourceProperty(forSourceId sourceId: String, property: String) -> MapboxCoreMaps.StylePropertyValue

    func styleSourceExists(forSourceId sourceId: String) -> Bool
    func getStyleSources() -> [MapboxCoreMaps.StyleObjectInfo]

    func getStyleTerrainProperty(forProperty property: String) -> MapboxCoreMaps.StylePropertyValue
    func getStyleProjectionProperty(forProperty property: String) -> MapboxCoreMaps.StylePropertyValue

    func getStyleImage(forImageId imageId: String) -> CoreMapsImage?
    func hasStyleImage(forImageId imageId: String) -> Bool

    func isStyleLoaded() -> Bool

    func addStyleLayer(
        forProperties properties: Any,
        layerPosition: CoreLayerPosition?) -> Expected<NSNull, NSString>

    func addStyleCustomLayer(
        forLayerId layerId: String,
        layerHost: CustomLayerHost, layerPosition: CoreLayerPosition?) -> Expected<NSNull, NSString>

    func addPersistentStyleLayer(
        forProperties properties: Any,
        layerPosition: CoreLayerPosition?) -> Expected<NSNull, NSString>

    func addPersistentStyleCustomLayer(
        forLayerId layerId: String,
        layerHost: CustomLayerHost,
        layerPosition: CoreLayerPosition?) -> Expected<NSNull, NSString>

    func isStyleLayerPersistent(forLayerId layerId: String) -> Expected<NSNumber, NSString>

    func removeStyleLayer(forLayerId layerId: String) -> Expected<NSNull, NSString>
    func moveStyleLayer(
        forLayerId layerId: String,
        layerPosition: CoreLayerPosition?
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
        image: CoreMapsImage) -> Expected<NSNull, NSString>

    func removeStyleSource(forSourceId sourceId: String) -> Expected<NSNull, NSString>
    func removeStyleSourceUnchecked(forSourceId sourceId: String) -> Expected<NSNull, NSString>

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

    // Snow
    func setStyleSnowForProperties(_ properties: Any) -> Expected<NSNull, NSString>
    func getStyleSnowProperty(forProperty: String) -> StylePropertyValue

    // Rain
    func setStyleRainForProperties(_ properties: Any) -> Expected<NSNull, NSString>
    func getStyleRainProperty(forProperty: String) -> StylePropertyValue

    // Style Model API
    func addStyleModel(forModelId modelId: String, modelUri: String) -> Expected<NSNull, NSString>
    func removeStyleModel(forModelId modelId: String) -> Expected<NSNull, NSString>
    func hasStyleModel(forModelId modelId: String) -> Bool

    // swiftlint:disable:next function_parameter_count
    func addStyleImage(
        forImageId imageId: String,
        scale: Float,
        image: CoreMapsImage,
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

    func addStyleCustomRasterSource(
        forSourceId: String,
        options: CustomRasterSourceOptions) -> Expected<NSNull, NSString>

    func setStyleCustomRasterSourceTileDataForSourceId(
        _ sourceId: String,
        tiles: [CoreCustomRasterSourceTileData]) -> Expected<NSNull, NSString>

    func __setStyleGeoJSONSourceDataForSourceId(
        _ sourceId: String,
        dataId: String,
        data: CoreGeoJSONSourceData
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

    func getStyleFeaturesets() -> [CoreFeaturesetDescriptor]

    func setStyleColorThemeFor(_ colorTheme: CoreColorTheme?) -> Expected<NSNull, NSString>
    func setInitialStyleColorTheme()
}

// MARK: Conformance

extension CoreStyleManager: StyleManagerProtocol {
    func setStyleURI(_ uri: String, callbacks: RuntimeStylingCallbacks) {
        load(style: uri, isJson: false, callbacks: callbacks)
    }

    func setStyleJSON(_ json: String, callbacks: RuntimeStylingCallbacks) {
        load(style: json, isJson: true, callbacks: callbacks)
    }

    private func load(style: String, isJson: Bool, callbacks: RuntimeStylingCallbacks) {

        var errorToken: Cancelable?
        errorToken = subscribe(forMapLoadingError: { error in
            if error.type == .style {
                errorToken?.cancel()
                callbacks.error?(StyleError(message: error.message))
            }
        })
        let options = CoreRuntimeStylingOptions(
            sourcesCallback: { _ in callbacks.sources?() },
            layersCallback: { _ in callbacks.layers?() },
            imagesCallback: { _ in callbacks.images?() },
            completedCallback: { _ in
                errorToken?.cancel()
                callbacks.completed?() },
            canceledCallback: { _ in
                errorToken?.cancel()
                callbacks.cancelled?()
            },
            errorCallback: nil)
        if isJson {
            setStyleJSONForJson(style, stylingOptions: options)
        } else {
            setStyleURIForUri(style, stylingOptions: options)
        }
    }
}
