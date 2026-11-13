import Foundation

/// An entry in the attribution menu.
@_spi(Restricted)
public struct AttributionMenuItem: Hashable {

    /// Role of an item in the menu. Not unique: all copyright rows share ``ID/copyright``.
    public struct ID: RawRepresentable, Hashable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static let copyright = ID(rawValue: "com.mapbox.maps.attribution.copyright")
        public static let contribute = ID(rawValue: "com.mapbox.maps.attribution.contribute")
        public static let privacyPolicy = ID(rawValue: "com.mapbox.maps.attribution.privacyPolicy")
        public static let geofencing = ID(rawValue: "com.mapbox.maps.attribution.geofencing")
        public static let telemetry = ID(rawValue: "com.mapbox.maps.attribution.telemetry")
        @available(*, deprecated, message: "No longer in use")
        public static let telemetryInfo = ID(rawValue: "com.mapbox.maps.attribution.telemetryInfo")
        @available(*, deprecated, message: "No longer in use")
        public static let enable = ID(rawValue: "com.mapbox.maps.attribution.enable")
        @available(*, deprecated, message: "No longer in use")
        public static let disable = ID(rawValue: "com.mapbox.maps.attribution.disable")
        @available(*, deprecated, message: "No longer in use")
        public static let cancel = ID(rawValue: "com.mapbox.maps.attribution.cancel")
    }

    /// A trailing link within an item's ``message``, e.g. "Learn more".
    struct Link: Hashable {
        var title: String
        var url: URL
    }

    enum Kind {
        /// A `nil` url renders as plain text.
        case link(URL?)
        case toggle(MutableRef<Bool>)
    }

    /// Role of the item within the menu.
    public let id: ID

    /// Title of the item.
    public let title: String

    /// Text below the title. For a toggle, matches its state when the menu was built.
    public let message: String?

    let link: Link?
    let kind: Kind

    let messageForState: ((Bool) -> String)?

    init(
        id: ID,
        title: String,
        message: String? = nil,
        messageForState: ((Bool) -> String)? = nil,
        link: Link? = nil,
        kind: Kind
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.messageForState = messageForState
        self.link = link
        self.kind = kind
    }

    func message(forToggleState isOn: Bool) -> String? {
        messageForState?(isOn) ?? message
    }

    var url: URL? {
        switch kind {
        case .link(let url): return url
        case .toggle: return nil
        }
    }

    var toggle: MutableRef<Bool>? {
        switch kind {
        case .toggle(let value): return value
        case .link: return nil
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(id)
        hasher.combine(url)
    }

    // Compares url so one provider's rows with different links stay distinct.
    public static func == (lhs: AttributionMenuItem, rhs: AttributionMenuItem) -> Bool {
        return lhs.title == rhs.title && lhs.id == rhs.id && lhs.url == rhs.url
    }
}

// MARK: - Deprecated

@_spi(Restricted)
extension AttributionMenuItem {
    /// Category that this item belongs to.
    @available(*, deprecated, message: "Categories no longer group the menu. Match on `id` instead.")
    public struct Category: RawRepresentable, Hashable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static let main = Category(rawValue: "com.mapbox.maps.attribution.main")
        public static let telemetry = Category(rawValue: "com.mapbox.maps.attribution.telemetry")
        public static let geofencing = Category(rawValue: "com.mapbox.maps.attribution.geofencing")
    }

    /// Category of the item, derived from its ``id``.
    @available(*, deprecated, message: "Match on `id` instead.")
    public var category: Category {
        switch id {
        case .telemetry: return .telemetry
        case .geofencing: return .geofencing
        default: return .main
        }
    }
}
