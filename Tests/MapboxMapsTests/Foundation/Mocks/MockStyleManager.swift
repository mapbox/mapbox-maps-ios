import Foundation
@testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private

class MockStyleManager: StyleManagerProtocol {
    struct LoadStyleParams {
        var value: String
        var callbacks: RuntimeStylingCallbacks
    }
    var setStyleURIStub = Stub<LoadStyleParams, Void>()
    func setStyleURI(_ uri: String, callbacks: RuntimeStylingCallbacks) {
        setStyleURIStub.call(with: .init(value: uri, callbacks: callbacks))
    }

    var setStyleJSONStub = Stub<LoadStyleParams, Void>()
    func setStyleJSON(_ json: String, callbacks: RuntimeStylingCallbacks) {
        setStyleJSONStub.call(with: .init(value: json, callbacks: callbacks))
    }

    func asStyleManager() -> StyleManager {
        fatalError()
    }

    let getStyleURIStub = Stub<Void, String>(defaultReturnValue: "")
    func getStyleURI() -> String {
        getStyleURIStub.call()
    }

    let setStyleURIForUriStub = Stub<String, Void>()
    func setStyleURIForUri(_ uri: String) {
        setStyleURIForUriStub.call(with: uri)
    }

    let getStyleJSONStub = Stub<Void, String>(defaultReturnValue: "")
    func getStyleJSON() -> String {
        getStyleJSONStub.call()
    }

    let setStyleJSONForJsonStub = Stub<String, Void>()
    func setStyleJSONForJson(_ json: String) {
        setStyleJSONForJsonStub.call(with: json)
    }

    let getStyleDefaultCameraStub = Stub<Void, CoreCameraOptions>(
        defaultReturnValue: .init(MapboxMaps.CameraOptions())
    )
    func getStyleDefaultCamera() -> CoreCameraOptions {
        getStyleDefaultCameraStub.call()
    }

    let getStyleTransitionStub = Stub<Void, MapboxCoreMaps.TransitionOptions>(
        defaultReturnValue: .init(TransitionOptions())
    )
    func getStyleTransition() -> MapboxCoreMaps.TransitionOptions {
        getStyleTransitionStub.call()
    }

    let setStyleTransitionStub = Stub<MapboxCoreMaps.TransitionOptions, Void>()
    func setStyleTransitionFor(_ transitionOptions: MapboxCoreMaps.TransitionOptions) {
        setStyleTransitionStub.call(with: transitionOptions)
    }

    // MARK: Style Layers

    @Stubbed var stubStyleLayers: [MapboxCoreMaps.StyleObjectInfo] = .random(withLength: 3) {
        MapboxCoreMaps.StyleObjectInfo(
            id: .randomAlphanumeric(withLength: 12),
            type: MapboxMaps.LayerType.random().rawValue)
    }
    let styleLayerExistsStub = Stub<String, Bool>(defaultReturnValue: false)
    func styleLayerExists(forLayerId layerId: String) -> Bool {
        styleLayerExistsStub.call(with: layerId)
    }

    let getStyleLayersStub = Stub<Void, [MapboxCoreMaps.StyleObjectInfo]>(defaultReturnValue: [])
    func getStyleLayers() -> [MapboxCoreMaps.StyleObjectInfo] {
        getStyleLayersStub.call()
    }

    let getStyleSlotsStub = Stub<Void, [String]>(defaultReturnValue: [])
    func getStyleSlots() -> [String] {
        getStyleSlotsStub.call()
    }

    typealias GetStyleLayerPropertyParameters = (layerID: String, property: String)
    let getStyleLayerPropertyStub = Stub<GetStyleLayerPropertyParameters, StylePropertyValue>(
        defaultReturnValue: StylePropertyValue(value: "foo", kind: .undefined)
    )
    func getStyleLayerProperty(
        forLayerId layerId: String,
        property: String
    ) -> MapboxCoreMaps.StylePropertyValue {

        getStyleLayerPropertyStub.call(with: (layerID: layerId, property: property))
    }

    // MARK: Source Info

