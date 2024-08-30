import MapboxCoreMaps

/// Represents either a GeoJSON geometry or an annotated layer feature.
public struct AnnotatedFeature: Equatable, Sendable {
    /// Represents a specific feature rendered on the layer.
    public struct LayerFeature: Equatable, Sendable {
        /// Identifier of the layer, that renders the feature.
        public var layerId: String

        /// Feature identifier. If not specified, the annotation will appear on any feature from that layer.
        public var featureId: String?
    }

    /// GeoJSON geometry.
    public var geometry: Geometry?

    /// Layer feature.
    public var layerFeature: LayerFeature?

    /// Creates Annotated feature from layer feature.
    ///
    /// - Parameters:
    ///   - layerId: Identifier of the layer, that renders the feature.
    ///   - featureId: Feature identifier. If not specified, the annotation will appear on any feature from that layer.
    public static func layerFeature(layerId: String, featureId: String? = nil) -> AnnotatedFeature {
        return .init(layerFeature: .init(layerId: layerId, featureId: featureId))
    }

    /// Creates Annotated feature from GeoJSON geometry.
    ///
    /// - Parameters:
    ///  - geometry: A geometry-convertible object, such as `Point`, `LineString` and others.
    public static func geometry(_ geometry: GeometryConvertible) -> AnnotatedFeature {
        return .init(geometry: geometry.geometry)
    }

    static func from(core: CoreAnnotatedFeature) -> AnnotatedFeature? {
        if core.isAnnotatedLayerFeature() {
            let f = core.getAnnotatedLayerFeature()
            return .layerFeature(layerId: f.layerId, featureId: f.featureId)
        }

        if core.isGeometry(), let geometry = Geometry(core.getGeometry()) {
            return .geometry(geometry)
        }

        return nil
    }

    var asCoreFeature: CoreAnnotatedFeature? {
        if let geometry {
            return .fromGeometry(MapboxCommon.Geometry(geometry))
        } else if let layerFeature {
            return .fromAnnotatedLayerFeature(CoreAnnotatedLayerFeature(layerId: layerFeature.layerId, featureId: layerFeature.featureId))
        }
        return nil
    }
}
