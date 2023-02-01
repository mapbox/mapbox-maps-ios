import UIKit

internal protocol AnnotationManagerFactoryProtocol: AnyObject {
    func makePointAnnotationManager(
        id: String,
        layerPosition: LayerPosition?,
        clusterOptions: ClusterOptions?
    ) -> AnnotationManagerInternal

    func makePolygonAnnotationManager(
        id: String,
        layerPosition: LayerPosition?
    ) -> AnnotationManagerInternal

    func makePolylineAnnotationManager(
        id: String,
        layerPosition: LayerPosition?
    ) -> AnnotationManagerInternal

    func makeCircleAnnotationManager(
        id: String,
        layerPosition: LayerPosition?
    ) -> AnnotationManagerInternal
}

internal final class AnnotationManagerFactory: AnnotationManagerFactoryProtocol {
    private let style: StyleProtocol
    private weak var displayLinkCoordinator: DisplayLinkCoordinator?
    private let offsetPointCalculator: OffsetPointCalculator
    private let offsetPolygonCalculator: OffsetPolygonCalculator
    private let offsetLineStringCalculator: OffsetLineStringCalculator

    private lazy var imagesManager = AnnotationImagesManager(style: style)

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
        layerPosition: LayerPosition?,
        clusterOptions: ClusterOptions?) -> AnnotationManagerInternal {
            guard let displayLinkCoordinator = displayLinkCoordinator else {
                fatalError("DisplayLinkCoordinator must be present when creating an annotation manager")
            }
            return PointAnnotationManager(
                id: id,
                style: style,
                layerPosition: layerPosition,
                displayLinkCoordinator: displayLinkCoordinator,
                clusterOptions: clusterOptions,
                imagesManager: imagesManager,
                offsetPointCalculator: offsetPointCalculator)
        }

    internal func makePolygonAnnotationManager(
        id: String,
        layerPosition: LayerPosition?) -> AnnotationManagerInternal {
            guard let displayLinkCoordinator = displayLinkCoordinator else {
                fatalError("DisplayLinkCoordinator must be present when creating an annotation manager")
            }
            return PolygonAnnotationManager(
                id: id,
                style: style,
                layerPosition: layerPosition,
                displayLinkCoordinator: displayLinkCoordinator,
                offsetPolygonCalculator: offsetPolygonCalculator)
        }

    internal func makePolylineAnnotationManager(
        id: String,
        layerPosition: LayerPosition?) -> AnnotationManagerInternal {
            guard let displayLinkCoordinator = displayLinkCoordinator else {
                fatalError("DisplayLinkCoordinator must be present when creating an annotation manager")
            }
            return PolylineAnnotationManager(
                id: id,
                style: style,
                layerPosition: layerPosition,
                displayLinkCoordinator: displayLinkCoordinator,
                offsetLineStringCalculator: offsetLineStringCalculator)
        }

    internal func makeCircleAnnotationManager(
        id: String,
        layerPosition: LayerPosition?) -> AnnotationManagerInternal {
            guard let displayLinkCoordinator = displayLinkCoordinator else {
                fatalError("DisplayLinkCoordinator must be present when creating an annotation manager")
            }
            return CircleAnnotationManager(
                id: id,
                style: style,
                layerPosition: layerPosition,
                displayLinkCoordinator: displayLinkCoordinator,
                offsetPointCalculator: offsetPointCalculator)
        }
}
