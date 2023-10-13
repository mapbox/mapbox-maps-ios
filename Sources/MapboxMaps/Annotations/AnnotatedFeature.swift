import MapboxCoreMaps

/// Represents either a GeoJSON geometry or an annotated layer feature.
public struct AnnotatedFeature: Equatable {
    /// Represents a specific feature rendered on the layer.
    public struct LayerFeature: Equatable {
        var layerId: String
        var featureId: String?
    }

    /// GeoJSON geometry.
    public var geometry: Geometry?

    /// Layer feature.
    public var layerFeature: LayerFeature?

    /// Creates Annotated feature from layer feature.
    public static func layerFeature(layerId: String, featureId: String? = nil) -> AnnotatedFeature {
        return .init(layerFeature: .init(layerId: layerId, featureId: featureId))
    }

    /// Creates Annotated feature from GeoJSON geometry.
    public static func geometry(_ geometry: GeometryConvertible) -> AnnotatedFeature {
        return .init(geometry: geometry.geometry)
    }

    static func from(core: MapboxCoreMaps.AnnotatedFeature) -> AnnotatedFeature? {
        if core.isAnnotatedLayerFeature() {
            let f = core.getAnnotatedLayerFeature()
            return .layerFeature(layerId: f.layerId, featureId: f.featureId)
        }

        if core.isGeometry(), let geometry = Geometry(core.getGeometry()) {
            return .geometry(geometry)
        }

        return nil
    }

    var asCoreFeature: MapboxCoreMaps.AnnotatedFeature? {
        if let geometry {
            return .fromGeometry(MapboxCommon.Geometry(geometry))
        } else if let layerFeature {
            return .fromAnnotatedLayerFeature(AnnotatedLayerFeature(layerId: layerFeature.layerId, featureId: layerFeature.featureId))
        }
        return nil
    }
}
