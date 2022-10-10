import Foundation
import MapboxCoreMaps.CoordinateBounds
import Turf

internal protocol CoordinateBoundsAnimator {
    func show(coordinateBounds: CoordinateBounds, padding: UIEdgeInsets, pitch: CGFloat, animationDuration: TimeInterval)
}

extension Viewport: CoordinateBoundsAnimator {

    func show(coordinateBounds: CoordinateBounds, padding: UIEdgeInsets, pitch: CGFloat, animationDuration: TimeInterval) {
        let geometry = MultiPoint([
            coordinateBounds.southwest,
            coordinateBounds.northwest,
            coordinateBounds.northeast,
            coordinateBounds.southeast,
        ])
        let viewportOptions = OverviewViewportStateOptions(geometry: geometry, padding: padding, pitch: pitch, animationDuration: animationDuration)
        let viewportState = makeOverviewViewportState(options: viewportOptions)
        transition(to: viewportState)
    }
}
