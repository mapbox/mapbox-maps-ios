import Foundation
import MapboxCoreMaps.CoordinateBounds
import Turf

internal protocol CoordinateBoundsAnimator {
    /// Animates to the camera covering the area defined by `coordinateBounds` and `padding`.
    ///
    /// - Parameter coordinateBounds: The area to be framed and animate to.
    /// - Parameter padding: The inset from the edges of the map.
    /// - Parameter pitch: Pitch toward the horizon measured in degrees.
    /// - Parameter animationDuration: Duration to perform the animation.
    func show(coordinateBounds: CoordinateBounds, padding: UIEdgeInsets, pitch: CGFloat?, animationDuration: TimeInterval)
}

extension Viewport: CoordinateBoundsAnimator {

    func show(coordinateBounds: CoordinateBounds, padding: UIEdgeInsets, pitch: CGFloat?, animationDuration: TimeInterval) {
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