    struct GetStyleSourcePropertyParameters {
        let sourceId: String
        let property: String
    }
    let getStyleSourcePropertyStub = Stub<GetStyleSourcePropertyParameters, MapboxCoreMaps.StylePropertyValue>(
        defaultReturnValue: .init(value: "stub", kind: .undefined)
    )
    func getStyleSourceProperty(forSourceId sourceId: String, property: String) -> MapboxCoreMaps.StylePropertyValue {
        getStyleSourcePropertyStub.call(with: GetStyleSourcePropertyParameters(sourceId: sourceId, property: property))
    }

    let styleSourceExistsStub = Stub<String, Bool>(defaultReturnValue: false)
    func styleSourceExists(forSourceId sourceId: String) -> Bool {
        styleSourceExistsStub.call(with: sourceId)
    }

    let getStyleSourcesStub = Stub<Void, [MapboxCoreMaps.StyleObjectInfo]>(defaultReturnValue: [])
    func getStyleSources() -> [MapboxCoreMaps.StyleObjectInfo] {
        getStyleSourcesStub.call()
    }

    let getStyleLightPropertyStub = Stub<String, MapboxCoreMaps.StylePropertyValue>(
        defaultReturnValue: .init(value: "stub", kind: .undefined)
    )
    func getStyleLightProperty(forProperty property: String) -> MapboxCoreMaps.StylePropertyValue {
        getStyleLightPropertyStub.call(with: property)
    }

    let getStyleLightsStub = Stub<Void, [StyleObjectInfo]>(defaultReturnValue: [])
    func getStyleLights() -> [StyleObjectInfo] {
        getStyleLightsStub.call()
    }

    let setStyleLightsStub = Stub<Any, Expected<NSNull, NSString>>(defaultReturnValue: Expected(value: NSNull()))
    func setStyleLightsForLights(_ lights: Any) -> Expected<NSNull, NSString> {
        setStyleLightsStub.call(with: lights)
    }

    struct GetStyleLightPropertyForIdParameters {
        let id, property: String
    }
    let getStyleLightPropertyForIdStub = Stub<GetStyleLightPropertyForIdParameters, StylePropertyValue>(
        defaultReturnValue: .init(value: "stub", kind: .undefined)
    )
    func getStyleLightProperty(forId id: String, property: String) -> StylePropertyValue {
        getStyleLightPropertyForIdStub.call(with: .init(id: id, property: property))
    }

    struct SetStyleLightPropertyForIdParameters {
        let id, property: String
        let value: Any
    }
    let setStyleLightPropertyForIdStub = Stub<SetStyleLightPropertyForIdParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func setStyleLightPropertyForId(_ id: String, property: String, value: Any) -> Expected<NSNull, NSString> {
        setStyleLightPropertyForIdStub.call(with: .init(id: id, property: property, value: value))
    }

    let getStyleTerrainPropertyStub = Stub<String, MapboxCoreMaps.StylePropertyValue>(
        defaultReturnValue: .init(value: "stub", kind: .undefined)
    )
    func getStyleTerrainProperty(forProperty property: String) -> MapboxCoreMaps.StylePropertyValue {
        getStyleTerrainPropertyStub.call(with: property)
    }

    let getStyleProjectionPropertyStub = Stub<String, MapboxCoreMaps.StylePropertyValue>(
        defaultReturnValue: .init(value: "stub", kind: .undefined)
    )
    func getStyleProjectionProperty(forProperty property: String) -> MapboxCoreMaps.StylePropertyValue {
        getStyleProjectionPropertyStub.call(with: property)
    }

    let getStyleImageStub = Stub<String, CoreMapsImage?>(defaultReturnValue: nil)
    func getStyleImage(forImageId imageId: String) -> CoreMapsImage? {
        getStyleImageStub.call(with: imageId)
    }

    let hasStyleImageStub = Stub<String, Bool>(defaultReturnValue: false)
    func hasStyleImage(forImageId imageId: String) -> Bool {
        hasStyleImageStub.call(with: imageId)
    }

    let isStyleLoadedStub = Stub<Void, Bool>(defaultReturnValue: false)
    func isStyleLoaded() -> Bool {
        isStyleLoadedStub.call()
    }

    // MARK: Style Imports

    let getStyleImportsStub = Stub<Void, [MapboxCoreMaps.StyleObjectInfo]>(defaultReturnValue: [])
    func getStyleImports() -> [StyleObjectInfo] {
        getStyleImportsStub.call()
    }

