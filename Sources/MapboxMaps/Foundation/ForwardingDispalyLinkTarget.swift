import QuartzCore

internal final class ForwardingDisplayLinkTarget {
    private let mapView: Unmanaged<MapView>
    private var invalidated = false

    internal init(mapView: MapView) {
        self.mapView = Unmanaged.passUnretained(mapView)
    }

    internal func invalidate() {
        invalidated = true
    }

    @objc internal func update(with displayLink: CADisplayLink) {
        guard invalidated == false else { return }
        mapView._withUnsafeGuaranteedRef { $0.update(with: displayLink) }
    }
}
