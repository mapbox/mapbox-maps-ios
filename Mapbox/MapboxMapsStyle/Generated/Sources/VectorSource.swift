// This file is generated.
// This file is generated.

import Foundation
import Turf

/**
 * A vector tile source.
 *
 * @see <a href="https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/#vector">The online documentation</a>
 *
 */
public struct VectorSource: Source {

    public let type: SourceType
 
  
    /** 
     * A URL to a TileJSON resource. Supported protocols are `http:`, `https:`, and `mapbox://<Tileset ID>`. 
    */
    public var url: String?
      
    /** 
     * An array of one or more tile source URLs, as in the TileJSON spec. 
    */
    public var tiles: [String]?
      
    /** 
     * An array containing the longitude and latitude of the southwest and northeast corners of the source's bounding box in the following order: `[sw.lng, sw.lat, ne.lng, ne.lat]`. When this property is included in a source, no tiles outside of the given bounds are requested by Mapbox GL. 
    */
    public var bounds: [Double]?
      
    /** 
     * Influences the y direction of the tile coordinates. The global-mercator (aka Spherical Mercator) profile is assumed. 
    */
    public var scheme: Scheme?
      
    /** 
     * Minimum zoom level for which tiles are available, as in the TileJSON spec. 
    */
    public var minzoom: Double?
      
    /** 
     * Maximum zoom level for which tiles are available, as in the TileJSON spec. Data from tiles at the maxzoom are used when displaying the map at higher zoom levels. 
    */
    public var maxzoom: Double?
      
    /** 
     * Contains an attribution to be displayed when the map is shown to a user. 
    */
    public var attribution: String?
      
    /** 
     * A setting to determine whether a source's tiles are cached locally. 
    */
    public var volatile: Bool?
      
  
    /** 
     * When loading a map, if `PrefetchZoomDelta` is set to any number greater than 0, the map will first request a tile for `zoom - delta` in a attempt to display a full map at lower resolution as quick as possible. It will get clamped at the tile source minimum zoom. The default `delta` is 4. 
    */
    public var prefetchZoomDelta: Double?
      
    /** 
     * Minimum tile update interval in milliseconds, which is used to throttle the tile update network requests. 
    */
    public var minimumTileUpdateInterval: Double?
      
    /** 
     * When a set of tiles for a current zoom level is being rendered and some of the ideal tiles that cover the screen are not yet loaded, parent tile could be used instead. This might introduce unwanted rendering side-effects, especially for raster tiles that are overscaled multiple times. This property sets the maximum limit for how much a parent tile can be overscaled. 
    */
    public var maxOverscaleFactorForParentTiles: Double?
     
    public init() {
      self.type = .vector
    }
}

// End of generated file.