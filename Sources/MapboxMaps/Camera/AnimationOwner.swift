public struct AnimationOwner: RawRepresentable, Equatable {
    public typealias RawValue = String

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let gestures = AnimationOwner(rawValue: "com.mapbox.maps.gestures")
    public static let unspecified = AnimationOwner(rawValue: "com.mapbox.maps.unspecified")
}
