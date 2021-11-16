import MapboxCoreMaps
@_implementationOnly import MapboxCoreMaps_Private

internal protocol DelegatingViewAnnotationPositionsUpdateListenerDelegate: AnyObject {
    func onViewAnnotationPositionsUpdate(forPositions positions: [ViewAnnotationPositionDescriptor])
}

internal final class DelegatingViewAnnotationPositionsUpdateListener: ViewAnnotationPositionsUpdateListener {
    internal weak var delegate: DelegatingViewAnnotationPositionsUpdateListenerDelegate?

    internal func onViewAnnotationPositionsUpdate(forPositions positions: [ViewAnnotationPositionDescriptor]) {
        delegate?.onViewAnnotationPositionsUpdate(forPositions: positions)
    }
}
