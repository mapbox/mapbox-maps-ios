import UIKit

/// Options used to configure the direction in which the map is allowed to move
/// during a pan gesture. Called `ScrollMode` in the Android SDK for
/// consistency with platform conventions.
public enum PanMode: String, Equatable, CaseIterable, Sendable {
    /// The map may only move horizontally.
    case horizontal

    /// The map may only move vertically.
    case vertical

    /// The map may move both horizontally and vertically.
    case horizontalAndVertical
}

/// Configuration options for the built-in gestures
public struct GestureOptions: Equatable, Sendable {

    /// Whether the single-touch pan gesture is enabled.
    ///
    /// Defaults to `true`.
    public var panEnabled: Bool

    /// Whether the pinch gesture is enabled.
    ///
    /// Defaults to `true`.
    public var pinchEnabled: Bool

    /// Whether rotation gesture is enabled.
    ///
    /// Defaults to `true`.
    public var rotateEnabled: Bool

    /// Whether rotation is enabled during the pinch gesture.
    ///
    /// Defaults to `true`.
    public var simultaneousRotateAndPinchZoomEnabled: Bool

    /// Whether zoom is enabled for the pinch gesture.
    ///
    /// Defaults to `true`.
    public var pinchZoomEnabled: Bool

    /// Whether pan is enabled for the pinch gesture.
    ///
    /// Defaults to `true`.
    public var pinchPanEnabled: Bool

    /// Whether the pitch gesture is enabled.
    ///
    /// Defaults to `true`.
    public var pitchEnabled: Bool

    /// Whether double tapping the map with one touch results in a zoom-in animation.
    ///
    /// Defaults to `true`.
    public var doubleTapToZoomInEnabled: Bool

    /// Whether single tapping the map with two touches results in a zoom-out animation.
    ///
    /// Defaults to `true`.
    public var doubleTouchToZoomOutEnabled: Bool

    /// Whether the quick zoom gesture is enabled.
    ///
    /// Defaults to `true`.
    public var quickZoomEnabled: Bool

    /// Configures the directions in which the map is allowed to move during a pan gesture.
    ///
    /// Defaults to `PanMode.horizontalAndVertical`. Called `scrollMode` in
    /// the Android SDK for consistency with platform conventions.
    public var panMode: PanMode

    /// A constant factor that determines how quickly pan deceleration animations happen.
    /// Multiplied with the velocity vector once per millisecond during deceleration animations.
    ///
    /// Defaults to `UIScrollView.DecelerationRate.normal.rawValue`
    public var panDecelerationFactor: CGFloat

    /// By default, gestures rotate and zoom around the center of the gesture. Set this property to rotate and zoom around a fixed point instead.
    ///
    /// This property will be ignored by the pinch gesture if ``GestureOptions/pinchPanEnabled`` is set to `true`.
    public var focalPoint: CGPoint?

    /// Initializes a `GestureOptions`.
    /// - Parameters:
    ///   - panEnabled: Whether the single-touch pan gesture is enabled.
    ///   - pinchEnabled: Whether the pinch gesture is enabled.
    ///   - rotateEnabled: Whether rotation gesture is enabled.
    ///   - simultaneousRotateAndPinchZoomEnabled: Whether rotation is enabled during the pinch gesture.
    ///   - pinchZoomEnabled: Whether zoom is enabled for the pinch gesture.
    ///   - pinchPanEnabled: Whether pan is enabled during the pinch gesture.
    ///   - pitchEnabled: Whether the pitch gesture is enabled.
    ///   - doubleTapToZoomInEnabled: Whether double tapping the map with one touch results in a zoom-in animation.
    ///   - doubleTouchToZoomOutEnabled: Whether single tapping the map with two touches results in a zoom-out animation.
    ///   - quickZoomEnabled: Whether the quick zoom gesture is enabled.
    ///   - panMode: The directions in which the map is allowed to move during a pan gesture.
    ///   - panDecelerationFactor: The constant factor that determines how quickly pan deceleration animations happen.
    ///   - focalPoint: The centerpoint for rotating and zooming the map.
    public init(
        panEnabled: Bool = true,
        pinchEnabled: Bool = true,
        rotateEnabled: Bool = true,
        simultaneousRotateAndPinchZoomEnabled: Bool = true,
        pinchZoomEnabled: Bool = true,
        pinchPanEnabled: Bool = true,
        pitchEnabled: Bool = true,
        doubleTapToZoomInEnabled: Bool = true,
        doubleTouchToZoomOutEnabled: Bool = true,
        quickZoomEnabled: Bool = true,
        panMode: PanMode = .horizontalAndVertical,
        panDecelerationFactor: CGFloat = UIScrollView.DecelerationRate.normal.rawValue,
        focalPoint: CGPoint? = nil
    ) {
        self.panEnabled = panEnabled
        self.pinchEnabled = pinchEnabled
        self.rotateEnabled = rotateEnabled
        self.simultaneousRotateAndPinchZoomEnabled = simultaneousRotateAndPinchZoomEnabled
        self.pinchZoomEnabled = pinchZoomEnabled
        self.pinchPanEnabled = pinchPanEnabled
        self.pitchEnabled = pitchEnabled
        self.doubleTapToZoomInEnabled = doubleTapToZoomInEnabled
        self.doubleTouchToZoomOutEnabled = doubleTouchToZoomOutEnabled
        self.quickZoomEnabled = quickZoomEnabled
        self.panMode = panMode
        self.panDecelerationFactor = panDecelerationFactor
        self.focalPoint = focalPoint
    }
}
