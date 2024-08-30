import Foundation
import CoreLocation

/// The `CompassDirectionFormatter` class provides properly formatted
/// descriptions of absolute compass directions. For example, a value of `90` may
/// be formatted as “east”, depending on the locale.
public class CompassDirectionFormatter {

    /// `Style` is used to configure how a `CompassDirectionFormatter`
    /// translates a compass direction into a `String`.
    public enum Style: Hashable, Sendable {

        /// When a `CompassDirectionFormatter` is configured to use
        /// the `short` style, it uses an abbreviation of the compass direction,
        /// like “N” for north or “NE” for northeast.
        case short

        /// When a `CompassDirectionFormatter` is configured to use
        /// the `long` style, it uses full descriptions of the compass direction,
        /// like “north” or “northeast.”
        case long

        fileprivate var tableName: String {
            switch self {
            case .short:
                return "CompassDirectionShort"
            case .long:
                return "CompassDirectionLong"
            }
        }
    }

    /// The `Style` used by this formatter. Defaults to `Style.long`.
    public var style = Style.long

    /// Creates a new `CompassDirectionFormatter` instance
    public init() {
    }

    /// Returns a localized string describing the provided compass direction.
    ///
    /// - Parameter direction: A compass direction, measured in degrees, where 0°
    /// means “due north” and 90° means “due east”.
    /// - Returns: A localized `String` describing the provided `direction`
    public func string(from direction: CLLocationDirection) -> String {
        let stringsCount = Self.strings(for: style).count
        let wrappedValueRounded = round(direction.wrapped(to: 0..<360) / 360 * Double(stringsCount))
        let cardinalPoint = Int(wrappedValueRounded.wrapped(to: 0..<Double(stringsCount)))
        return Self.strings(for: style)[cardinalPoint]
    }

    private static var cachedStringsByStyle = [Style: [String]]()

    private static func strings(for style: Style) -> [String] {
        if let strings = cachedStringsByStyle[style] {
            return strings
        }
        let strings = [
            "N", "NbE", "NNE", "NEbN", "NE", "NEbE", "ENE", "EbN",
            "E", "EbS", "ESE", "SEbE", "SE", "SEbS", "SSE", "SbE",
            "S", "SbW", "SSW", "SWbS", "SW", "SWbW", "WSW", "WbS",
            "W", "WbN", "WNW", "NWbW", "NW", "NWbN", "NNW", "NbW",
        ]
        .map {
            NSLocalizedString($0, tableName: style.tableName, bundle: .mapboxMaps, comment: "")
        }
        cachedStringsByStyle[style] = strings
        return strings
    }
}
