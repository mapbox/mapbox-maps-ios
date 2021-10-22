internal protocol LocationStyleProtocol: AnyObject {
    func addPersistentLayer(_ layer: Layer, layerPosition: LayerPosition?) throws
    func addPersistentLayer(with properties: [String: Any], layerPosition: LayerPosition?) throws
    func removeLayer(withId id: String) throws
    func layerExists(withId id: String) -> Bool
    func setLayerProperties(for layerId: String, properties: [String: Any]) throws

    func addSource(_ source: Source, id: String) throws
    func removeSource(withId id: String) throws
    func sourceExists(withId id: String) -> Bool
    func setSourceProperties(for sourceId: String, properties: [String: Any]) throws

    //swiftlint:disable function_parameter_count
    func addImage(_ image: UIImage,
                  id: String,
                  sdf: Bool,
                  stretchX: [ImageStretches],
                  stretchY: [ImageStretches],
                  content: ImageContent?) throws
    func removeImage(withId id: String) throws
}

extension Style: LocationStyleProtocol { }
