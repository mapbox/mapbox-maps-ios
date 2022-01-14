public enum FollowingViewportStateBearing: Hashable {
    case constant(_ bearing: CLLocationDirection)
    @available(tvOS, unavailable)
    case heading
    case course

    internal func evaluate(with location: Location) -> CLLocationDirection? {
        switch self {
        case .constant(let value):
            return value
        #if !os(tvOS)
        case .heading:
            return location.headingDirection
        #endif
        case .course:
            return location.course
        }
    }
}
