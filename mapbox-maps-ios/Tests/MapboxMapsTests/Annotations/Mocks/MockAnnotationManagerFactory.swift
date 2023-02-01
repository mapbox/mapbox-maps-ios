@testable import MapboxMaps

internal final class MockAnnotationManagerFactory: AnnotationManagerFactoryProtocol {
    struct MakePointAnnotationManagerParams {
        var id: String
        var layerPosition: LayerPosition?
        var clusterOptions: ClusterOptions?
    }
    let makePointAnnotationManagerStub = Stub<MakePointAnnotationManagerParams, AnnotationManagerInternal>(defaultReturnValue: MockAnnotationManager())
    func makePointAnnotationManager(
        id: String,
        layerPosition: LayerPosition?,
        clusterOptions: ClusterOptions?) -> AnnotationManagerInternal {
        return makePointAnnotationManagerStub.call(with: MakePointAnnotationManagerParams(
            id: id,
            layerPosition: layerPosition,
            clusterOptions: clusterOptions))
    }

    struct MakePolylineAnnotationManagerParams {
        var id: String
        var layerPosition: LayerPosition?
    }
    let makePolylineAnnotationManagerStub = Stub<MakePolylineAnnotationManagerParams, AnnotationManagerInternal>(defaultReturnValue: MockAnnotationManager())
    func makePolylineAnnotationManager(
        id: String,
        layerPosition: LayerPosition?) -> AnnotationManagerInternal {
            return makePolylineAnnotationManagerStub.call(with: MakePolylineAnnotationManagerParams(
                id: id,
                layerPosition: layerPosition))
    }

    struct MakeCircleAnnotationManagerParams {
        var id: String
        var layerPosition: LayerPosition?
    }
    let makeCircleAnnotationManagerStub = Stub<MakeCircleAnnotationManagerParams, AnnotationManagerInternal>(defaultReturnValue: MockAnnotationManager())
    func makeCircleAnnotationManager(
        id: String,
        layerPosition: LayerPosition?) -> AnnotationManagerInternal {
        return makeCircleAnnotationManagerStub.call(with: MakeCircleAnnotationManagerParams(
            id: id,
            layerPosition: layerPosition))
    }

    struct MakePolygonAnnotationManagerParams {
        var id: String
        var layerPosition: LayerPosition?
    }
    let makePolygonAnnotationManagerStub = Stub<MakePolygonAnnotationManagerParams, AnnotationManagerInternal>(defaultReturnValue: MockAnnotationManager())
    internal func makePolygonAnnotationManager(
        id: String,
        layerPosition: LayerPosition?
    ) -> AnnotationManagerInternal {
        return makePolygonAnnotationManagerStub.call(with: MakePolygonAnnotationManagerParams(
            id: id,
            layerPosition: layerPosition))
    }
}
