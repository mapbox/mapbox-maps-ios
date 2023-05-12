/// Expresses the different ways that ``FollowPuckViewportState`` can obtain values to use when
/// setting ``CameraOptions/bearing``.
///
/// - SeeAlso: ``LocationOptions/puckBearing``
public enum FollowPuckViewportStateBearing: Hashable {

    /// ``FollowPuckViewportState`` sets ``CameraOptions/bearing`` to a constant value.
    ///
    /// - Parameter bearing: the constant value that should be used to set the camera bearing.
    case constant(_ bearing: CLLocationDirection)

    /// ``FollowPuckViewportState`` sets ``CameraOptions/bearing`` based on the current
    /// heading.
    ///
    /// - SeeAlso:
    ///   - ``LocationManager``
    ///   - ``Location/heading``
    case heading

    /// ``FollowPuckViewportState`` sets ``CameraOptions/bearing`` based on the current
    /// course.
    ///
    /// - SeeAlso:
    ///   - ``LocationManager``
    ///   - ``Location/course``
    case course

    internal func evaluate(with location: InterpolatedLocation) -> CLLocationDirection? {
        switch self {
        case .constant(let value):
            return value
        case .heading:
            return location.heading
        case .course:
            return location.course
        }
    }
}
