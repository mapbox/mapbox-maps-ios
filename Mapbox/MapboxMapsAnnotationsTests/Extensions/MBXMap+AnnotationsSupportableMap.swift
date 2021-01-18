import MapboxCoreMaps
import MapboxCommon

#if canImport(Mapbox)
@testable import Mapbox
#else
@testable import MapboxMapsAnnotations
#endif

extension Map: AnnotationsSupportableMap {
    func addStyleSource(forSourceId sourceId: String, properties: Any) { }

    func addStyleLayer(forProperties properties: Any, layerPosition: LayerPosition?) { }

    //swiftlint:disable function_parameter_count
    func addStyleImage(forImageId imageId: String,
                       scale: Float,
                       image: Image,
                       sdf: Bool,
                       stretchX: [ImageStretches],
                       stretchY: [ImageStretches],
                       content: ImageContent?) { }

    func setStyleLayerPropertyForLayerId(_ layerId: String, property: String, value: Any) { }

    func removeStyleImage(forImageId: String) { }

    func removeStyleLayer(forLayerId: String) { }

    func removeStyleSource(forSourceId: String) { }
}
