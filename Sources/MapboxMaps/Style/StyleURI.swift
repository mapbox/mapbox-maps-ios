import Foundation

/// Enum representing the latest version of the Mapbox styles (as of publication). In addition,
/// you can provide a custom URL or earlier version of a Mapbox style by using the `.custom` case.
public struct StyleURI: Hashable, RawRepresentable {
    public typealias RawValue = String

    public let rawValue: String

    /// Create a custom StyleURI from a String. The String may be a full HTTP or HTTPS URI, a Mapbox style URI
    /// (mapbox://styles/{user}/{style}), or a path to a local file relative to the application’s
    /// resource path.
    /// Returns nil if the String is invalid.
    /// - Parameter rawValue: String representation of the URI for the style
    public init?(rawValue: String) {
        guard let url = URL(string: rawValue), url.scheme != nil else {
            return nil
        }
        self.rawValue = rawValue
    }

    /// Create a custom StyleURI from a URL. The URL may be a full HTTP or HTTPS URI, a Mapbox style URI
    /// (mapbox://styles/{user}/{style}), or a path to a local file relative to the application’s
    /// resource path.
    /// Returns nil if the URL is invalid.
    /// - Parameter url: URL for the style
    public init?(url: URL) {
        self.init(rawValue: url.absoluteString)
    }

    /// Mapbox Streets is a general-purpose style with detailed road and transit networks.
    public static let streets = StyleURI(rawValue: "mapbox://styles/mapbox/streets-v11")!

    /// Mapbox Outdoors is a general-purpose style tailored to outdoor activities.
    public static let outdoors = StyleURI(rawValue: "mapbox://styles/mapbox/outdoors-v11")!

    /// Mapbox Light is a subtle, light-colored backdrop for data visualizations.
    public static let light = StyleURI(rawValue: "mapbox://styles/mapbox/light-v10")!

    /// Mapbox Dark is a subtle, dark-colored backdrop for data visualizations.
    public static let dark = StyleURI(rawValue: "mapbox://styles/mapbox/dark-v10")!

    /// The Mapbox Satellite style is a base-map of high-resolution satellite and aerial imagery.
    public static let satellite = StyleURI(rawValue: "mapbox://styles/mapbox/satellite-v9")!

    /// The Mapbox Satellite Streets style combines the high-resolution satellite and aerial imagery
    /// of Mapbox Satellite with unobtrusive labels and translucent roads from Mapbox Streets.
    public static let satelliteStreets = StyleURI(rawValue: "mapbox://styles/mapbox/satellite-streets-v11")!

    public static let v12 = V12()

    public struct V12 {
        /// Mapbox Streets is a general-purpose style with detailed road and transit networks.
        public let streets = StyleURI(rawValue: "mapbox://styles/mapbox/streets-v12")!

        /// Mapbox Outdoors is a general-purpose style tailored to outdoor activities.
        public let outdoors = StyleURI(rawValue: "mapbox://styles/mapbox/outdoors-v12")!

        /// Mapbox Light is a subtle, light-colored backdrop for data visualizations.
        public let light = StyleURI(rawValue: "mapbox://styles/mapbox/light-v11")!

        /// Mapbox Dark is a subtle, dark-colored backdrop for data visualizations.
        public let dark = StyleURI(rawValue: "mapbox://styles/mapbox/dark-v11")!

        /// The Mapbox Satellite style is a base-map of high-resolution satellite and aerial imagery.
        public let satellite = StyleURI(rawValue: "mapbox://styles/mapbox/satellite-v9")!

        /// The Mapbox Satellite Streets style combines the high-resolution satellite and aerial imagery
        /// of Mapbox Satellite with unobtrusive labels and translucent roads from Mapbox Streets.
        public let satelliteStreets = StyleURI(rawValue: "mapbox://styles/mapbox/satellite-streets-v12")!

        public let navigationDay = StyleURI(rawValue: "mapbox://styles/mapbox/navigation-day-v1")!
        public let navigationNight = StyleURI(rawValue: "mapbox://styles/mapbox/navigation-night-v1")!
    }
}
