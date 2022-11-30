import UIKit

internal protocol AnnotationManagerFactoryProtocol: AnyObject {
    func makePointAnnotationManager(
        id: String,
        style: StyleProtocol,
        layerPosition: LayerPosition?,
        displayLinkCoordinator: DisplayLinkCoordinator,
        clusterOptions: ClusterOptions?,
        offsetPointCalculator: OffsetPointCalculator
    ) -> AnnotationManagerInternal

    func makePolygonAnnotationManager(
        id: String,
        style: StyleProtocol,
        layerPosition: LayerPosition?,
        displayLinkCoordinator: DisplayLinkCoordinator,
        offsetPolygonCalculator: OffsetPolygonCalculator
    ) -> AnnotationManagerInternal

    func makePolylineAnnotationManager(
        id: String,
        style: StyleProtocol,
        layerPosition: LayerPosition?,
        displayLinkCoordinator: DisplayLinkCoordinator,
        offsetLineStringCalculator: OffsetLineStringCalculator
    ) -> AnnotationManagerInternal

    func makeCircleAnnotationManager(
        id: String,
        style: StyleProtocol,
        layerPosition: LayerPosition?,
        displayLinkCoordinator: DisplayLinkCoordinator,
        offsetPointCalculator: OffsetPointCalculator
    ) -> AnnotationManagerInternal
}

internal final class AnnotationManagerFactory: AnnotationManagerFactoryProtocol {
    // add instance variables here for style, displaylinkCoordinator and calculators

    private let style: StyleProtocol
    private let displayLinkCoordinator: DisplayLinkCoordinator
    private let offsetPointCalculator: OffsetPointCalculator
    private let offsetPolygonCalculator: OffsetPolygonCalculator
    private let offsetLineStringCalculator: OffsetLineStringCalculator

    internal init(style: StyleProtocol,
                  displayLinkCoordinator: DisplayLinkCoordinator,
                  offsetPointCalculator: OffsetPointCalculator,
                  offsetPolygonCalculator: OffsetPolygonCalculator,
                  offsetLineStringCalculator: OffsetLineStringCalculator) {
        self.style = style
        self.displayLinkCoordinator = displayLinkCoordinator
        self.offsetPointCalculator = offsetPointCalculator
        self.offsetPolygonCalculator = offsetPolygonCalculator
        self.offsetLineStringCalculator = offsetLineStringCalculator
    }

    internal func makePointAnnotationManager(
        id: String,
        style: StyleProtocol,
        layerPosition: LayerPosition?,
        displayLinkCoordinator: DisplayLinkCoordinator,
        clusterOptions: ClusterOptions?,
        offsetPointCalculator: OffsetPointCalculator) -> AnnotationManagerInternal {
            return PointAnnotationManager(
                id: id,
                style: style,
                layerPosition: layerPosition,
                displayLinkCoordinator: displayLinkCoordinator,
                offsetPointCalculator: offsetPointCalculator)
        }

    internal func makePolygonAnnotationManager(
        id: String,
        style: StyleProtocol,
        layerPosition: LayerPosition?,
        displayLinkCoordinator: DisplayLinkCoordinator,
        offsetPolygonCalculator: OffsetPolygonCalculator) -> AnnotationManagerInternal {
            return PolygonAnnotationManager(
                id: id,
                style: style,
                layerPosition: layerPosition,
                displayLinkCoordinator: displayLinkCoordinator,
                offsetPolygonCalculator: offsetPolygonCalculator)
        }

    internal func makePolylineAnnotationManager(
        id: String,
        style: StyleProtocol,
        layerPosition: LayerPosition?,
        displayLinkCoordinator: DisplayLinkCoordinator,
        offsetLineStringCalculator: OffsetLineStringCalculator) -> AnnotationManagerInternal {
            return PolylineAnnotationManager(
                id: id,
                style: style,
                layerPosition: layerPosition,
                displayLinkCoordinator: displayLinkCoordinator,
                offsetLineStringCalculator: offsetLineStringCalculator)
        }

    internal func makeCircleAnnotationManager(
        id: String,
        style: StyleProtocol,
        layerPosition: LayerPosition?,
        displayLinkCoordinator: DisplayLinkCoordinator,
        offsetPointCalculator: OffsetPointCalculator) -> AnnotationManagerInternal {
            return CircleAnnotationManager(
                id: id,
                style: style,
                layerPosition: layerPosition,
                displayLinkCoordinator: displayLinkCoordinator,
                offsetPointCalculator: offsetPointCalculator)
        }
}
