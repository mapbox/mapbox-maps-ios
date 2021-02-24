import UIKit

public enum PanScrollingMode: String, Equatable {
    /// The map allows the user to only scroll horizontally.
    case horizontal

    /// The map allows the user to only scroll vertically.
    case vertical

    /// The map allows the user to scroll both horizontally and vertically.
    case horizontalAndVertical
}

/// Used to configure how the User Interacts with the Map
public struct GestureOptions: Equatable {

    /**
        A Boolean value that determines whether the user may zoom the map in and
        out, changing the zoom level.

        When this property is set to `true`, the default, the user may zoom the map
        in and out by pinching two fingers or by double tapping, holding, and moving
        the finger up and down.

        This property controls only user interactions with the map. If you set the
        value of this property to `false`, you may still change the map zoom
        programmatically.

        The default value of this property is `true`.
    */
    public var zoomEnabled = true

    /**
        A Boolean value that determines whether the user may rotate the map,
        changing the direction.

        When this property is set to `true`, the user may rotate the map
        by moving two fingers in a circular motion.

        This property controls only user interactions with the map. If you set the
        value of this property to `false`, you may still rotate the map
        programmatically.

        The default value of this property is `true`.
    */
    public var rotateEnabled: Bool = true

    /**
        A Boolean value that determines whether the user may scroll around the map,
        changing the center coordinate.

        When this property is set to `true`, the default, the user may scroll the map
        by dragging or swiping with one finger.

        This property controls only user interactions with the map. If you set the
        value of this property to `false`, you may still change the map location
        programmatically.

        The default value of this property is `true`.
    */
    public var scrollEnabled: Bool = true

    /**
        The scrolling mode the user is allowed to use to interact with the map.

        `horizontal` only allows the user to scroll horizontally on the map,
        restricting a user's ability to scroll vertically.

        `vertical` only allows the user to scroll vertically on the map,
        restricting a user's ability to scroll horizontally.

        `horizontalAndVertical` allows the user to scroll both horizontally and vertically
        on the map.

        By default, this property is set to `MGLPanScrollingModeDefault`.
     */
    public var scrollingMode: PanScrollingMode = .horizontalAndVertical

    /**
        A Boolean value that determines whether the user may change the pitch (tilt) of
        the map.

        When this property is set to `true`, the default, the user may tilt the map by
        vertically dragging two fingers.

        This property controls only user interactions with the map. If you set the
        value of this property to `false`, you may still change the pitch of the map
        programmatically.

        The default value of this property is `true`.
    */
    public var pitchEnabled: Bool = true

    /**
        A Boolean value that determines whether the user will receive haptic feedback
        for certain interactions with the map.

        When this property is set to `true`, the default, a `UIImpactFeedbackStyleLight`
        haptic feedback event be played when the user rotates the map to due north
        (0°).

        This feature requires a device that supports haptic feedback, running iOS 10 or
        newer.

        The default value of this property is `true`.
    */
    public var hapticFeedbackEnabled: Bool = true

    /**
        A floating-point value that determines the rate of deceleration after the user lifts their finger.
    */
    public var decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue

    public init() {}

    /// Emits the supported gesture types for the current set of options
    internal func supportedGestureTypes() -> Set<GestureType> {
        var supportedGestureTypes = Set<GestureType>()

        if scrollEnabled {
            supportedGestureTypes.insert(.pan)
        }

        if zoomEnabled {
            supportedGestureTypes.insert(.pinch)
            supportedGestureTypes.insert(.tap(numberOfTaps: 2,
                                              numberOfTouches: 1))
            supportedGestureTypes.insert(.tap(numberOfTaps: 2,
                                              numberOfTouches: 2))
            supportedGestureTypes.insert(.quickZoom)
        }

        if rotateEnabled {
            supportedGestureTypes.insert(.rotate)
        }

        if pitchEnabled {
            supportedGestureTypes.insert(.pitch)
        }

        return supportedGestureTypes
    }
}
