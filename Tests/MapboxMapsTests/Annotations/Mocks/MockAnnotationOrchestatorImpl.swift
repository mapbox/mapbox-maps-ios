import Foundation
@testable import MapboxMaps

final class MockAnnotationOrchestatorImpl: AnnotationOrchestratorImplProtocol {
    @Stubbed
    var annotationManagersById: [String: AnnotationManager] = [:]

    func makePointAnnotationManager(id: String,
                                    layerPosition: LayerPosition?,
                                    clusterOptions: ClusterOptions?) -> AnnotationManagerInternal {
        fatalError("TODO")
    }
    func makePolygonAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal {
        fatalError("TODO")
    }
    func makePolylineAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal {
        fatalError("TODO")
    }
    func makeCircleAnnotationManager(id: String, layerPosition: LayerPosition?) -> AnnotationManagerInternal {
        fatalError("TODO")
    }
    func removeAnnotationManager(withId id: String) {
        fatalError("TODO")
    }
}