    struct RemoveStyleImportParameters {
        let importId: String
    }
    let removeStyleImportStub = Stub<RemoveStyleImportParameters, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func removeStyleImport(forImportId importId: String) -> Expected<NSNull, NSString> {
        removeStyleImportStub.call(with: RemoveStyleImportParameters(importId: importId))
    }

    struct GetStyleImportSchemaParameters {
        let importId: String
    }
    let getStyleImportSchemaStub = Stub<GetStyleImportSchemaParameters, Expected<AnyObject, NSString>>(defaultReturnValue: .init(value: NSDictionary(dictionary: ["stub": "stub"])))
    func getStyleImportSchema(forImportId importId: String) -> Expected<AnyObject, NSString> {
        getStyleImportSchemaStub.call(with: GetStyleImportSchemaParameters(importId: importId))
    }

    struct GetStyleImportConfigPropertiesParameters {
        let importId: String
    }
    let getStyleImportConfigPropertiesStub = Stub<GetStyleImportConfigPropertiesParameters, Expected<NSDictionary, NSString>>(defaultReturnValue: .init(value: NSDictionary(dictionary: ["stub": StylePropertyValue.init(value: "stub", kind: .undefined)])))
    func getStyleImportConfigProperties(forImportId importId: String) -> Expected<NSDictionary, NSString> {
        getStyleImportConfigPropertiesStub.call(with: GetStyleImportConfigPropertiesParameters(importId: importId))
    }

    struct GetStyleImportConfigPropertyParameters {
        let importId: String
        let config: String
    }
    let getStyleImportConfigPropertyStub = Stub<GetStyleImportConfigPropertyParameters, Expected<MapboxCoreMaps.StylePropertyValue, NSString>>(defaultReturnValue: .init(value: .init(value: "stub", kind: .undefined)))
    func getStyleImportConfigProperty(forImportId importId: String, config: String) -> Expected<StylePropertyValue, NSString> {
        getStyleImportConfigPropertyStub.call(with: GetStyleImportConfigPropertyParameters(importId: importId, config: config))
    }

    struct SetStyleImportConfigPropertiesForImportIdParameters {
        let importId: String
        let configs: [String: Any]
    }
    let setStyleImportConfigPropertiesForImportIdStub = Stub<SetStyleImportConfigPropertiesForImportIdParameters, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func setStyleImportConfigPropertiesForImportId(_ importId: String, configs: [String: Any]) -> Expected<NSNull, NSString> {
        setStyleImportConfigPropertiesForImportIdStub.call(with: SetStyleImportConfigPropertiesForImportIdParameters(importId: importId, configs: configs))
    }

    struct SetStyleImportConfigPropertyForImportIdParameters {
        let importId: String
        let config: String
        let value: Any
    }
    let setStyleImportConfigPropertyForImportIdStub = Stub<SetStyleImportConfigPropertyForImportIdParameters, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func setStyleImportConfigPropertyForImportId(_ importId: String, config: String, value: Any) -> Expected<NSNull, NSString> {
        setStyleImportConfigPropertyForImportIdStub.call(with: SetStyleImportConfigPropertyForImportIdParameters(importId: importId, config: config, value: value))
    }

    // MARK: Layers

    struct AddStyleLayerParameters {
        let properties: Any
        let layerPosition: CoreLayerPosition?

        var layerId: String? {
            (properties as? [String: Any])?["id"] as? String
        }
    }
    let addStyleLayerStub = Stub<AddStyleLayerParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func addStyleLayer(
        forProperties properties: Any,
        layerPosition: CoreLayerPosition?
    ) -> Expected<NSNull, NSString> {

        addStyleLayerStub.call(with: AddStyleLayerParameters(properties: properties, layerPosition: layerPosition))
    }

    struct AddStyleCustomLayerParameters {
        let layerId: String
        let layerHost: CustomLayerHost
        let layerPosition: CoreLayerPosition?
    }
    let addStyleCustomLayerStub = Stub<AddStyleCustomLayerParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func addStyleCustomLayer(
        forLayerId layerId: String,
        layerHost: CustomLayerHost,
        layerPosition: CoreLayerPosition?
    ) -> Expected<NSNull, NSString> {

        addStyleCustomLayerStub.call(
            with: AddStyleCustomLayerParameters(layerId: layerId, layerHost: layerHost, layerPosition: layerPosition)
        )
    }

