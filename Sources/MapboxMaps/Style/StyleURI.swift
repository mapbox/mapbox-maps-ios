import Foundation

/// Enum representing the latest version of the Mapbox styles (as of publication). In addition,
/// you can provide a custom URL or earlier version of a Mapbox style by using `init?(url: URL)`.
public struct StyleURI: Hashable, RawRepresentable, Sendable {
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

        guard url.isFileURL || url.host != nil else {
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
    public static let streets = StyleURI(rawValue: "mapbox://styles/mapbox/streets-v12")!

    /// Mapbox Outdoors is a general-purpose style tailored to outdoor activities.
    public static let outdoors = StyleURI(rawValue: "mapbox://styles/mapbox/outdoors-v12")!

    /// Mapbox Light is a subtle, light-colored backdrop for data visualizations.
    public static let light = StyleURI(rawValue: "mapbox://styles/mapbox/light-v11")!

    /// Mapbox Dark is a subtle, dark-colored backdrop for data visualizations.
    public static let dark = StyleURI(rawValue: "mapbox://styles/mapbox/dark-v11")!

    /// The Mapbox Satellite style is a base-map of high-resolution satellite and aerial imagery.
    public static let satellite = StyleURI(rawValue: "mapbox://styles/mapbox/satellite-v9")!

    /// The Mapbox Satellite Streets style combines the high-resolution satellite and aerial imagery
    /// of Mapbox Satellite with unobtrusive labels and translucent roads from Mapbox Streets.
    public static let satelliteStreets = StyleURI(rawValue: "mapbox://styles/mapbox/satellite-streets-v12")!
}
