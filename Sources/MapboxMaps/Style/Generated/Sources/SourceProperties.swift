// This file is generated.
import Foundation

/// Influences the y direction of the tile coordinates. The global-mercator (aka Spherical Mercator) profile is assumed.
public enum Scheme: String, Codable {

    /// Slippy map tilenames scheme.
    case xyz = "xyz"

    /// OSGeo spec scheme.
    case tms = "tms"

}

/// The encoding used by this source. Mapbox Terrain RGB is used by default
public enum Encoding: String, Codable {

    /// Terrarium format PNG tiles. See https://aws.amazon.com/es/public-datasets/terrain/ for more info.
    case terrarium = "terrarium"

    /// Mapbox Terrain RGB tiles. See https://www.mapbox.com/help/access-elevation-data/#mapbox-terrain-rgb for more info.
    case mapbox = "mapbox"

}

// End of generated file.