    let addPersistentStyleLayerStub = Stub<AddStyleLayerParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func addPersistentStyleLayer(
        forProperties properties: Any,
        layerPosition: CoreLayerPosition?
    ) -> Expected<NSNull, NSString> {

        addPersistentStyleLayerStub.call(with: AddStyleLayerParameters(properties: properties, layerPosition: layerPosition))
    }

    let addPersistentStyleCustomLayerStub = Stub<AddStyleCustomLayerParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func addPersistentStyleCustomLayer(
        forLayerId layerId: String,
        layerHost: CustomLayerHost,
        layerPosition: CoreLayerPosition?
    ) -> Expected<NSNull, NSString> {

        addPersistentStyleCustomLayerStub.call(
            with: AddStyleCustomLayerParameters(layerId: layerId, layerHost: layerHost, layerPosition: layerPosition)
        )
    }

    let isStyleLayerPersistentStub = Stub<String, Expected<NSNumber, NSString>>(defaultReturnValue: .init(value: 0))
    func isStyleLayerPersistent(forLayerId layerId: String) -> Expected<NSNumber, NSString> {
        isStyleLayerPersistentStub.call(with: layerId)
    }

    let removeStyleLayerStub = Stub<String, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func removeStyleLayer(forLayerId layerId: String) -> Expected<NSNull, NSString> {
        removeStyleLayerStub.call(with: layerId)
    }

    struct MoveStyleLayerParameters {
        let layerId: String
        let layerPosition: CoreLayerPosition?
    }
    let moveStyleLayerStub = Stub<MoveStyleLayerParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func moveStyleLayer(forLayerId layerId: String, layerPosition: CoreLayerPosition?) -> Expected<NSNull, NSString> {
        moveStyleLayerStub.call(with: MoveStyleLayerParameters(layerId: layerId, layerPosition: layerPosition))
    }

    struct SetStyleLayerPropertyParameters {
        let layerId: String
        let property: String
        let value: Any
    }
    let setStyleLayerPropertyStub = Stub<SetStyleLayerPropertyParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func setStyleLayerPropertyForLayerId(_ layerId: String, property: String, value: Any) -> Expected<NSNull, NSString> {
        setStyleLayerPropertyStub.call(
            with: SetStyleLayerPropertyParameters(layerId: layerId, property: property, value: value)
        )
    }

    let getStyleLayerPropertiesStub = Stub<String, Expected<AnyObject, NSString>>(
        defaultReturnValue: .init(value: NSDictionary(dictionary: ["stub": "stub"]))
    )
    func getStyleLayerProperties(forLayerId layerId: String) -> Expected<AnyObject, NSString> {
        getStyleLayerPropertiesStub.call(with: layerId)
    }

    struct SetStyleLayerPropertiesParameters {
        let layerId: String
        let properties: Any
    }
    let setStyleLayerPropertiesStub = Stub<SetStyleLayerPropertiesParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func setStyleLayerPropertiesForLayerId(_ layerId: String, properties: Any) -> Expected<NSNull, NSString> {
        setStyleLayerPropertiesStub.call(
            with: SetStyleLayerPropertiesParameters(layerId: layerId, properties: properties)
        )
    }

    struct SetStyleSourceParameters {
        let sourceId: String
        let properties: Any
    }
    let addStyleSourceStub = Stub<SetStyleSourceParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func addStyleSource(forSourceId sourceId: String, properties: Any) -> Expected<NSNull, NSString> {
        addStyleSourceStub.call(with: SetStyleSourceParameters(sourceId: sourceId, properties: properties))
    }

    struct SetStyleSourcePropertyParameters {
        let sourceId: String
        let property: String
        let value: Any
    }
    let setStyleSourcePropertyStub = Stub<SetStyleSourcePropertyParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func setStyleSourcePropertyForSourceId(_ sourceId: String, property: String, value: Any) -> Expected<NSNull, NSString> {
        setStyleSourcePropertyStub.call(
            with: SetStyleSourcePropertyParameters(sourceId: sourceId, property: property, value: value)
        )
    }

