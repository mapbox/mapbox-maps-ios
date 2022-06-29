// This file is generated.
import Foundation

/// A GeoJSON data source.
///
/// - SeeAlso: [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/#geo_json)
public struct GeoJSONSource: Source {

    public let type: SourceType

    /// A URL to a GeoJSON file, or inline GeoJSON.
    public var data: GeoJSONSourceData?

    /// Maximum zoom level at which to create vector tiles (higher means greater detail at high zoom levels).
    public var maxzoom: Double?

    /// Contains an attribution to be displayed when the map is shown to a user.
    public var attribution: String?

    /// Size of the tile buffer on each side. A value of 0 produces no buffer. A value of 512 produces a buffer as wide as the tile itself. Larger values produce fewer rendering artifacts near tile edges and slower performance.
    public var buffer: Double?

    /// Douglas-Peucker simplification tolerance (higher means simpler geometries and faster performance).
    public var tolerance: Double?

    /// If the data is a collection of point features, setting this to true clusters the points by radius into groups. Cluster groups become new `Point` features in the source with additional properties:
    ///  * `cluster` Is `true` if the point is a cluster
    ///  * `cluster_id` A unqiue id for the cluster to be used in conjunction with the [cluster inspection methods](https://www.mapbox.com/mapbox-gl-js/api/#geojsonsource#getclusterexpansionzoom)
    ///  * `point_count` Number of original points grouped into this cluster
    ///  * `point_count_abbreviated` An abbreviated point count
    public var cluster: Bool?

    /// Radius of each cluster if clustering is enabled. A value of 512 indicates a radius equal to the width of a tile.
    public var clusterRadius: Double?

    /// Max zoom on which to cluster points if clustering is enabled. Defaults to one zoom less than maxzoom (so that last zoom features are not clustered). Clusters are re-evaluated at integer zoom levels so setting clusterMaxZoom to 14 means the clusters will be displayed until z15.
    public var clusterMaxZoom: Double?

    /// An object defining custom properties on the generated clusters if clustering is enabled, aggregating values from clustered points. Has the form `{"property_name": [operator, map_expression]}`. `operator` is any expression function that accepts at least 2 operands (e.g. `"+"` or `"max"`) — it accumulates the property value from clusters/points the cluster contains; `map_expression` produces the value of a single point.
    ///
    /// Example: `{"sum": ["+", ["get", "scalerank"]]}`.
    ///
    /// For more advanced use cases, in place of `operator`, you can use a custom reduce expression that references a special `["accumulated"]` value, e.g.:
    /// `{"sum": [["+", ["accumulated"], ["get", "sum"]], ["get", "scalerank"]]}`
    public var clusterProperties: [String: Expression]?

    /// Whether to calculate line distance metrics. This is required for line layers that specify `line-gradient` values.
    public var lineMetrics: Bool?

    /// Whether to generate ids for the geojson features. When enabled, the `feature.id` property will be auto assigned based on its index in the `features` array, over-writing any previous values.
    public var generateId: Bool?

    /// A property to use as a feature id (for feature state). Either a property name, or an object of the form `{<sourceLayer>: <propertyName>}`.
    public var promoteId: PromoteId?

    /// When loading a map, if PrefetchZoomDelta is set to any number greater than 0, the map will first request a tile at zoom level lower than zoom - delta, but so that the zoom level is multiple of delta, in an attempt to display a full map at lower resolution as quick as possible. It will get clamped at the tile source minimum zoom. The default delta is 4.
    public var prefetchZoomDelta: Double?

    public init() {
        self.type = .geoJson
    }
}

extension GeoJSONSource {
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case data = "data"
        case maxzoom = "maxzoom"
        case attribution = "attribution"
        case buffer = "buffer"
        case tolerance = "tolerance"
        case cluster = "cluster"
        case clusterRadius = "clusterRadius"
        case clusterMaxZoom = "clusterMaxZoom"
        case clusterProperties = "clusterProperties"
        case lineMetrics = "lineMetrics"
        case generateId = "generateId"
        case promoteId = "promoteId"
        case prefetchZoomDelta = "prefetch-zoom-delta"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if encoder.userInfo[.volatilePropertiesOnly] as? Bool == true  {
            try encodeVolatile(to: encoder, into: &container)
        } else if encoder.userInfo[.nonVolatilePropertiesOnly] as? Bool == true  {
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
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(data, forKey: .data)
        try container.encodeIfPresent(maxzoom, forKey: .maxzoom)
        try container.encodeIfPresent(attribution, forKey: .attribution)
        try container.encodeIfPresent(buffer, forKey: .buffer)
        try container.encodeIfPresent(tolerance, forKey: .tolerance)
        try container.encodeIfPresent(cluster, forKey: .cluster)
        try container.encodeIfPresent(clusterRadius, forKey: .clusterRadius)
        try container.encodeIfPresent(clusterMaxZoom, forKey: .clusterMaxZoom)
        try container.encodeIfPresent(clusterProperties, forKey: .clusterProperties)
        try container.encodeIfPresent(lineMetrics, forKey: .lineMetrics)
        try container.encodeIfPresent(generateId, forKey: .generateId)
        try container.encodeIfPresent(promoteId, forKey: .promoteId)
    }
}
// End of generated file.
