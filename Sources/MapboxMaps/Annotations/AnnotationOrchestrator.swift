import UIKit
import Turf
@_implementationOnly import MapboxCommon_Private

public protocol Annotation {

    /// The unique identifier of the annotation.
    var id: String { get }

    /// The feature that is backing this annotation.
    var feature: Turf.Feature { get }

    /// Properties associated with the annotation.
    var userInfo: [String: Any]? { get set }
}

public protocol AnnotationManager {

    /// The id of this annotation manager.
    var id: String { get }

    /// The id of the `GeoJSONSource` that this manager is responsible for.
    var sourceId: String { get }

    /// The id of the layer that this manager is responsible for.
    var layerId: String { get }
}

/// A delegate that is called when a tap is detected on an annotation (or on several of them).
public protocol AnnotationInteractionDelegate: AnyObject {

    /// This method is invoked when a tap gesture is detected on an annotation
    /// - Parameters:
    ///   - manager: The `AnnotationManager` that detected this tap gesture
    ///   - annotations: A list of `Annotations` that were tapped
    func annotationManager(_ manager: AnnotationManager,
                           didDetectTappedAnnotations annotations: [Annotation])

}

public protocol AnnotationDragDelegate: AnyObject {
    func annotationManager(_manager: AnnotationManager, didDragStart annotations: Annotation)
    func annotationManager(_manager: AnnotationManager, didDrag annotations: Annotation)
    func annotationManager(_manager: AnnotationManager, didDragEnd annotations: Annotation)
}

public class AnnotationOrchestrator {

    private weak var view: MapView?

    private weak var style: Style?

    private weak var mapFeatureQueryable: MapFeatureQueryable?

    internal init(view: MapView, mapFeatureQueryable: MapFeatureQueryable, style: Style) {
        self.view = view
        self.mapFeatureQueryable = mapFeatureQueryable
        self.style = style
    }

    /// Creates a `PointAnnotationManager` which is used to manage a collection of `PointAnnotation`s. The collection of `PointAnnotation` collection will persist across style changes.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `PointAnnotationManager`
    public func makePointAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                           layerPosition: LayerPosition? = nil) -> PointAnnotationManager {

        guard let view = view, let mapFeatureQueryable = mapFeatureQueryable, let style = style else {
            fatalError("Style must be present when creating an annotation manager")
        }

        return PointAnnotationManager(id: id,
                                      style: style,
                                      view: view,
                                      mapFeatureQueryable: mapFeatureQueryable,
                                      shouldPersist: true,
                                      layerPosition: layerPosition)
    }

    /// Creates a `PolygonAnnotationManager` which is used to manage a collection of `PolygonAnnotation`s. The collection of `PolygonAnnotation`s will persist across style changes.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager..
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `PolygonAnnotationManager`
    public func makePolygonAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                             layerPosition: LayerPosition? = nil) -> PolygonAnnotationManager {

        guard let view = view, let mapFeatureQueryable = mapFeatureQueryable, let style = style else {
            fatalError("Style must be present when creating an annotation manager")
        }

        return PolygonAnnotationManager(id: id,
                                        style: style,
                                        view: view,
                                        mapFeatureQueryable: mapFeatureQueryable,
                                        shouldPersist: true,
                                        layerPosition: layerPosition)
    }

    /// Creates a `PolylineAnnotationManager` which is used to manage a collection of `PolylineAnnotation`s. The collection of `PolylineAnnotation`s will persist across style changes.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `PolylineAnnotationManager`
    public func makePolylineAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                              layerPosition: LayerPosition? = nil) -> PolylineAnnotationManager {

        guard let view = view, let mapFeatureQueryable = mapFeatureQueryable, let style = style else {
            fatalError("Style must be present when creating an annotation manager")
        }

        return PolylineAnnotationManager(id: id,
                                         style: style,
                                         view: view,
                                         mapFeatureQueryable: mapFeatureQueryable,
                                         shouldPersist: true,
                                         layerPosition: layerPosition)
    }

    /// Creates a `CircleAnnotationManager` which is used to manage a collection of `CircleAnnotation`s.  The collection of `CircleAnnotation`s will persist across style changes.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `CircleAnnotationManager`
    public func makeCircleAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                            layerPosition: LayerPosition? = nil) -> CircleAnnotationManager {

        guard let view = view, let mapFeatureQueryable = mapFeatureQueryable, let style = style else {
            fatalError("Style must be present when creating an annotation manager")
        }

        return CircleAnnotationManager(id: id,
                                       style: style,
                                       view: view,
                                       mapFeatureQueryable: mapFeatureQueryable,
                                       shouldPersist: true,
                                       layerPosition: layerPosition)
    }
}
