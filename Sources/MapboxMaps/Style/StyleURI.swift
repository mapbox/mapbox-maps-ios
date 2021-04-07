import Foundation

/// Enum representing the latest version of the Mapbox styles (as of publication). In addition,
/// you can provide a custom URL or earlier version of a Mapbox style by using the `.custom` case.
public enum StyleURI: Hashable, RawRepresentable {
    public typealias RawValue = URL

    /// Mapbox Streets is a general-purpose style with detailed road and transit networks.
    case streets

    /// Mapbox Streets is a general-purpose style tailored to outdoor activities.
    case outdoors

    /// Mapbox Light is a subtle, light-colored backdrop for data visualizations.
    case light

    /// Mapbox Dark is a subtle, dark-colored backdrop for data visualizations.
    case dark

    /// The Mapbox Satellite style is a base-map of high-resolution satellite and aerial imagery.
    case satellite

    /// The Mapbox Satellite Streets style combines the high-resolution satellite and aerial imagery
    /// of Mapbox Satellite with unobtrusive labels and translucent roads from Mapbox Streets.
    case satelliteStreets

    /// The URL to a custom style. The URL may be a full HTTP or HTTPS URL, a Mapbox style URL
    /// (mapbox://styles/{user}/{style}), or a path to a local file relative to the application’s
    /// resource path.
    case custom(url: URL)

    /// :nodoc:
    /// `RawRepresentable` conformance
    public var rawValue: URL {
        switch self {
        case .streets:
            return Self.streetsURI
        case .outdoors:
            return Self.outdoorsURI
        case .light:
            return Self.lightURI
        case .dark:
            return Self.darkURI
        case .satellite:
            return Self.satelliteURI
        case .satelliteStreets:
            return Self.satelliteStreetsURI
        case .custom(let url):
            return url
        }
    }

    /// Create a StyleURI from a URL.
    /// Returns nil if the URI is invalid.
    /// - Parameter rawValue: URL to create style URI from.
    public init?(rawValue: URL) {
        switch rawValue {
        case Self.streetsURI:
            self = .streets
        case Self.outdoorsURI:
            self = .outdoors
        case Self.lightURI:
            self = .light
        case Self.darkURI:
            self = .dark
        case Self.satelliteURI:
            self = .satellite
        case Self.satelliteStreetsURI:
            self = .satelliteStreets
        default:
            guard rawValue.scheme != nil else {
                return nil
            }
            self = .custom(url: rawValue)
        }
    }

    private static let streetsURI          = URL(string: "mapbox://styles/mapbox/streets-v11")!
    private static let outdoorsURI         = URL(string: "mapbox://styles/mapbox/outdoors-v11")!
    private static let lightURI            = URL(string: "mapbox://styles/mapbox/light-v10")!
    private static let darkURI             = URL(string: "mapbox://styles/mapbox/dark-v10")!
    private static let satelliteURI        = URL(string: "mapbox://styles/mapbox/satellite-v9")!
    private static let satelliteStreetsURI = URL(string: "mapbox://styles/mapbox/satellite-streets-v11")!

    /// :nodoc:
    /// Hashable conformance
    /// - Parameter hasher: The hasher used to generate a hash value.
    /// - Note: This function is not meant to be called by application code.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
