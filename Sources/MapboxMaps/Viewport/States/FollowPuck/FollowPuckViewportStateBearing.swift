@_spi(Experimental) public enum FollowPuckViewportStateBearing: Hashable {
    case constant(_ bearing: CLLocationDirection)
    case heading
    case course

    internal func evaluate(with location: Location) -> CLLocationDirection? {
        switch self {
        case .constant(let value):
            return value
        case .heading:
            return location.headingDirection
        case .course:
            return location.course
        }
    }
}
