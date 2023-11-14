import MapboxCoreMaps

typealias ViewAnnotationPositionsUpdateCallback = ([ViewAnnotationPositionDescriptor]) -> Void

internal final class ViewAnnotationPositionsUpdateListenerImpl: CoreViewAnnotationPositionsUpdateListener {
    private let callback: ViewAnnotationPositionsUpdateCallback
    init(callback: @escaping ViewAnnotationPositionsUpdateCallback) {
        self.callback = callback
    }

    internal func onViewAnnotationPositionsUpdate(forPositions positions: [ViewAnnotationPositionDescriptor]) {
        callback(positions)
    }
}
