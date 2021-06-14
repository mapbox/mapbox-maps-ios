import Foundation
@testable import MapboxMaps

class MockLocationStyleDelegate: LocationStyleDelegate {
    func _addPersistentLayer(_ layer: Layer, layerPosition: LayerPosition?) throws {}
    func removeLayer(withId id: String) throws {}
    func layerExists(withId id: String) -> Bool { return false }
    func setLayerProperties(for layerId: String, properties: [String: Any]) throws {}
    func addSource(_ source: Source, id: String) throws {}
    func removeSource(withId id: String) throws {}
    func setSourceProperty(for sourceId: String, property: String, value: Any) throws {}

    //swiftlint:disable function_parameter_count
    func addImage(_ image: UIImage, id: String, sdf: Bool, stretchX: [ImageStretches], stretchY: [ImageStretches], content: ImageContent?) throws {}
}
