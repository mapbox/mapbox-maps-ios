import Foundation

public enum StyleURL: Hashable {
    public static var defaultStreetsVersion: UInt { return 11 }
    public static var defaultOutdoorsVersion: UInt { return 11 }
    public static var defaultLightVersion: UInt { return 10 }
    public static var defaultDarkVersion: UInt { return 10 }
    public static var defaultSatelliteVersion: UInt { return 9 }
    public static var defaultSatelliteStreetsVersion: UInt { return 11 }

    /**
     The latest version of the Mapbox Streets style as of publication.

     Mapbox Streets is a general-purpose style with detailed road and transit networks.
     */

    case streets

    /**
     The Mapbox Streets style is a general-purpose style
     with detailed road and transit networks.
     The latest version of Mapbox Streets is used by default.

     @param version A specific version of the Mapbox Streets style. Defaults to the latest version.
     */

    case streetsVersion(_ version: UInt = defaultStreetsVersion)

    /**
    The latest version of the Mapbox Outdoors style as of publication.

    Mapbox Streets is a general-purpose style tailored to
    outdoor activities.
    */

    case outdoors

    /**
     The Mapbox Outdoors style is a general-purpose style
     tailored to outdoor activities.
     The latest version of Mapbox Outdoors is used by default.

     @param version A specific version of the Mapbox Outdoors style. Defaults to the latest version.
     */

    case outdoorsVersion(_ version: UInt = defaultOutdoorsVersion)

    /**
    The latest version of the Mapbox Light style as of publication.

    Mapbox Light is a subtle, light-colored backdrop for
    data visualizations.
     */

    case light

    /**
    The Mapbox Light style is a subtle, light-colored
    backdrop for data visualizations.

    The latest version of Mapbox Light is used by default.

    @param version A specific version of the Mapbox Light
    style. Defaults to the latest version.
     */

    case lightVersion(_ version: UInt = defaultLightVersion)

    /**
    The latest version of the Mapbox Dark style as of
    publication.

    Mapbox Dark is a subtle, dark-colored backdrop for
    data visualizations.
     */

    case dark

    /**
     The Mapbox Dark style is a subtle, dark-colored backdrop for data visualizations.

     The latest version of Mapbox Dark is used by default.

     @param version A specific version of the Mapbox Dark style. Defaults to the latest version.
    */

    case darkVersion(_ version: UInt = defaultDarkVersion)

    /**
    The latest version of the Mapbox Satellite style as of
    publication.

    Mapbox Satellite is a base-map of  high-resolution
    satellite and aerial imagery.
     */

    case satellite
    /**
     The Mapbox Satellite style is a base-map of  high-resolution satellite and aerial imagery.

     The latest version of Mapbox Satellite is used by default.

     @param version A specific version of the Mapbox Satellite style. Defaults to the latest version.
     */

    case satelliteVersion(_ version: UInt = defaultSatelliteVersion)

    /**
     The latest version of the Mapbox Satellite Streets style
     as of publication.

     The latest version of Mapbox Satellite Streets is used
     by default.
     */

    case satelliteStreets
    /**
     The Mapbox Satellite Streets style combines the
     high-resolution satellite and aerial imagery of
     Mapbox Satellite with unobtrusive labels and
     translucent roads from Mapbox Streets.

     The latest version of Mapbox Satellite Streets is used
     by default.

     @param version A specific version of the Mapbox
     Satellite Streets style. Defaults to the latest version.
     */
    case satelliteStreetsVersion(_ version: UInt = defaultSatelliteStreetsVersion)

    /**
     The URL to a custom style. The URL may be a full HTTP
     or HTTPS URL, a Mapbox style URL (mapbox://styles/{user}/{style}),
     or a path to a local file relative to the
     application’s resource path.

     @param url The URL to a custom style.
     */
    case custom(url: URL)
}

extension StyleURL {
    public var url: URL {
        switch self {
        case .streets:
            return StyleURL.streetsVersion().url
        case let .streetsVersion(version):
            if version >= StyleURL.defaultStreetsVersion {
                return URL(string: "mapbox://styles/mapbox/streets-v\(StyleURL.defaultStreetsVersion)")!
            }
            return URL(string: "mapbox://styles/mapbox/streets-v\(version)")!
        case .outdoors:
            return StyleURL.outdoorsVersion().url
        case let .outdoorsVersion(version):
            if version >= StyleURL.defaultOutdoorsVersion {
                return URL(string: "mapbox://styles/mapbox/outdoors-v\(StyleURL.defaultOutdoorsVersion)")!
            }
            return URL(string: "mapbox://styles/mapbox/outdoors-v\(version)")!
        case .light:
            return StyleURL.lightVersion().url
        case let .lightVersion(version):
            if version >= StyleURL.defaultLightVersion {
                return URL(string: "mapbox://styles/mapbox/light-v\(StyleURL.defaultLightVersion)")!
            }
            return URL(string: "mapbox://styles/mapbox/light-v\(version)")!
        case .dark:
            return StyleURL.darkVersion().url
        case let .darkVersion(version):
            if version >= StyleURL.defaultDarkVersion {
                return URL(string: "mapbox://styles/mapbox/dark-v\(StyleURL.defaultDarkVersion)")!
            }
            return URL(string: "mapbox://styles/mapbox/dark-v\(version)")!
        case .satellite:
            return StyleURL.satelliteVersion().url
        case let .satelliteVersion(version):
            if version >= StyleURL.defaultSatelliteVersion {
                    return URL(string: "mapbox://styles/mapbox/satellite-v\(StyleURL.defaultSatelliteVersion)")!
            }
            return URL(string: "mapbox://styles/mapbox/satellite-v\(version)")!
        case .satelliteStreets:
            return StyleURL.satelliteStreetsVersion().url
        case let .satelliteStreetsVersion(version):
            if version >= StyleURL.defaultSatelliteStreetsVersion {
                return URL(string: "mapbox://styles/mapbox/satellite-streets-v\(StyleURL.defaultSatelliteStreetsVersion)")!
            }
            return URL(string: "mapbox://styles/mapbox/satellite-streets-v\(version)")!
        case let .custom(url):
            return url
        }
    }
}
