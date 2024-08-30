/// Expresses the different ways that ``FollowPuckViewportState`` can obtain values to use when
/// setting ``CameraOptions-swift.struct/bearing``.
///
/// - SeeAlso: ``LocationOptions/puckBearing``
public enum FollowPuckViewportStateBearing: Codable, Hashable, Sendable {

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
}

extension FollowPuckViewportStateBearing {
    func evaluate(with state: FollowPuckViewportState.RenderingState) -> CLLocationDirection? {
        switch self {
        case .constant(let value):
            return value
        case .heading:
            return state.heading
        case .course:
            return state.bearing
        }
    }
}
