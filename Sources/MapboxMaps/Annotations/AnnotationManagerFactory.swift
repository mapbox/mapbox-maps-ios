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
    private var displayLink: Signal<Void>
    private let style: StyleProtocol
    private let offsetPointCalculator: OffsetPointCalculator
    private let offsetPolygonCalculator: OffsetPolygonCalculator
    private let offsetLineStringCalculator: OffsetLineStringCalculator
    private let mapFeatureQueryable: MapFeatureQueryable

    private lazy var imagesManager = AnnotationImagesManager(style: style)

    internal init(
        style: StyleProtocol,
        displayLink: Signal<Void>,
        offsetPointCalculator: OffsetPointCalculator,
        offsetPolygonCalculator: OffsetPolygonCalculator,
        offsetLineStringCalculator: OffsetLineStringCalculator,
        mapFeatureQueryable: MapFeatureQueryable
    ) {
        self.style = style
        self.displayLink = displayLink
        self.offsetPointCalculator = offsetPointCalculator
        self.offsetPolygonCalculator = offsetPolygonCalculator
        self.offsetLineStringCalculator = offsetLineStringCalculator
        self.mapFeatureQueryable = mapFeatureQueryable
    }

    internal func makePointAnnotationManager(
        id: String,
        layerPosition: LayerPosition?,
        clusterOptions: ClusterOptions?) -> AnnotationManagerInternal {
            return PointAnnotationManager(
                id: id,
                style: style,
                layerPosition: layerPosition,
                displayLink: displayLink,
                clusterOptions: clusterOptions,
                mapFeatureQueryable: mapFeatureQueryable,
                imagesManager: imagesManager,
                offsetCalculator: offsetPointCalculator)
        }

    internal func makePolygonAnnotationManager(
        id: String,
        layerPosition: LayerPosition?) -> AnnotationManagerInternal {
            return PolygonAnnotationManager(
                id: id,
                style: style,
                layerPosition: layerPosition,
                displayLink: displayLink,
                offsetCalculator: offsetPolygonCalculator)
        }

    internal func makePolylineAnnotationManager(
        id: String,
        layerPosition: LayerPosition?) -> AnnotationManagerInternal {
            return PolylineAnnotationManager(
                id: id,
                style: style,
                layerPosition: layerPosition,
                displayLink: displayLink,
                offsetCalculator: offsetLineStringCalculator)
        }

    internal func makeCircleAnnotationManager(
        id: String,
        layerPosition: LayerPosition?) -> AnnotationManagerInternal {
            return CircleAnnotationManager(
                id: id,
                style: style,
                layerPosition: layerPosition,
                displayLink: displayLink,
                offsetCalculator: offsetPointCalculator)
        }
}
