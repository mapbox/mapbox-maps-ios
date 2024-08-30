public struct AnimationOwner: RawRepresentable, Equatable, Sendable {
    public typealias RawValue = String

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let gestures = AnimationOwner(rawValue: "com.mapbox.maps.gestures")

    public static let unspecified = AnimationOwner(rawValue: "com.mapbox.maps.unspecified")

    public static let compass = AnimationOwner(rawValue: "com.mapbox.maps.ornaments.compass")

    internal static let cameraAnimationsManager = AnimationOwner(rawValue: "com.mapbox.maps.cameraAnimationsManager")

    internal static let defaultViewportTransition = AnimationOwner(rawValue: "com.mapbox.maps.viewport.defaultTransition")
}
