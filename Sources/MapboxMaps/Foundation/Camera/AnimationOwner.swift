// MARK: AnimationOwner Enum
public enum AnimationOwner {
    case gestures
    case unspecified
    case custom(id: String)

    public var id: String {
        switch self {
        case .gestures:
            return "com.mapbox.maps.gestures"
        case .unspecified:
            return "com.mapbox.maps.unspecified"
        case .custom(id: let  id):
            return id
        }
    }
}
