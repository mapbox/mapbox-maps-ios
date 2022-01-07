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

/// Represents the available pinch gesture implementations. Each implementation has
/// some shortcomings, and we hope to eliminate the need to make this trade-off in a
/// future release.
@_spi(Experimental) public enum PinchGestureBehavior {

    /// This case represents the pinch gesture behavior that was in place in v10.1. It
    /// resets the camera to the initial state at each frame, resulting in the issue reported
    /// in https://github.com/mapbox/mapbox-maps-ios/issues/775
    case tracksTouchLocationsWhenPanningAfterZoomChange

    /// This case represents a new pinch gesture behavior that solves
    /// https://github.com/mapbox/mapbox-maps-ios/issues/775 but
    /// introduces an issue where panning while zooming doesn't work as expected:
    /// https://github.com/mapbox/mapbox-maps-ios/issues/864
    case doesNotResetCameraAtEachFrame
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

    /// Can be used to make the desired trade-off between two available pinch gesture implementations. See ``PinchGestureBehavior`` for details.
    /// This API is marked as experimental in anticipation of future pinch gesture improvements that remove or update the nature of this trade-off.
    @_spi(Experimental) public var pinchBehavior: PinchGestureBehavior = .tracksTouchLocationsWhenPanningAfterZoomChange

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

    /// Whether touching with the map cancels and prevents animations
    public var animationLockoutEnabled: Bool = true

    public init() {}
}
