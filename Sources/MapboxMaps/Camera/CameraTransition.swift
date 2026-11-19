import UIKit
import CoreLocation
@_spi(Experimental) import MapboxCoreMaps

/// Structure used to represent a desired change to the map's camera
public struct CameraTransition: Equatable, Sendable {

    /// Represents a change to the center coordinate of the map.
    /// NOTE: Setting the `toValue` of `center` overrides any `anchor` animations
    public var center: Change<CLLocationCoordinate2D>

    /// Represents a change to the zoom of the map.
    public var zoom: Change<CGFloat>

    /// Represents a change to the padding of the map.
    public var padding: Change<UIEdgeInsets>

    /// Represents a change to the anchor of the map
    /// NOTE: Incompatible with concurrent center animations
    public var anchor: Change<CGPoint>

    /// Represents a change to the bearing of the map.
    public var bearing: Change<CLLocationDirection>

    /// Ensures that bearing transitions are optimized to take the shortest path. Defaults to `true`.
    public var shouldOptimizeBearingPath: Bool = true

    /// Represents a change to the pitch of the map.
    public var pitch: Change<CGFloat>

    /// Represents a change to the vertical field of view of the map.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var verticalFov: Change<CGFloat>

    /// Represents a change to the position point of the map, with `x` and `y` of the point in the `-1...1` range.
    ///
    /// - SeeAlso: ``CameraPositionPoint``
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var positionPoint: Change<CGPoint>

    /// Represents a change to the view point of the map.
    ///
    /// - SeeAlso: ``CameraViewPointState``
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var viewPoint: Change<CameraViewPointState>

    /// Generic struct used to represent a change in a value from a starting point (i.e. `fromValue`) to an end point (i.e. `toValue`).
    public struct Change<T>: Equatable where T: Equatable {
        public var fromValue: T
        public var toValue: T?

        init(fromValue: T, toValue: T? = nil) {
            self.fromValue = fromValue
            self.toValue = toValue
        }
    }

    internal init(cameraState: CameraState, initialAnchor: CGPoint) {
        center  = Change(fromValue: cameraState.center)
        zoom    = Change(fromValue: cameraState.zoom)
        padding = Change(fromValue: cameraState.padding)
        pitch   = Change(fromValue: cameraState.pitch)
        bearing = Change(fromValue: cameraState.bearing)
        anchor  = Change(fromValue: initialAnchor)
        verticalFov = Change(fromValue: cameraState.verticalFov)
        positionPoint = Change(fromValue: CGPoint(x: cameraState.positionPoint.x, y: cameraState.positionPoint.y))
        viewPoint = Change(fromValue: cameraState.viewPoint)
    }

    internal var toCameraOptions: CameraOptions {
        var options = CameraOptions(
            center: center.toValue,
            padding: padding.toValue,
            anchor: anchor.toValue,
            zoom: zoom.toValue,
            bearing: shouldOptimizeBearingPath ? optimizedBearingToValue : bearing.toValue,
            pitch: pitch.toValue,
            verticalFov: verticalFov.toValue)
        options.positionPoint = positionPoint.toValue.map(CameraPositionPoint.init(_:))
        options.viewPoint = viewPoint.toValue
        return options
    }

    internal var fromCameraOptions: CameraOptions {
        var options = CameraOptions(
            center: center.fromValue,
            padding: padding.fromValue,
            anchor: anchor.fromValue,
            zoom: zoom.fromValue,
            bearing: bearing.fromValue,
            pitch: pitch.fromValue,
            verticalFov: verticalFov.fromValue)
        options.positionPoint = CameraPositionPoint(positionPoint.fromValue)
        options.viewPoint = viewPoint.fromValue
        return options
    }

    internal var optimizedBearingToValue: CLLocationDirection? {

        // If `bearing.toValue` is nil, then return nil.
        guard let toBearing = bearing.toValue?.truncatingRemainder(dividingBy: 360.0) else {
            return nil
        }

        let fromBearing = bearing.fromValue

        // 180 degrees is the max the map should rotate, therefore if the difference between the end and start point is
        // more than 180 we need to go the opposite direction
        if toBearing - fromBearing >= 180 {
            return toBearing - 360
        }

        // This is the inverse of the above, accounting for negative bearings
        if toBearing - fromBearing <= -180 {
            return toBearing + 360
        }

        return toBearing

    }

}

extension CameraTransition.Change: Sendable where T: Sendable {}

