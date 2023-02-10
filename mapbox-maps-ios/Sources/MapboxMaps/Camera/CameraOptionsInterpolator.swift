import CoreLocation
import UIKit

internal protocol CameraOptionsInterpolatorProtocol: AnyObject {
    func interpolate(from: CameraOptions,
                     to: CameraOptions,
                     fraction: Double) -> CameraOptions
}

internal final class CameraOptionsInterpolator: CameraOptionsInterpolatorProtocol {
    private let optionalInterpolator = OptionalInterpolator()
    private let coordinateInterpolator: CoordinateInterpolatorProtocol
    private let uiEdgeInsetsInterpolator: UIEdgeInsetsInterpolatorProtocol
    private let doubleInterpolator: DoubleInterpolatorProtocol
    private let directionInterpolator: DirectionInterpolatorProtocol

    internal init(coordinateInterpolator: CoordinateInterpolatorProtocol,
                  uiEdgeInsetsInterpolator: UIEdgeInsetsInterpolatorProtocol,
                  doubleInterpolator: DoubleInterpolatorProtocol,
                  directionInterpolator: DirectionInterpolatorProtocol) {
        self.coordinateInterpolator = coordinateInterpolator
        self.uiEdgeInsetsInterpolator = uiEdgeInsetsInterpolator
        self.doubleInterpolator = doubleInterpolator
        self.directionInterpolator = directionInterpolator
    }

    internal func interpolate(from: CameraOptions,
                              to: CameraOptions,
                              fraction: Double) -> CameraOptions {
        let center = optionalInterpolator.interpolate(
            from: from.center,
            to: to.center,
            fraction: fraction,
            interpolate: coordinateInterpolator.interpolate(from:to:fraction:))

        let padding = optionalInterpolator.interpolate(
            from: from.padding,
            to: to.padding,
            fraction: fraction,
            interpolate: uiEdgeInsetsInterpolator.interpolate(from:to:fraction:))

        let zoom = optionalInterpolator.interpolate(
            from: from.zoom.map(Double.init(_:)),
            to: to.zoom.map(Double.init(_:)),
            fraction: fraction,
            interpolate: doubleInterpolator.interpolate(from:to:fraction:))

        let bearing = optionalInterpolator.interpolate(
            from: from.bearing,
            to: to.bearing,
            fraction: fraction,
            interpolate: directionInterpolator.interpolate(from:to:fraction:))

        let pitch = optionalInterpolator.interpolate(
            from: from.pitch.map(Double.init(_:)),
            to: to.pitch.map(Double.init(_:)),
            fraction: fraction,
            interpolate: doubleInterpolator.interpolate(from:to:fraction:))

        return CameraOptions(
            center: center,
            padding: padding,
            anchor: nil,
            zoom: zoom.map(CGFloat.init(_:)),
            bearing: bearing,
            pitch: pitch.map(CGFloat.init(_:)))
    }
}
