@_spi(Package) import MapboxMaps
@_implementationOnly import MapboxCoreMaps_Private

@available(iOS 13.0, *)
final class ViewAnnotationsProvider: ObservableObject, ViewAnnotationPositionsUpdateListener {
    struct VisibleAnnotation: Identifiable {
        let id: String
        let frame: CGRect
    }

    /// List of ``ViewAnnotation`` visible in current map's bounds.
    @Published private(set) var visibleAnnotations: [VisibleAnnotation] = []

    func onViewAnnotationPositionsUpdate(forPositions positions: [ViewAnnotationPositionDescriptor]) {
        visibleAnnotations = positions.compactMap { position in
            return VisibleAnnotation(
                id: position.identifier,
                frame: CGRect(
                    x: position.leftTopCoordinate.x,
                    y: position.leftTopCoordinate.y,
                    width: CGFloat(position.width),
                    height: CGFloat(position.height))
            )
        }
    }

    func connect(to map: MapboxMap) {
        map.setViewAnnotationPositionsUpdateListener(self)
    }
}