    let getStyleSourcePropertiesStub = Stub<String, Expected<AnyObject, NSString>>(
        defaultReturnValue: .init(value: NSDictionary(dictionary: ["stub": "stub"]))
    )
    func getStyleSourceProperties(forSourceId sourceId: String) -> Expected<AnyObject, NSString> {
        getStyleSourcePropertiesStub.call(with: sourceId)
    }

    let setStyleSourcePropertiesStub = Stub<SetStyleSourceParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func setStyleSourcePropertiesForSourceId(_ sourceId: String, properties: Any) -> Expected<NSNull, NSString> {
        setStyleSourcePropertiesStub.call(with: .init(sourceId: sourceId, properties: properties))
    }

    struct UpdateStyleImageSourceParameters {
        let sourceId: String
        let image: CoreMapsImage
    }
    let updateStyleImageSourceStub = Stub<UpdateStyleImageSourceParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func updateStyleImageSourceImage(forSourceId sourceId: String, image: CoreMapsImage) -> Expected<NSNull, NSString> {
        updateStyleImageSourceStub.call(with: UpdateStyleImageSourceParameters(sourceId: sourceId, image: image))
    }

    let removeStyleSourceStub = Stub<String, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func removeStyleSource(forSourceId sourceId: String) -> Expected<NSNull, NSString> {
        removeStyleSourceStub.call(with: sourceId)
    }

    let removeStyleSourceUncheckedStub = Stub<String, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func removeStyleSourceUnchecked(forSourceId sourceId: String) -> Expected<NSNull, NSString> {
        removeStyleSourceUncheckedStub.call(with: sourceId)
    }

    struct SetStylePropertyParameters {
        let property: String
        let value: Any
    }
    let setStyleLightPropertyStub = Stub<SetStylePropertyParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func setStyleLightPropertyForProperty(_ property: String, value: Any) -> Expected<NSNull, NSString> {
        setStyleLightPropertyStub.call(with: SetStylePropertyParameters(property: property, value: value))
    }

    let setStyleTerrainForPropertiesStub = Stub<Any, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func setStyleTerrainForProperties(_ properties: Any) -> Expected<NSNull, NSString> {
        setStyleTerrainForPropertiesStub.call(with: properties)
    }

    let setStyleTerrainPropertyStub = Stub<SetStylePropertyParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func setStyleTerrainPropertyForProperty(_ property: String, value: Any) -> Expected<NSNull, NSString> {
        setStyleTerrainPropertyStub.call(with: SetStylePropertyParameters(property: property, value: value))
    }

    let setStyleProjectionPropertiesStub = Stub<Any, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func setStyleProjectionForProperties(_ properties: Any) -> Expected<NSNull, NSString> {
        setStyleProjectionPropertiesStub.call(with: properties)
    }

    let setStyleProjectionPropertyStub = Stub<SetStylePropertyParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func setStyleProjectionPropertyForProperty(_ property: String, value: Any) -> Expected<NSNull, NSString> {
        setStyleProjectionPropertyStub.call(with: SetStylePropertyParameters(property: property, value: value))
    }

    struct AddStyleImageParameters {
        let imageId: String
        let scale: Float
        let image: CoreMapsImage
        let sdf: Bool
        let stretchX: [ImageStretches]
        let stretchY: [ImageStretches]
        let content: ImageContent?
    }
    let addStyleImageStub = Stub<AddStyleImageParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    // swiftlint:disable:next function_parameter_count
    func addStyleImage(
        forImageId imageId: String,
        scale: Float,
        image: CoreMapsImage,
        sdf: Bool,
        stretchX: [ImageStretches],
        stretchY: [ImageStretches],
        content: ImageContent?
    ) -> Expected<NSNull, NSString> {

        addStyleImageStub.call(
            with: AddStyleImageParameters(
                imageId: imageId,
                scale: scale,
                image: image,
                sdf: sdf,
                stretchX: stretchX,
                stretchY: stretchY,
                content: content
            ))
    }

