import Foundation
@testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private

class MockStyleManager: StyleManagerProtocol {

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

    let getStyleDefaultCameraStub = Stub<Void, MapboxCoreMaps.CameraOptions>(
        defaultReturnValue: .init(MapboxMaps.CameraOptions())
    )
    func getStyleDefaultCamera() -> MapboxCoreMaps.CameraOptions {
        getStyleDefaultCameraStub.call()
    }

    let getStyleTransitionStub = Stub<Void, MapboxCoreMaps.TransitionOptions>(
        defaultReturnValue: TransitionOptions(duration: nil, delay: nil, enablePlacementTransitions: nil)
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

    let getStyleImageStub = Stub<String, MapboxCoreMaps.Image?>(defaultReturnValue: nil)
    func getStyleImage(forImageId imageId: String) -> MapboxCoreMaps.Image? {
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

    // MARK: Layers

    struct AddStyleLayerParameters {
        let properties: Any
        let layerPosition: MapboxCoreMaps.LayerPosition?
    }
    let addStyleLayerStub = Stub<AddStyleLayerParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func addStyleLayer(
        forProperties properties: Any,
        layerPosition: MapboxCoreMaps.LayerPosition?
    ) -> Expected<NSNull, NSString> {

        addStyleLayerStub.call(with: AddStyleLayerParameters(properties: properties, layerPosition: layerPosition))
    }

    struct AddStyleCustomLayerParameters {
        let layerId: String
        let layerHost: CustomLayerHost
        let layerPosition: MapboxCoreMaps.LayerPosition?
    }
    let addStyleCustomLayerStub = Stub<AddStyleCustomLayerParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func addStyleCustomLayer(
        forLayerId layerId: String,
        layerHost: CustomLayerHost,
        layerPosition: MapboxCoreMaps.LayerPosition?
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
        layerPosition: MapboxCoreMaps.LayerPosition?
    ) -> Expected<NSNull, NSString> {

        addPersistentStyleLayerStub.call(with: AddStyleLayerParameters(properties: properties, layerPosition: layerPosition))
    }

    let addPersistentStyleCustomLayerStub = Stub<AddStyleCustomLayerParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func addPersistentStyleCustomLayer(
        forLayerId layerId: String,
        layerHost: CustomLayerHost,
        layerPosition: MapboxCoreMaps.LayerPosition?
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
        let layerPosition: MapboxCoreMaps.LayerPosition?
    }
    let moveStyleLayerStub = Stub<MoveStyleLayerParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func moveStyleLayer(forLayerId layerId: String, layerPosition: MapboxCoreMaps.LayerPosition?) -> Expected<NSNull, NSString> {
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
        let image: MapboxCoreMaps.Image
    }
    let updateStyleImageSourceStub = Stub<UpdateStyleImageSourceParameters, Expected<NSNull, NSString>>(
        defaultReturnValue: .init(value: NSNull())
    )
    func updateStyleImageSourceImage(forSourceId sourceId: String, image: Image) -> Expected<NSNull, NSString> {
        updateStyleImageSourceStub.call(with: UpdateStyleImageSourceParameters(sourceId: sourceId, image: image))
    }

    let removeStyleSourceStub = Stub<String, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func removeStyleSource(forSourceId sourceId: String) -> Expected<NSNull, NSString> {
        removeStyleSourceStub.call(with: sourceId)
    }

    let setStyleLightForPropertiesStub = Stub<Any, Expected<NSNull, NSString>>(defaultReturnValue: .init(value: NSNull()))
    func setStyleLightForProperties(_ properties: Any) -> Expected<NSNull, NSString> {
        setStyleLightForPropertiesStub.call(with: properties)
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
        let image: MapboxCoreMaps.Image
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
        image: Image,
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
