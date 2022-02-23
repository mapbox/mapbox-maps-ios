import UIKit

/// Options used to configure the direction in which the map is allowed to move
/// during a pan gesture. Called `ScrollMode` in the Android SDK for
/// consistency with platform conventions.
public enum PanMode: String, Equatable, CaseIterable {
    /// The map may only move horizontally.
    case horizontal

    /// The map may only move vertically.
    case vertical

    /// The map may move both horizontally and vertically.
    case horizontalAndVertical
}

/// Configuration options for the built-in gestures
public struct GestureOptions: Equatable {

    /// Whether the single-touch pan gesture is enabled. Defaults to `true`.
    public var panEnabled: Bool = true

    /// Whether the pinch gesture is enabled. Allows panning, rotating, and zooming.
    /// Defaults to `true`.
    public var pinchEnabled: Bool = true

    /// Whether rotation is enabled for the pinch gesture.
    /// Defaults to `true`.
    public var pinchRotateEnabled: Bool = true

    /// Whether zoom is enabled for the pinch gesture.
    /// Defaults to `true`.
    public var pinchZoomEnabled: Bool = true

    /// Whether pan is enabled for the pinch gesture.
    /// Defaults to `true`.
    public var pinchPanEnabled: Bool = true

    /// Whether the pitch gesture is enabled. Defaults to `true`.
    public var pitchEnabled: Bool = true

    /// Whether double tapping the map with one touch results in a zoom-in animation.
    /// Defaults to `true`.
    public var doubleTapToZoomInEnabled: Bool = true

    /// Whether single tapping the map with two touches results in a zoom-out animation.
    /// Defaults to `true`.
    public var doubleTouchToZoomOutEnabled: Bool = true

    /// Whether the quick zoom gesture is enabled. Defaults to `true`.
    public var quickZoomEnabled: Bool = true

    /// Configures the directions in which the map is allowed to move during a pan gesture.
    /// Defaults to `PanMode.horizontalAndVertical`. Called `scrollMode` in
    /// the Android SDK for consistency with platform conventions.
    public var panMode: PanMode = .horizontalAndVertical

    /// A constant factor that determines how quickly pan deceleration animations happen.
    /// Multiplied with the velocity vector once per millisecond during deceleration animations.
    /// Defaults to `UIScrollView.DecelerationRate.normal.rawValue`
    public var panDecelerationFactor: CGFloat = UIScrollView.DecelerationRate.normal.rawValue

    /// By default, gestures rotate and zoom around the center of the gesture. Set this property to rotate and zoom around a fixed point instead.
    ///
    /// This property will be ignored by the pinch gesture if ``GestureOptions/pinchPanEnabled`` is set to `true`.
    public var focalPoint: CGPoint?

    public init() {}
}
