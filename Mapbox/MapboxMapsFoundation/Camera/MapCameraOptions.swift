import UIKit

/// Used to configure Camera-specific capabilities of the map
public struct MapCameraOptions: Equatable {

    /**
        The minimum zoom level at which the map can be shown.
        Depending on the map view’s aspect ratio, the map view may be prevented
        from reaching the minimum zoom level, in order to keep the map from
        repeating within the current viewport.
        If the value of this property is greater than that of the
        maximumZoomLevel property, the behavior is undefined.

        The default minimumZoomLevel is 0.
    */
    public var minimumZoomLevel: CGFloat = 0.0

    /**
         The maximum zoom level the map can be shown at. If the value of this property is
         smaller than that of the minimumZoomLevel property, the behavior is undefined.
         The default maximumZoomLevel is 22. The upper bound for this property is 25.5.
    */
    public var maximumZoomLevel: CGFloat = 22.0

    /**
        The minimum pitch of the map’s camera toward the horizon measured in degrees.

        If the value of this property is greater than that of the `maximumPitch`
        property, the behavior is undefined. The pitch may not be less than 0
        regardless of this property.

        The default value of this property is 0 degrees, allowing the map to appear
        two-dimensional.
    */
    public var minimumPitch: CGFloat = 0.0

    /**
        The maximum pitch of the map’s camera toward the horizon measured in degrees.

        If the value of this property is smaller than that of the `minimumPitch`
        property, the behavior is undefined. The pitch may not exceed 85 degrees
        regardless of this property.

        The default value of this property is 85 degrees.
    */
    public var maximumPitch: CGFloat = 85.0

    /**
        A time interval that represents the amount of time the camera view is animated for.
    */
    public var animationDuration: TimeInterval = 0.3

    /**
        A floating-point value that determines the rate of deceleration after the user lifts their finger.
    */
    public var decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue

    /**
        An optional set of coordinate bounds the camera view is allowed to stay within.
     */
    public var restrictedCoordinateBounds: CoordinateBounds?

    public init() {}
}
