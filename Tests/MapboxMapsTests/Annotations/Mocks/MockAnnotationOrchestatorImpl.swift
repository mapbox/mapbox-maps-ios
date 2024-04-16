import Foundation
@testable import MapboxMaps

final class MockAnnotationOrchestatorImpl: AnnotationOrchestratorImplProtocol {
    @Stubbed
    var managersByLayerId: [String: AnnotationManagerInternal] = [:]

    @Stubbed
    var annotationManagersById: [String: AnnotationManager] = [:]

    struct MakePointAnnotationManagerParams: Equatable {
        var id: String
        var layerPosition: LayerPosition?
        var clusterOptions: ClusterOptions?
    }
    let makePointAnnotationManagerStub = Stub<MakePointAnnotationManagerParams, AnnotationManagerInternal>(
        defaultReturnValue: PointAnnotationManager(
            id: "test",
            style: MockStyle(),
            layerPosition: .default,
            displayLink: Signal { _ in .empty },
            mapFeatureQueryable: MockMapFeatureQueryable(),
            imagesManager: MockAnnotationImagesManager(),
            offsetCalculator: .init(mapboxMap: MockMapboxMap())
        )
    )
    func makePointAnnotationManager(
        id: String,
        layerPosition: LayerPosition?,
        clusterOptions: ClusterOptions?) -> AnnotationManagerInternal {
            return makePointAnnotationManagerStub.call(with: MakePointAnnotationManagerParams(
                id: id,
                layerPosition: layerPosition,
                clusterOptions: clusterOptions))
        }

    struct MakePolygonAnnotationManagerParams: Equatable {
        var id: String
        var layerPosition: LayerPosition?
    }
    let makePolygonAnnotationManagerStub = Stub<MakePolygonAnnotationManagerParams, AnnotationManagerInternal>(
        defaultReturnValue: PolygonAnnotationManager(
            id: "test",
            style: MockStyle(),
            layerPosition: .default,
            displayLink: Signal { _ in .empty },
            offsetCalculator: .init(mapboxMap: MockMapboxMap())))
    func makePolygonAnnotationManager(
        id: String,
        layerPosition: LayerPosition?) -> AnnotationManagerInternal {
            return makePolygonAnnotationManagerStub.call(with: MakePolygonAnnotationManagerParams(
                id: id,
                layerPosition: layerPosition))
        }

    struct MakePolylineAnnotationManagerParams: Equatable {
        var id: String
        var layerPosition: LayerPosition?
    }
    let makePolylineAnnotationManagerStub = Stub<MakePolylineAnnotationManagerParams, AnnotationManagerInternal>(
        defaultReturnValue: PolylineAnnotationManager(
            id: "test",
            style: MockStyle(),
            layerPosition: .default,
            displayLink: Signal { _ in .empty },
            offsetCalculator: .init(mapboxMap: MockMapboxMap())))
    func makePolylineAnnotationManager(
        id: String,
        layerPosition: LayerPosition?) -> AnnotationManagerInternal {
            return makePolylineAnnotationManagerStub.call(with: MakePolylineAnnotationManagerParams(
                id: id,
                layerPosition: layerPosition))
        }

    struct MakeCircleAnnotationManagerParams: Equatable {
        var id: String
        var layerPosition: LayerPosition?
    }
    let makeCircleAnnotationManagerStub = Stub<MakeCircleAnnotationManagerParams, AnnotationManagerInternal>(
        defaultReturnValue: CircleAnnotationManager(
            id: "test",
            style: MockStyle(),
            layerPosition: .default,
            displayLink: Signal { _ in .empty },
            offsetCalculator: .init(mapboxMap: MockMapboxMap())))
    func makeCircleAnnotationManager(
        id: String,
        layerPosition: LayerPosition?) -> AnnotationManagerInternal {
            return makeCircleAnnotationManagerStub.call(with: MakeCircleAnnotationManagerParams(
                id: id,
                layerPosition: layerPosition))
        }

    let removeAnnotationManagerStub = Stub<String, Void>()
    func removeAnnotationManager(withId id: String) {
        removeAnnotationManagerStub.call(with: id)}
}
