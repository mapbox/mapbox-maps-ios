/// Declares type of animations. Can be used to fine-grain cancellation filtering.
internal struct AnimationType: RawRepresentable, Equatable {

    internal let rawValue: String

    internal static let unspecified = AnimationType(rawValue: "com.mapbox.maps.animation.type.unspecified")

    internal static let deceleration = AnimationType(rawValue: "com.mapbox.maps.animation.type.deceleration")

}
