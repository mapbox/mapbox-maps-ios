import Foundation
@testable import MapboxMaps

final class MockAnnotationOrchestatorImpl: AnnotationOrchestratorImplProtocol {
    @Stubbed
    var annotationManagersById: [String: AnnotationManager] = [:]

    func makePointAnnotationManager(id: String,
                                    layerPosition: LayerPosition?,
                                    clusterOptions: ClusterOptions?) -> PointAnnotationManager {
        fatalError("TODO")
    }
    func makePolygonAnnotationManager(id: String, layerPosition: LayerPosition?) -> PolygonAnnotationManager {
        fatalError("TODO")
    }
    func makePolylineAnnotationManager(id: String, layerPosition: LayerPosition?) -> PolylineAnnotationManager {
        fatalError("TODO")
    }
    func makeCircleAnnotationManager(id: String, layerPosition: LayerPosition?) -> CircleAnnotationManager {
        fatalError("TODO")
    }
    func removeAnnotationManager(withId id: String) {
        fatalError("TODO")
    }
}
