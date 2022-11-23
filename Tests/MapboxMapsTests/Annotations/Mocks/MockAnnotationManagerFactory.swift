@testable import MapboxMaps

internal final class MockAnnotationManagerFactory: AnnotationManagerFactoryProtocol {

    struct MakePolygonAnnotationManagerParams {
        var id: String
        var style: StyleProtocol
        var layerPosition: LayerPosition?
        var displayLinkCoordinator: DisplayLinkCoordinator
        var offsetPolygonCalculator: OffsetPolygonCalculator
    }
    let makePolygonAnnotationManagerStub = Stub<Void, AnnotationManagerInternal>(defaultReturnValue: MockAnnotationManager())
    internal func makePolygonAnnotationManager(
        id: String,
        style: StyleProtocol,
        layerPosition: LayerPosition?,
        displayLinkCoordinator: DisplayLinkCoordinator,
        offsetPolygonCalculator: OffsetPolygonCalculator
    ) -> AnnotationManagerInternal {
        return makePolygonAnnotationManagerStub.call(with: MakePolygonAnnotationManagerParams(id: id, style: style, layerPosition: layerPosition!, displayLinkCoordinator: displayLinkCoordinator, offsetPolygonCalculator: offsetPolygonCalculator))
    }

    internal final class AnnotationManagerFactory: AnnotationManagerFactoryProtocol {

        internal func makePolygonAnnotationManager(
            id: String,
            style: StyleProtocol,
            layerPosition: LayerPosition?,
            displayLinkCoordinator: DisplayLinkCoordinator,
            offsetPolygonCalculator: OffsetPolygonCalculator
        ) -> AnnotationManagerInternal {
            return PolygonAnnotationManager(
                id: id,
                style: style,
                layerPosition: layerPosition,
                displayLinkCoordinator: displayLinkCoordinator,
                offsetPolygonCalculator: offsetPolygonCalculator)
        }
    }
}