    let removeStyleImageStub = Stub<String, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func removeStyleImage(forImageId imageId: String) -> Expected<NSNull, NSString> {
        removeStyleImageStub.call(with: imageId)
    }

    struct AddStyleCustomGeometrySourceParameters {
        let sourceId: String
        let options: CustomGeometrySourceOptions
    }
    let addStyleCustomGeometrySourceStub = Stub<AddStyleCustomGeometrySourceParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func addStyleCustomGeometrySource(
        forSourceId sourceId: String,
        options: CustomGeometrySourceOptions
    ) -> Expected<NSNull, NSString> {

        addStyleCustomGeometrySourceStub.call(
            with: AddStyleCustomGeometrySourceParameters(sourceId: sourceId, options: options)
        )
    }

    struct SetStyleGeometrySourceTileDataParameters {
        let sourceId: String
        let tileId: CanonicalTileID
        let featureCollection: [MapboxCommon.Feature]
    }
    let setStyleCustomGeometrySourceTileDataStub = Stub<SetStyleGeometrySourceTileDataParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func setStyleCustomGeometrySourceTileDataForSourceId(
        _ sourceId: String,
        tileId: CanonicalTileID,
        featureCollection: [MapboxCommon.Feature]
    ) -> Expected<NSNull, NSString> {

        setStyleCustomGeometrySourceTileDataStub.call(
            with: SetStyleGeometrySourceTileDataParameters(
                sourceId: sourceId,
                tileId: tileId,
                featureCollection: featureCollection
            ))
    }

    struct InvalidateCustomGeometryTileParameters {
        let sourceId: String
        let tileId: CanonicalTileID
    }
    let invalidateStyleCustomGeometrySourceTileStub = Stub<InvalidateCustomGeometryTileParameters, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func invalidateStyleCustomGeometrySourceTile(
        forSourceId sourceId: String,
        tileId: CanonicalTileID
    ) -> Expected<NSNull, NSString> {

        invalidateStyleCustomGeometrySourceTileStub.call(with: .init(sourceId: sourceId, tileId: tileId))
    }

    struct InvalidateCustomGeometrySourceRegionParameters {
        let sourceId: String
        let bounds: CoordinateBounds
    }
    let invalidateStyleCustomGeometrySourceRegionStub = Stub<InvalidateCustomGeometrySourceRegionParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func invalidateStyleCustomGeometrySourceRegion(
        forSourceId sourceId: String,
        bounds: CoordinateBounds
    ) -> Expected<NSNull, NSString> {

        invalidateStyleCustomGeometrySourceRegionStub.call(with: .init(sourceId: sourceId, bounds: bounds))
    }

    struct AddStyleCustomRasterSourceParameters {
        let sourceID: String
        let options: CustomRasterSourceOptions
    }
    let addStyleCustomRasterSourceStub = Stub<AddStyleCustomRasterSourceParameters, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func addStyleCustomRasterSource(
        forSourceId sourceId: String,
        options: CustomRasterSourceOptions
    ) -> Expected<NSNull, NSString> {
        addStyleCustomRasterSourceStub.call(with: .init(sourceID: sourceId, options: options))
    }

