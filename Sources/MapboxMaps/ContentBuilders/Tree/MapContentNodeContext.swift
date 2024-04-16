import UIKit

struct MapContentStyleDependencies {
    var styleManager: StyleManagerProtocol
    var sourceManager: StyleSourceManagerProtocol
}

struct MapContentDependencies {
    let layerAnnotations: Ref<AnnotationOrchestrator?>
    let viewAnnotations: Ref<ViewAnnotationManager?>
    let location: Ref<LocationManager?>

    let addAnnotationViewController: (UIViewController) -> Void
    let removeAnnotationViewController: (UIViewController) -> Void
}

final class MapContentNodeContext {
    var content: MapContentDependencies?
    let style: MapContentStyleDependencies
    var isEqualContent: (Any, Any) -> Bool

    var lastLayerId: String?
    var initialStyleLayers: [String] = []
    var uniqueProperties = MapContentUniqueProperties()

    init(
        styleManager: StyleManagerProtocol,
        sourceManager: StyleSourceManagerProtocol,
        isEqualContent: @escaping (Any?, Any?) -> Bool
    ) {
        self.style = MapContentStyleDependencies(styleManager: styleManager, sourceManager: sourceManager)
        self.isEqualContent = isEqualContent
    }

    func resolveLayerPosition() -> LayerPosition {
        if let lastLayerId {
            return .above(lastLayerId)
        }

        let lastStyleLayer = initialStyleLayers.last(where: style.styleManager.styleLayerExists)
        return lastStyleLayer.map { .above($0) } ?? .at(0)
    }
}
