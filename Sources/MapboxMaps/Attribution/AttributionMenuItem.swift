import Foundation
import UIKit

/// A menu item entry in the attribution list.
@_spi(Restricted)
public struct AttributionMenuItem {

    /// Denotes a category(section) that item belongs to.
    public struct Category: RawRepresentable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        /// Main(root) category
        public static let main = Category(rawValue: "com.mapbox.maps.attribution.main")

        /// Category for opting in/out of telemetry
        public static let telemetry = Category(rawValue: "com.mapbox.maps.attribution.telemetry")

        /// Category for opting in/out of geofencing
        public static let geofencing = Category(rawValue: "com.mapbox.maps.attribution.geofencing")
    }

    /// Denotes an identifier of an item
    public struct ID: RawRepresentable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        /// Item attributing a copyright
        public static let copyright = ID(rawValue: "com.mapbox.maps.attribution.copyright")

        /// Represents an item opening a contribution form
        public static let contribute = ID(rawValue: "com.mapbox.maps.attribution.contribute")

        /// Opens privacy policy page
        public static let privacyPolicy = ID(rawValue: "com.mapbox.maps.attribution.privacyPolicy")

        /// Opens page with the info about Mapbox telemetry
        public static let telemetryInfo = ID(rawValue: "com.mapbox.maps.attribution.telemetryInfo")

        /// Item that enables a certain option, typically associated with a category
        /// e.g. `category: .telemetry, id: .enable`
        public static let enable = ID(rawValue: "com.mapbox.maps.attribution.enable")

        /// Item that disables a certain option, typically associated with a category
        /// e.g. `category: .telemetry, id: .disable`
        public static let disable = ID(rawValue: "com.mapbox.maps.attribution.disable")

        /// Item that dismisses the attribution menu
        public static let cancel = ID(rawValue: "com.mapbox.maps.attribution.cancel")
    }

    /// Title of the attribution menu item
    public let title: String

    /// Identifier of the item
    public let id: ID

    /// Category of the item
    public let category: Category

    let action: (() -> Void)?
    let style: Style

    init(title: String, style: Style = .default, id: ID, category: Category, action: (() -> Void)? = nil) {
        self.title = title
        self.id = id
        self.category = category
        self.action = action
        self.style = style
    }
}

extension AttributionMenuItem {
    enum Style {
        case `default`
        case cancel

        var uiActionStyle: UIAlertAction.Style {
            switch self {
            case .default: return .default
            case .cancel: return .cancel
            }
        }
    }
}
