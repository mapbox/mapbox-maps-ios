import Foundation

/// A pre-specified location in the style where layer will be added to
/// (such as on top of existing land layers, but below all labels).
///
/// - SeeAlso: More information about slots in [Mapbox Style Specification](https://docs.mapbox.com/style-spec/reference/slots).
public struct Slot: Hashable, Codable, RawRepresentable, ExpressibleByStringLiteral, Sendable {
    /// Above POI labels and behind Place and Transit labels
    public static let top = Slot(rawValue: "top")

    /// Above lines (roads, etc.) and behind 3D buildings
    public static let middle = Slot(rawValue: "middle")

    /// Above polygons (land, landuse, water, etc.)
    public static let bottom = Slot(rawValue: "bottom")

    public let rawValue: String

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}
