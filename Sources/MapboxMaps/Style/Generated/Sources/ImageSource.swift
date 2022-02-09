// This file is generated.
import Foundation

/// An image data source.
///
/// - SeeAlso: [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/#image)
public struct ImageSource: Source {

    public let type: SourceType

    /// URL that points to an image.
    public var url: String?

    /// Corners of image specified in longitude, latitude pairs.
    public var coordinates: [[Double]]?

    /// When loading a map, if PrefetchZoomDelta is set to any number greater than 0, the map will first request a tile at zoom level lower than zoom - delta, but so that the zoom level is multiple of delta, in an attempt to display a full map at lower resolution as quick as possible. It will get clamped at the tile source minimum zoom. The default delta is 4.
    public var prefetchZoomDelta: Double?

    public init() {
        self.type = .image
    }
}

// End of generated file.
