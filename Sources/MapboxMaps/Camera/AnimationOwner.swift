public struct AnimationOwner: RawRepresentable, Equatable {
    public typealias RawValue = String

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let gestures = AnimationOwner(rawValue: "com.mapbox.maps.gestures")

    public static let unspecified = AnimationOwner(rawValue: "com.mapbox.maps.unspecified")

    internal static let cameraAnimationsManager = AnimationOwner(rawValue: "com.mapbox.maps.cameraAnimationsManager")

    internal static let defaultViewportTransition = AnimationOwner(rawValue: "com.mapbox.maps.viewport.defaultTransition")
}

/// Declares type of animations. Can be used to fine-grain cancellation filtering.
public struct AnimationType: RawRepresentable, Equatable {

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let unspecified = AnimationType(rawValue: "com.mapbox.maps.animation.type.unspecified")

    public static let deceleration = AnimationType(rawValue: "com.mapbox.maps.animation.type.deceleration")

}
