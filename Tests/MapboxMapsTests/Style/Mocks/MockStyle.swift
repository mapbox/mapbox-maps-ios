import UIKit
@testable @_spi(Experimental) import MapboxMaps

final class MockStyle: StyleProtocol {
    @TestPublished var styleRootLoaded = false
    var isStyleRootLoaded: Signal<Bool> { $styleRootLoaded }

    var mapStyle: MapStyle?

    private(set)var isMapContentSet: Bool = false
    @available(iOS 13.0, *)
    func setMapContent(_ content: () -> any MapContent) {
        isMapContentSet.toggle()
    }

    let setMapContentDependenciesStub = Stub<MapContentDependencies, Void>()
    @available(iOS 13.0, *)
    func setMapContentDependencies(_ dependencies: MapContentDependencies) {
        setMapContentDependenciesStub.call(with: dependencies)
    }

    @Stubbed var isStyleLoaded: Bool = false
    @Stubbed var styleDefaultCamera: MapboxMaps.CameraOptions = .init()
    @Stubbed var uri: StyleURI? = .streets
    struct AddGeoJSONSourceFeaturesParams {
        let sourceId: String
        let features: [Feature]
        let dataId: String?
    }
    let addGeoJSONSourceFeaturesStub = Stub<AddGeoJSONSourceFeaturesParams, Void>()
    func addGeoJSONSourceFeatures(forSourceId sourceId: String, features: [Feature], dataId: String?) {
        addGeoJSONSourceFeaturesStub.call(with: .init(sourceId: sourceId, features: features, dataId: dataId))
    }

    struct UpdateGeoJSONSourceFeaturesParams {
        let sourceId: String
        let features: [Feature]
        let dataId: String?
    }
    let updateGeoJSONSourceFeaturesStub = Stub<UpdateGeoJSONSourceFeaturesParams, Void>()
    func updateGeoJSONSourceFeatures(forSourceId sourceId: String, features: [Feature], dataId: String?) {
        updateGeoJSONSourceFeaturesStub.call(with: .init(sourceId: sourceId, features: features, dataId: dataId))
    }

    struct RemoveGeoJSONSourceFeaturesParams {
        let sourceId: String
        let featureIds: [String]
        let dataId: String?
    }
    let removeGeoJSONSourceFeaturesStub = Stub<RemoveGeoJSONSourceFeaturesParams, Void>()
    func removeGeoJSONSourceFeatures(forSourceId sourceId: String, featureIds: [String], dataId: String?) {
        removeGeoJSONSourceFeaturesStub.call(with: .init(sourceId: sourceId, featureIds: featureIds, dataId: dataId))
    }

    struct AddLayerParams {
        var layer: Layer
        var layerPosition: LayerPosition?
    }

    let addLayerStub = Stub<AddLayerParams, Void>()
    func addLayer(_ layer: MapboxMaps.Layer, layerPosition: MapboxMaps.LayerPosition?) throws {
        addLayerStub.call(with: .init(layer: layer, layerPosition: layerPosition))
    }

    struct SetSourcePropertyParams {
        let sourceId: String
        let property: String
        let value: Any
    }

    let setSourcePropertyStub = Stub<SetSourcePropertyParams, Void>()
    func setSourceProperty(for sourceId: String, property: String, value: Any) throws {
        setSourcePropertyStub.call(with: .init(sourceId: sourceId, property: property, value: value))
    }

    let imageExistsStub = Stub<String, Bool>(defaultReturnValue: false)
    func imageExists(withId id: String) -> Bool {
        return imageExistsStub.call(with: id)
    }

    struct AddPersistentLayerParams {
        var layer: Layer
        var layerPosition: LayerPosition?
    }
    let addPersistentLayerStub = Stub<AddPersistentLayerParams, Void>()
    func addPersistentLayer(_ layer: Layer, layerPosition: LayerPosition?) throws {
        addPersistentLayerStub.call(with: .init(layer: layer, layerPosition: layerPosition))
    }

    struct MoveLayerParams {
        var id: String
        var position: LayerPosition
    }
    let moveLayerStub = Stub<MoveLayerParams, Void>()
    func moveLayer(withId id: String, to position: LayerPosition) throws {
        moveLayerStub.call(with: MoveLayerParams(id: id, position: position))
    }

