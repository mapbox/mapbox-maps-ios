@testable import MapboxMaps

final class MockStyle: StyleProtocol {
    struct AddPersistentLayerParams {
        var layer: Layer
        var layerPosition: LayerPosition?
    }
    let addPersistentLayerStub = Stub<AddPersistentLayerParams, Void>()
    func addPersistentLayer(_ layer: Layer, layerPosition: LayerPosition?) throws {
        addPersistentLayerStub.call(with: .init(layer: layer, layerPosition: layerPosition))
    }

    struct AddPersistentLayerWithPropertiesParams {
        var properties: [String : Any]
        var layerPosition: LayerPosition?
    }
    let addPersistentLayerWithPropertiesStub = Stub<AddPersistentLayerWithPropertiesParams, Void>()
    func addPersistentLayer(with properties: [String : Any], layerPosition: LayerPosition?) throws {
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

    struct SetLayerPropertiesParams {
        var layerId: String
        var properties: [String: Any]
    }
    let setLayerPropertiesStub = Stub<SetLayerPropertiesParams, Void>()
    func setLayerProperties(for layerId: String, properties: [String: Any]) throws {
        setLayerPropertiesStub.call(with: .init(layerId: layerId, properties: properties))
    }

    struct AddSourceParams {
        var source: Source
        var id: String
    }
    let addSourceStub = Stub<AddSourceParams, Void>()
    func addSource(_ source: Source, id: String) throws {
        addSourceStub.call(with: .init(source: source, id: id))
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
        var properties: [String : Any]
    }
    let setSourcePropertiesStub = Stub<SetSourcePropertiesParams, Void>()
    func setSourceProperties(for sourceId: String, properties: [String : Any]) throws {
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
    //swiftlint:disable function_parameter_count
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
}
