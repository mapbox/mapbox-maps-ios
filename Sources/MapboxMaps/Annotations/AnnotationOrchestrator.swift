import UIKit
@_implementationOnly import MapboxCommon_Private

public protocol Annotation {

    /// The unique identifier of the annotation.
    var id: String { get }

    /// The geometry that is backing this annotation.
    var geometry: Turf.Geometry { get }

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

public class AnnotationOrchestrator {

    private weak var singleTapGestureRecognizer: UIGestureRecognizer?

    private let style: Style

    private let mapFeatureQueryable: MapFeatureQueryable

    private weak var displayLinkCoordinator: DisplayLinkCoordinator?

    internal init(singleTapGestureRecognizer: UIGestureRecognizer,
                  mapFeatureQueryable: MapFeatureQueryable,
                  style: Style,
                  displayLinkCoordinator: DisplayLinkCoordinator) {
        self.singleTapGestureRecognizer = singleTapGestureRecognizer
        self.mapFeatureQueryable = mapFeatureQueryable
        self.style = style
        self.displayLinkCoordinator = displayLinkCoordinator
    }

    /// Creates a `PointAnnotationManager` which is used to manage a collection of `PointAnnotation`s. The collection of `PointAnnotation` collection will persist across style changes.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `PointAnnotationManager`
    public func makePointAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                           layerPosition: LayerPosition? = nil) -> PointAnnotationManager {

        guard let singleTapGestureRecognizer = singleTapGestureRecognizer,
              let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("SingleTapGestureRecognizer and displayLinkCoordinator must be present when creating an annotation manager")
        }

        return PointAnnotationManager(id: id,
                                      style: style,
                                      singleTapGestureRecognizer: singleTapGestureRecognizer,
                                      mapFeatureQueryable: mapFeatureQueryable,
                                      shouldPersist: true,
                                      layerPosition: layerPosition,
                                      displayLinkCoordinator: displayLinkCoordinator)
    }

    /// Creates a `PolygonAnnotationManager` which is used to manage a collection of `PolygonAnnotation`s. The collection of `PolygonAnnotation`s will persist across style changes.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager..
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `PolygonAnnotationManager`
    public func makePolygonAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                             layerPosition: LayerPosition? = nil) -> PolygonAnnotationManager {

        guard let singleTapGestureRecognizer = singleTapGestureRecognizer,
              let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("SingleTapGestureRecognizer and displayLinkCoordinator must be present when creating an annotation manager")
        }

        return PolygonAnnotationManager(id: id,
                                        style: style,
                                        singleTapGestureRecognizer: singleTapGestureRecognizer,
                                        mapFeatureQueryable: mapFeatureQueryable,
                                        shouldPersist: true,
                                        layerPosition: layerPosition,
                                        displayLinkCoordinator: displayLinkCoordinator)
    }

    /// Creates a `PolylineAnnotationManager` which is used to manage a collection of `PolylineAnnotation`s. The collection of `PolylineAnnotation`s will persist across style changes.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `PolylineAnnotationManager`
    public func makePolylineAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                              layerPosition: LayerPosition? = nil) -> PolylineAnnotationManager {

        guard let singleTapGestureRecognizer = singleTapGestureRecognizer,
              let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("SingleTapGestureRecognizer and displayLinkCoordinator must be present when creating an annotation manager")
        }

        return PolylineAnnotationManager(id: id,
                                         style: style,
                                         singleTapGestureRecognizer: singleTapGestureRecognizer,
                                         mapFeatureQueryable: mapFeatureQueryable,
                                         shouldPersist: true,
                                         layerPosition: layerPosition,
                                         displayLinkCoordinator: displayLinkCoordinator)
    }

    /// Creates a `CircleAnnotationManager` which is used to manage a collection of `CircleAnnotation`s.  The collection of `CircleAnnotation`s will persist across style changes.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `CircleAnnotationManager`
    public func makeCircleAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                            layerPosition: LayerPosition? = nil) -> CircleAnnotationManager {

        guard let singleTapGestureRecognizer = singleTapGestureRecognizer,
              let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("SingleTapGestureRecognizer and displayLinkCoordinator must be present when creating an annotation manager")
        }

        return CircleAnnotationManager(id: id,
                                       style: style,
                                       singleTapGestureRecognizer: singleTapGestureRecognizer,
                                       mapFeatureQueryable: mapFeatureQueryable,
                                       shouldPersist: true,
                                       layerPosition: layerPosition,
                                       displayLinkCoordinator: displayLinkCoordinator)
    }
}