    struct SetStyleCustomRasterSourceTileDataParameters {
        let sourceID: String
        let tiles: [MapboxMaps.CoreCustomRasterSourceTileData]
    }
    let setStyleCustomRasterSourceTileDataStub = Stub<SetStyleCustomRasterSourceTileDataParameters, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))

    func setStyleCustomRasterSourceTileDataForSourceId(
        _ sourceId: String,
        tiles: [MapboxMaps.CoreCustomRasterSourceTileData]
    ) -> Expected<NSNull, NSString> {
        setStyleCustomRasterSourceTileDataStub.call(with: .init(sourceID: sourceId, tiles: tiles))
    }

    struct InvalidateStyleCustomRasterSourceTileParameters {
        let sourceID: String
        let tileId: CanonicalTileID
    }
    let invalidateStyleCustomRasterSourceTileStub = Stub<InvalidateStyleCustomRasterSourceTileParameters, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func invalidateStyleCustomRasterSourceTile(
        forSourceId sourceId: String,
        tileId: CanonicalTileID
    ) -> Expected<NSNull, NSString> {
        invalidateStyleCustomRasterSourceTileStub.call(with: .init(sourceID: sourceId, tileId: tileId))
    }

    struct InvalidateStyleCustomRasterSourceRegionParameters {
        let sourceID: String
        let bounds: CoordinateBounds
    }
    let invalidateStyleCustomRasterSourceRegionStub = Stub<InvalidateStyleCustomRasterSourceRegionParameters, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func invalidateStyleCustomRasterSourceRegion(
        forSourceId sourceId: String,
        bounds: CoordinateBounds
    ) -> Expected<NSNull, NSString> {
        invalidateStyleCustomRasterSourceRegionStub.call(with: .init(sourceID: sourceId, bounds: bounds))
    }

    struct SetStyleGeoJSONSourceDataForSourceIdDataIDParams {
        let sourceId: String
        let dataId: String?
        let data: CoreGeoJSONSourceData
    }
    let setStyleGeoJSONSourceDataForSourceIdDataIDStub = Stub<SetStyleGeoJSONSourceDataForSourceIdDataIDParams, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: .init())
    )
    func __setStyleGeoJSONSourceDataForSourceId(_ sourceId: String, dataId: String, data: CoreGeoJSONSourceData) -> Expected<NSNull, NSString> {
        setStyleGeoJSONSourceDataForSourceIdDataIDStub.call(with: .init(sourceId: sourceId, dataId: dataId, data: data))
    }

    struct AddStyleModelParams {
        let modelId, modelUri: String
    }
    let addStyleModelStub = Stub<AddStyleModelParams, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func addStyleModel(forModelId modelId: String, modelUri: String) -> Expected<NSNull, NSString> {
        addStyleModelStub.call(with: AddStyleModelParams(modelId: modelId, modelUri: modelUri))
    }

    struct RemoveStyleModelParams {
        let modelId: String
    }
    let removeStyleModelStub = Stub<RemoveStyleModelParams, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func removeStyleModel(forModelId modelId: String) -> Expected<NSNull, NSString> {
        removeStyleModelStub.call(with: RemoveStyleModelParams(modelId: modelId))
    }

    struct HasStyleModelParams {
        let modelId: String
    }
    let hasStyleModelStub = Stub<HasStyleModelParams, Bool>(defaultReturnValue: false)
    func hasStyleModel(forModelId modelId: String) -> Bool {
        hasStyleModelStub.call(with: HasStyleModelParams(modelId: modelId))
    }

    let getStyleAtmospherePropertyStub = Stub<String, MapboxCoreMaps.StylePropertyValue>(
        defaultReturnValue: .init(value: "stub", kind: .undefined)
    )
    func getStyleAtmosphereProperty(forProperty property: String) -> StylePropertyValue {
        getStyleAtmospherePropertyStub.call(with: property)
    }

    let setStyleAtmosphereForPropertiesStub = Stub<Any, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func setStyleAtmosphereForProperties(_ properties: Any) -> Expected<NSNull, NSString> {
        setStyleAtmosphereForPropertiesStub.call(with: properties)
    }

    let setStyleAtmospherePropertyStub = Stub<SetStylePropertyParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func setStyleAtmospherePropertyForProperty(_ property: String, value: Any) -> Expected<NSNull, NSString> {
        setStyleAtmospherePropertyStub.call(with: SetStylePropertyParameters(property: property, value: value))
    }

    struct AddGeoJSONSourceFeaturesParams {
        let sourceId: String
        let features: [MapboxCommon.Feature]
        let dataId: String
    }
    let addGeoJSONSourceFeaturesStub = Stub<AddGeoJSONSourceFeaturesParams, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull()))
    func addGeoJSONSourceFeatures(forSourceId sourceId: String, dataId: String, features: [MapboxCommon.Feature]) -> Expected<NSNull, NSString> {
        addGeoJSONSourceFeaturesStub.call(with: .init(sourceId: sourceId, features: features, dataId: dataId))
    }

    struct UpdateGeoJSONSourceFeaturesParams {
        let sourceId: String
        let features: [MapboxCommon.Feature]
        let dataId: String
    }
    let updateGeoJSONSourceFeaturesStub = Stub<UpdateGeoJSONSourceFeaturesParams, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull()))
    func updateGeoJSONSourceFeatures(forSourceId sourceId: String, dataId: String, features: [MapboxCommon.Feature]) -> Expected<NSNull, NSString> {
        updateGeoJSONSourceFeaturesStub.call(with: .init(sourceId: sourceId, features: features, dataId: dataId))
    }

    struct RemoveGeoJSONSourceFeaturesParams {
        let sourceId: String
        let featureIds: [String]
        let dataId: String
    }
    let removeGeoJSONSourceFeaturesStub = Stub<RemoveGeoJSONSourceFeaturesParams, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull()))
    func removeGeoJSONSourceFeatures(forSourceId sourceId: String, dataId: String, featureIds: [String]) -> Expected<NSNull, NSString> {
        removeGeoJSONSourceFeaturesStub.call(with: .init(sourceId: sourceId, featureIds: featureIds, dataId: dataId))
    }

    // MARK: - Import

    struct AddStyleImportFromJSONParams {
        let forImportId: String
        let json: String, config: [String: Any]?
        let importPosition: MapboxMaps.CoreImportPosition?
    }
    let addStyleImportFromJSONStub = Stub<AddStyleImportFromJSONParams, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull()))

    func addStyleImportFromJSON(
        forImportId: String,
        json: String, config: [String: Any]?,
        importPosition: MapboxMaps.CoreImportPosition?
    ) -> Expected<NSNull, NSString> {
        addStyleImportFromJSONStub.call(with: AddStyleImportFromJSONParams(forImportId: forImportId, json: json, config: config, importPosition: importPosition))
    }

    struct AddStyleImportFromURIParams {
        let forImportId: String
        let uri: String
        let importPosition: MapboxMaps.CoreImportPosition?
    }
    let addStyleImportFromURIStub = Stub<AddStyleImportFromURIParams, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull()))

    func addStyleImportFromURI(
        forImportId: String,
        uri: String,
        config: [String: Any]?,
        importPosition: MapboxMaps.CoreImportPosition?
    ) -> Expected<NSNull, NSString> {
        addStyleImportFromURIStub.call(with: AddStyleImportFromURIParams(forImportId: forImportId, uri: uri, importPosition: importPosition))
    }

    struct UpdateStyleImportWithURIParams {
        let forImportId: String
        let uri: String
        let config: [String: Any]?
    }
    let updateStyleImportWithURIStub = Stub<UpdateStyleImportWithURIParams, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull()))

    func updateStyleImportWithURI(
        forImportId: String,
        uri: String,
        config: [String: Any]?
    ) -> Expected<NSNull, NSString> {
        updateStyleImportWithURIStub.call(with: UpdateStyleImportWithURIParams(forImportId: forImportId, uri: uri, config: config))
    }

    struct UpdateStyleImportWithJSONParams {
        let forImportId: String
        let json: String
        let config: [String: Any]?
    }
    let updateStyleImportWithJSONStub = Stub<UpdateStyleImportWithJSONParams, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull()))

    func updateStyleImportWithJSON(
        forImportId: String,
        json: String,
        config: [String: Any]?
    ) -> Expected<NSNull, NSString> {
        updateStyleImportWithJSONStub.call(with: UpdateStyleImportWithJSONParams(forImportId: forImportId, json: json, config: config))
    }

    struct MoveStyleImportParams {
        let forImportId: String
        let importPosition: MapboxMaps.CoreImportPosition?
    }
    let moveStyleImportStub = Stub<MoveStyleImportParams, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull()))

    func moveStyleImport(forImportId: String, importPosition: MapboxMaps.CoreImportPosition?) -> Expected<NSNull, NSString> {
        moveStyleImportStub.call(with: MoveStyleImportParams(forImportId: forImportId, importPosition: importPosition))
    }
}

struct NonEncodableLayer: Layer {
    var id: String = "dummy-non-encodable-layer-id"
    var visibility: Value<Visibility> = .constant(.visible)
    var type: LayerType = .random()
    var filter: Exp?
    var source: String?
    var sourceLayer: String?
    var minZoom: Double?
    var maxZoom: Double?
    var slot: Slot?
    var layerPosition: LayerPosition?

    init() {}

    func encode(to encoder: Encoder) throws {
        throw MockError()
    }
}
