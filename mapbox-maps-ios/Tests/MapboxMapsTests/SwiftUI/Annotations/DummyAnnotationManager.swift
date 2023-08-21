@testable import MapboxMaps

final class DummyAnnotationManager: AnnotationManagerInternal {
    let allLayerIds: [String]

    func destroy() {}

    func handleQueriedFeatureIds(_ queriedFeatureIds: [String]) {}
    func handleDragBegin(with featureIdentifiers: [String]) {}
    func handleDragChanged(with translation: CGPoint) {}
    func handleDragEnded() {}

    let id: String
    let sourceId: String
    let layerId: String

    init() {
        id = UUID().uuidString
        sourceId = "dummy-source_\(id)"
        layerId = "dummy-layer_\(id)"
        allLayerIds = []
    }
}
