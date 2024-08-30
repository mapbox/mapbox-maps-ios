// This file is generated.
import Foundation

/// Influences the y direction of the tile coordinates. The global-mercator (aka Spherical Mercator) profile is assumed.
public struct Scheme: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Slippy map tilenames scheme.
    public static let xyz = Scheme(rawValue: "xyz")

    /// OSGeo spec scheme.
    public static let tms = Scheme(rawValue: "tms")

}

/// The encoding used by this source. Mapbox Terrain RGB is used by default
public struct Encoding: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Terrarium format PNG tiles. See https://aws.amazon.com/es/public-datasets/terrain/ for more info.
    public static let terrarium = Encoding(rawValue: "terrarium")

    /// Mapbox Terrain RGB tiles. See https://www.mapbox.com/help/access-elevation-data/#mapbox-terrain-rgb for more info.
    public static let mapbox = Encoding(rawValue: "mapbox")

}

// End of generated file.
