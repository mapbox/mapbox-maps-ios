@testable import MapboxMaps

internal final class MockAnnotationManagerFactory: AnnotationManagerFactoryProtocol {
    struct MakePointAnnotationManagerParams {
        var id: String
        var style: StyleProtocol
        var layerPosition: LayerPosition?
        var displayLinkCoordinator: DisplayLinkCoordinator
        var clusterOptions: ClusterOptions?
        var offsetPointCalculator: OffsetPointCalculator
    }
    let makePointAnnotationManagerStub = Stub<MakePointAnnotationManagerParams, AnnotationManagerInternal>(defaultReturnValue: MockAnnotationManager())
    func makePointAnnotationManager(
        id: String,
        style: StyleProtocol,
        layerPosition: LayerPosition?,
        displayLinkCoordinator: DisplayLinkCoordinator,
        clusterOptions: ClusterOptions?,
        offsetPointCalculator: OffsetPointCalculator) -> AnnotationManagerInternal {
        return makePointAnnotationManagerStub.call(with: MakePointAnnotationManagerParams(
            id: id,
            style: style,
            layerPosition: layerPosition,
            displayLinkCoordinator: displayLinkCoordinator,
            clusterOptions: clusterOptions,
            offsetPointCalculator: offsetPointCalculator))
    }

    struct MakePolylineAnnotationManagerParams {
        var id: String
        var style: StyleProtocol
        var layerPosition: LayerPosition?
        var displayLinkCoordinator: DisplayLinkCoordinator
        var offsetLineStringCalculator: OffsetLineStringCalculator
    }
    let makePolylineAnnotationManagerStub = Stub<MakePolylineAnnotationManagerParams, AnnotationManagerInternal>(defaultReturnValue: MockAnnotationManager())
    func makePolylineAnnotationManager(
        id: String,
        style: StyleProtocol,
        layerPosition: LayerPosition?,
        displayLinkCoordinator: DisplayLinkCoordinator,
        offsetLineStringCalculator: OffsetLineStringCalculator) -> AnnotationManagerInternal {
            return makePolylineAnnotationManagerStub.call(with: MakePolylineAnnotationManagerParams(
                id: id,
                style: style,
                layerPosition: layerPosition,
                displayLinkCoordinator: displayLinkCoordinator,
                offsetLineStringCalculator: offsetLineStringCalculator))
    }

    struct MakeCircleAnnotationManagerParams {
        var id: String
        var style: StyleProtocol
        var layerPosition: LayerPosition?
        var displayLinkCoordinator: DisplayLinkCoordinator
        var offsetPointCalculator: OffsetPointCalculator
    }
    let makeCircleAnnotationManagerStub = Stub<MakeCircleAnnotationManagerParams, AnnotationManagerInternal>(defaultReturnValue: MockAnnotationManager())
    func makeCircleAnnotationManager(
        id: String,
        style: StyleProtocol,
        layerPosition: LayerPosition?,
        displayLinkCoordinator: DisplayLinkCoordinator,
        offsetPointCalculator: OffsetPointCalculator) -> AnnotationManagerInternal {
        return makeCircleAnnotationManagerStub.call(with: MakeCircleAnnotationManagerParams(
            id: id,
            style: style,
            layerPosition: layerPosition,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPointCalculator: offsetPointCalculator))
    }

    struct MakePolygonAnnotationManagerParams {
        var id: String
        var style: StyleProtocol
        var layerPosition: LayerPosition?
        var displayLinkCoordinator: DisplayLinkCoordinator
        var offsetPolygonCalculator: OffsetPolygonCalculator
    }
    let makePolygonAnnotationManagerStub = Stub<MakePolygonAnnotationManagerParams, AnnotationManagerInternal>(defaultReturnValue: MockAnnotationManager())
    internal func makePolygonAnnotationManager(
        id: String,
        style: StyleProtocol,
        layerPosition: LayerPosition?,
        displayLinkCoordinator: DisplayLinkCoordinator,
        offsetPolygonCalculator: OffsetPolygonCalculator
    ) -> AnnotationManagerInternal {
        return makePolygonAnnotationManagerStub.call(with: MakePolygonAnnotationManagerParams(
            id: id,
            style: style,
            layerPosition: layerPosition,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPolygonCalculator: offsetPolygonCalculator))
    }
}
