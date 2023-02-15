import MapboxCoreMaps
@_implementationOnly import MapboxCoreMaps_Private

/// :nodoc:
@_spi(Package)
public typealias ViewAnnotationPositionsUpdateCallback = ([ViewAnnotationPositionDescriptor]) -> Void

internal final class ViewAnnotationPositionsUpdateListenerImpl: ViewAnnotationPositionsUpdateListener {
    private let callback: ViewAnnotationPositionsUpdateCallback
    init(callback: @escaping ViewAnnotationPositionsUpdateCallback) {
        self.callback = callback
    }

    internal func onViewAnnotationPositionsUpdate(forPositions positions: [ViewAnnotationPositionDescriptor]) {
        callback(positions)
    }
}