    struct AddPersistentLayerWithPropertiesParams {
        var properties: [String: Any]
        var layerPosition: LayerPosition?
    }
    let addPersistentLayerWithPropertiesStub = Stub<AddPersistentLayerWithPropertiesParams, Void>()
    func addPersistentLayer(with properties: [String: Any], layerPosition: LayerPosition?) throws {
        addPersistentLayerWithPropertiesStub.call(with: .init(properties: properties, layerPosition: layerPosition))
    }

    let removeLayerStub = Stub<String, Void>()
    func removeLayer(withId id: String) throws {
        removeLayerStub.call(with: id)
    }

    let layerExistsStub = Stub<String, Bool>(defaultReturnValue: false)
    func layerExists(withId id: String) -> Bool {
        layerExistsStub.call(with: id)
    }

    let layerPropertiesStub = Stub<String, [String: Any]>(defaultReturnValue: [:])
    func layerProperties(for layerId: String) throws -> [String: Any] {
        layerPropertiesStub.call(with: layerId)
    }

    struct SetLayerPropertiesParams {
        var layerId: String
        var properties: [String: Any]
    }
    let setLayerPropertiesStub = Stub<SetLayerPropertiesParams, Void>()
    func setLayerProperties(for layerId: String, properties: [String: Any]) throws {
        setLayerPropertiesStub.call(with: .init(layerId: layerId, properties: properties))
    }

    struct SetLayerPropertyParams {
        let layerId: String
        let property: String
        let value: Any
    }
    let setLayerPropertyStub = Stub<SetLayerPropertyParams, Void>()
    func setLayerProperty(for layerId: String, property: String, value: Any) throws {
        setLayerPropertyStub.call(with: .init(layerId: layerId, property: property, value: value))
    }

    struct AddSourceParams {
        var source: Source
        var dataId: String?
    }
    let addSourceStub = Stub<AddSourceParams, Void>()
    func addSource(_ source: Source, dataId: String? = nil) throws {
        addSourceStub.call(with: .init(source: source, dataId: dataId))
    }

    let removeSourceStub = Stub<String, Void>()
    func removeSource(withId id: String) throws {
        removeSourceStub.call(with: id)
    }

    let sourceExistsStub = Stub<String, Bool>(defaultReturnValue: false)
    func sourceExists(withId id: String) -> Bool {
        sourceExistsStub.call(with: id)
    }

    struct SetSourcePropertiesParams {
        var sourceId: String
        var properties: [String: Any]
    }
    let setSourcePropertiesStub = Stub<SetSourcePropertiesParams, Void>()
    func setSourceProperties(for sourceId: String, properties: [String: Any]) throws {
        setSourcePropertiesStub.call(with: .init(sourceId: sourceId, properties: properties))
    }

    struct AddImageParams {
        var image: UIImage
        var id: String
        var sdf: Bool
        var stretchX: [ImageStretches]
        var stretchY: [ImageStretches]
        var content: ImageContent?
    }
    let addImageStub = Stub<AddImageParams, Void>()

    // swiftlint:disable:next function_parameter_count
    func addImage(_ image: UIImage,
                  id: String,
                  sdf: Bool,
                  stretchX: [ImageStretches],
                  stretchY: [ImageStretches],
                  content: ImageContent?) throws {
        addImageStub.call(with: .init(
            image: image,
            id: id,
            sdf: sdf,
            stretchX: stretchX,
            stretchY: stretchY,
            content: content))
    }

    let removeImageStub = Stub<String, Void>()
    func removeImage(withId id: String) throws {
        removeImageStub.call(with: id)
    }

    struct AddImageWithInsetsParams {
        let image: UIImage
        let id: String
        let sdf: Bool
        let contentInsets: UIEdgeInsets
    }
    let addImageWithInsetsStub = Stub<AddImageWithInsetsParams, Void>()
    func addImage(_ image: UIImage, id: String, sdf: Bool, contentInsets: UIEdgeInsets) throws {
        addImageWithInsetsStub.call(with: .init(image: image, id: id, sdf: sdf, contentInsets: contentInsets))
    }

    struct UpdateGeoJSONSourceParams {
        let id: String
        let geojson: GeoJSONObject
        let dataId: String?
    }
    let updateGeoJSONSourceStub = Stub<UpdateGeoJSONSourceParams, Void>()
    func updateGeoJSONSource(withId id: String, geoJSON: GeoJSONObject, dataId: String? = nil) {
        updateGeoJSONSourceStub.call(with: UpdateGeoJSONSourceParams(id: id, geojson: geoJSON, dataId: dataId))
    }
}
