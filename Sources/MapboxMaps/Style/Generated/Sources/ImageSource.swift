// This file is generated.
import Foundation

/// An image data source.
///
/// - SeeAlso: [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/#image)
public struct ImageSource: Source {

    public let type: SourceType
    public let id: String

    /// URL that points to an image. If the URL is not specified, the image is expected to be loaded directly during runtime.
    public var url: String?

    /// Corners of image specified in longitude, latitude pairs. Note: When using globe projection, the image will be centered at the North or South Pole in the respective hemisphere if the average latitude value exceeds 85 degrees or falls below -85 degrees.
    public var coordinates: [[Double]]?

    /// When loading a map, if PrefetchZoomDelta is set to any number greater than 0, the map will first request a tile at zoom level lower than zoom - delta, but so that the zoom level is multiple of delta, in an attempt to display a full map at lower resolution as quick as possible. It will get clamped at the tile source minimum zoom.
    /// Default value: 4.
    public var prefetchZoomDelta: Double?

    public init(id: String) {
        self.id = id
        self.type = .image
    }
}

extension ImageSource {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case url = "url"
        case coordinates = "coordinates"
        case prefetchZoomDelta = "prefetch-zoom-delta"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if encoder.userInfo[.volatilePropertiesOnly] as? Bool == true {
            try encodeVolatile(to: encoder, into: &container)
        } else if encoder.userInfo[.nonVolatilePropertiesOnly] as? Bool == true {
            try encodeNonVolatile(to: encoder, into: &container)
        } else {
            try encodeVolatile(to: encoder, into: &container)
            try encodeNonVolatile(to: encoder, into: &container)
        }
    }

    private func encodeVolatile(to encoder: Encoder, into container: inout KeyedEncodingContainer<CodingKeys>) throws {
        try container.encodeIfPresent(prefetchZoomDelta, forKey: .prefetchZoomDelta)
    }

    private func encodeNonVolatile(to encoder: Encoder, into container: inout KeyedEncodingContainer<CodingKeys>) throws {
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(coordinates, forKey: .coordinates)
    }
}

extension ImageSource {

    /// URL that points to an image. If the URL is not specified, the image is expected to be loaded directly during runtime.
    public func url(_ newValue: String) -> Self {
        with(self, setter(\.url, newValue))
    }

    /// Corners of image specified in longitude, latitude pairs. Note: When using globe projection, the image will be centered at the North or South Pole in the respective hemisphere if the average latitude value exceeds 85 degrees or falls below -85 degrees.
    public func coordinates(_ newValue: [[Double]]) -> Self {
        with(self, setter(\.coordinates, newValue))
    }

    /// When loading a map, if PrefetchZoomDelta is set to any number greater than 0, the map will first request a tile at zoom level lower than zoom - delta, but so that the zoom level is multiple of delta, in an attempt to display a full map at lower resolution as quick as possible. It will get clamped at the tile source minimum zoom.
    /// Default value: 4.
    public func prefetchZoomDelta(_ newValue: Double) -> Self {
        with(self, setter(\.prefetchZoomDelta, newValue))
    }
}
// End of generated file.
