/// Expresses the different ways that ``FollowPuckViewportState`` can obtain values to use when
/// setting ``CameraOptions-swift.struct/bearing``.
///
/// - SeeAlso: ``LocationOptions/puckBearing``
public enum FollowPuckViewportStateBearing: Codable, Hashable {

    /// ``FollowPuckViewportState`` sets ``CameraOptions-swift.struct/bearing`` to a constant value.
    ///
    /// - Parameter bearing: the constant value that should be used to set the camera bearing.
    case constant(_ bearing: CLLocationDirection)

    /// ``FollowPuckViewportState`` sets ``CameraOptions-swift.struct/bearing`` based on the current
    /// heading.
    ///
    /// - SeeAlso:
    ///   - ``LocationManager``
    ///   - ``Location/heading``
    case heading

    /// ``FollowPuckViewportState`` sets ``CameraOptions-swift.struct/bearing`` based on the current
    /// course.
    ///
    /// - SeeAlso:
    ///   - ``LocationManager``
    ///   - ``Location/course``
    case course

    internal func evaluate(with data: PuckRenderingData) -> CLLocationDirection? {
        switch self {
        case .constant(let value):
            return value
        case .heading:
            return data.heading?.direction
        case .course:
            return data.location.bearing
        }
    }
}
