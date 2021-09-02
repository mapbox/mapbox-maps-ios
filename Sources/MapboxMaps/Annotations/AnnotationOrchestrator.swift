import UIKit
@_implementationOnly import MapboxCommon_Private
@_implementationOnly import MapboxCoreMaps_Private

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

    private weak var view: UIView?

    private let style: Style

    private let mapFeatureQueryable: MapFeatureQueryable

    private let mapViewAnnotationHandler: MapViewAnnotationInterface

    private weak var displayLinkCoordinator: DisplayLinkCoordinator?

    internal init(view: UIView, mapFeatureQueryable: MapFeatureQueryable, mapViewAnnotationHandler: MapViewAnnotationInterface, style: Style, displayLinkCoordinator: DisplayLinkCoordinator) {
        self.view = view
        self.mapFeatureQueryable = mapFeatureQueryable
        self.style = style
        self.displayLinkCoordinator = displayLinkCoordinator
        self.mapViewAnnotationHandler = mapViewAnnotationHandler
    }

    /// Creates a `PointAnnotationManager` which is used to manage a collection of `PointAnnotation`s. The collection of `PointAnnotation` collection will persist across style changes.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `PointAnnotationManager`
    public func makePointAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                           layerPosition: LayerPosition? = nil) -> PointAnnotationManager {

        guard let view = view,
              let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("View and displayLinkCoordinator must be present when creating an annotation manager")
        }

        return PointAnnotationManager(id: id,
                                      style: style,
                                      view: view,
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

        guard let view = view,
              let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("View and displayLinkCoordinator must be present when creating an annotation manager")
        }

        return PolygonAnnotationManager(id: id,
                                        style: style,
                                        view: view,
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

        guard let view = view,
              let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("View and displayLinkCoordinator must be present when creating an annotation manager")
        }

        return PolylineAnnotationManager(id: id,
                                         style: style,
                                         view: view,
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

        guard let view = view,
              let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("View and displayLinkCoordinator must be present when creating an annotation manager")
        }

        return CircleAnnotationManager(id: id,
                                       style: style,
                                       view: view,
                                       mapFeatureQueryable: mapFeatureQueryable,
                                       shouldPersist: true,
                                       layerPosition: layerPosition,
                                       displayLinkCoordinator: displayLinkCoordinator)
    }


    // MARK: - View backed annotations -

    internal var viewAnnotationsById: [String: ViewAnnotation] = [:]

    public func addViewAnnotation(_ viewAnnotation: ViewAnnotation) {
        
        mapViewAnnotationHandler.addViewAnnotation(forIdentifier: viewAnnotation.id, options: viewAnnotation.options) { [weak self] positions in
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let view = self.view else { return  }
                self.viewAnnotationsById[viewAnnotation.id] = viewAnnotation
                view.addSubview(viewAnnotation)
                self.placeAnnotations(for: positions)
            }
        }
    }

    public func removeViewAnnotation(_ viewAnnotation: ViewAnnotation) {
        
        mapViewAnnotationHandler.removeViewAnnotation(forIdentifier: viewAnnotation.id) { [weak self ] positions in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return  }
                self.placeAnnotations(for: positions)
                
                // cleanup the view
                viewAnnotation.removeFromSuperview()
                self.viewAnnotationsById.removeValue(forKey: viewAnnotation.id)
            }
        }
        
    }

    public func updateViewAnnotation(_ viewAnnotation: ViewAnnotation) {
        mapViewAnnotationHandler.updateViewAnnotation(forIdentifier: viewAnnotation.id, options: viewAnnotation.options) { [weak self] positions in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else { return }
                
                self.viewAnnotationsById[viewAnnotation.id] = viewAnnotation
                self.placeAnnotations(for: positions)
            }
        }
    }

    
    
    internal func placeAnnotations(for positions: [ViewAnnotationPositionDescriptor]) {

        guard let mapView = view else { return }

        for position in positions {

            // Approach:
            // 1. Get the view for this position's identifier
            // 2. Adjust the origin of the view. If the view is off screen, then hide the view

            let viewAnnotation = viewAnnotationsById[position.identifier]
            let newOriginForAnnotation = position.leftTopCoordinate.point

            if mapView.frame.contains(newOriginForAnnotation) {
                viewAnnotation?.frame.origin = newOriginForAnnotation
                viewAnnotation?.isHidden = false
            } else {
                viewAnnotation?.isHidden = true
            }
        }

    }
}

public protocol ViewAnnotation: UIView {
    var id: String { get }
    var options: ViewAnnotationOptions { get }
}

//
//extension ViewAnnotationsPosition: CustomStringConvertible {
//
//    open override var description: String {
//
//        var description = "-------\n"
//
//        for position in self.positions {
//
//            let positionDescription = """
//            annotaiton id: \(position.identifier)
//            origin.x: \(position.leftTopCoordinate.x)
//            origin.y: \(position.leftTopCoordinate.y)
//            """
//
//            description += positionDescription
//        }
//
//        return description
//    }
//}