extension CameraPositionPoint {
    init(_ point: CGPoint) {
        self.init(x: Double(point.x), y: Double(point.y))
    }
}

extension CameraPositionPoint {
    /// The core rejects a camera whose position point lies outside `-1...1`.
    var clampedToUnitSquare: CameraPositionPoint {
        CameraPositionPoint(x: x.clamped(to: -1...1), y: y.clamped(to: -1...1))
    }
}

extension CameraViewPoint {
    /// The core rejects a camera whose view point lies outside `-1...1`.
    var clampedToUnitSquare: CameraViewPoint {
        CameraViewPoint(x: x.clamped(to: -1...1), y: y.clamped(to: -1...1))
    }

    /// The view point that a camera following its position point has, in the same units as `padding` and `size`.
    ///
    /// Each axis is clamped to `-1...1`, as padding can push the position point out of the viewport.
    init(followingPositionPoint positionPoint: CameraPositionPoint, padding: UIEdgeInsets, size: CGSize) {
        guard size.width > 0, size.height > 0 else {
            self.init(x: 0, y: 0)
            return
        }
        let halfWidth = Double(size.width - padding.left - padding.right) / 2
        let halfHeight = Double(size.height - padding.top - padding.bottom) / 2
        let pointX = Double(padding.left) + halfWidth + positionPoint.x * halfWidth
        let pointY = Double(padding.top) + halfHeight + positionPoint.y * halfHeight
        self.init(
            x: (pointX * 2 / Double(size.width) - 1).clamped(to: -1...1),
            y: (pointY * 2 / Double(size.height) - 1).clamped(to: -1...1))
    }
}

/// The path of the view point over an animation, evaluated for a fraction of its progress.
///
/// A following view point depends on padding and position point, which the animation changes as well. The path
/// therefore ends at the following view point of the target camera, and the camera is switched to its final
/// state when the animation ends.
internal struct ViewPointPath: Equatable {
    struct CameraParameters: Equatable {
        var positionPoint: CameraPositionPoint
        var padding: UIEdgeInsets
    }

    var from: CameraViewPoint
    var to: CameraViewPoint
    /// The state to apply when a reversed animation ends at its start.
    var initialState: CameraViewPointState
    /// The state to apply when the animation ends.
    var finalState: CameraViewPointState

    /// True if the animation hands the view point back to the position point.
    var releasesViewPoint: Bool { finalState == .followsPositionPoint }

    /// Returns nil if there is nothing to animate.
    init?(from fromState: CameraViewPointState,
          to toState: CameraViewPointState?,
          fromCamera: CameraParameters,
          toCamera: CameraParameters,
          size: CGSize) {
        guard let toState, fromState != .followsPositionPoint || toState != .followsPositionPoint else {
            return nil
        }
        func resolve(_ state: CameraViewPointState, _ camera: CameraParameters) -> CameraViewPoint {
            switch state {
            case .followsPositionPoint:
                return CameraViewPoint(followingPositionPoint: camera.positionPoint, padding: camera.padding, size: size)
            case .viewPoint(let point):
                return point
            @unknown default:
                return CameraViewPoint(followingPositionPoint: camera.positionPoint, padding: camera.padding, size: size)
            }
        }
        from = resolve(fromState, fromCamera).clampedToUnitSquare
        to = resolve(toState, toCamera).clampedToUnitSquare
        initialState = Self.endState(fromState, resolved: from)
        finalState = Self.endState(toState, resolved: to)
    }

    private static func endState(_ state: CameraViewPointState, resolved point: CameraViewPoint) -> CameraViewPointState {
        switch state {
        case .followsPositionPoint:
            return .followsPositionPoint
        case .viewPoint:
            return .viewPoint(point)
        @unknown default:
            return state
        }
    }

    /// The state to apply when the animation ends at `position`; nil when it was cancelled.
    func state(at position: UIViewAnimatingPosition) -> CameraViewPointState? {
        switch position {
        case .start:
            return initialState
        case .end:
            return finalState
        case .current:
            return nil
        @unknown default:
            return finalState
        }
    }

    /// Timing curves can overshoot, and the core rejects points outside the unit square.
    func point(at fraction: Double) -> CameraViewPoint {
        CameraViewPoint(
            x: (1 - fraction) * from.x + fraction * to.x,
            y: (1 - fraction) * from.y + fraction * to.y
        ).clampedToUnitSquare
    }
}
