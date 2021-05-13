internal protocol LocationStyleDelegate: AnyObject {
    func addLayer(_ layer: Layer, layerPosition: LayerPosition?) throws
    func removeLayer(withId id: String) throws
    func layerExists(withId id: String) -> Bool
    func setLayerProperties(for layerId: String, properties: [String: Any]) throws
    func addSource(_ source: Source, id: String) throws
    func removeSource(withId id: String) throws
    func setSourceProperty(for sourceId: String, property: String, value: Any) throws

    //swiftlint:disable function_parameter_count
    func addImage(_ image: UIImage, id: String, sdf: Bool, stretchX: [ImageStretches], stretchY: [ImageStretches], content: ImageContent?) throws
}

extension LocationStyleDelegate {
    internal func addLayer(_ layer: Layer, layerPosition: LayerPosition? = nil) throws {
        try addLayer(layer, layerPosition: layerPosition)
    }

    internal func addImage(_ image: UIImage, id: String, sdf: Bool = false, stretchX: [ImageStretches] = [], stretchY: [ImageStretches] = [], content: ImageContent? = nil) throws {
        try addImage(image, id: id, sdf: sdf, stretchX: stretchX, stretchY: stretchY, content: content)
    }
}
