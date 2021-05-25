import UIKit
import Turf
@_implementationOnly import MapboxCommon_Private

public enum AnnotationType {
    case point
    case polyline
    case polygon
    case circle
}

public protocol Annotation: Hashable {
    
    /// The unique identifier of the annotation.
    var id: String { get }
    
    /// The feature that is backing this annotation.
    var feature: Turf.Feature { get }
    
    /// The geometry associated with an annotation.
    var type: AnnotationType { get }
    
    /// A Boolean value that indicates whether an annotation is selected, either
    /// programmatically or via user-interactions.
    var isSelected: Bool { get set }

    /// Properties associated with the annotation
    var userInfo: [String: Any]? { get set }
}

public protocol AnnotationManager {
    
//    associatedtype A where A: Hashable
    
    var id: String { get }
    
    
//    var annotations: Set<A> { get set }
    
    var sourceId: String { get }
    
    var layerId: String { get }
}


public class AnnotationOrchestrator {
    
    private weak var view: UIView?
    
    private weak var style: Style?
    
    private weak var mapFeatureQueryable: MapFeatureQueryable?

    internal init(view: UIView, mapFeatureQueryable: MapFeatureQueryable, style: Style) {
        self.view = view
        self.mapFeatureQueryable = mapFeatureQueryable
        self.style = style
    }
    
    public func makePointAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                           layerPosition: LayerPosition? = nil) -> PointAnnotationManager {
        
        guard let view = view, let mapFeatureQueryable = mapFeatureQueryable, let style = style else {
            fatalError("Style must be present when creating an annotation manager")
        }
        
        return PointAnnotationManager(id: id,
                                      style: style,
                                      view: view,
                                      mapFeatureQueryable: mapFeatureQueryable,
                                      layerPosition: layerPosition)
    }
    
    public func makePolygonAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                             layerPosition: LayerPosition? = nil) -> PolygonAnnotationManager {
        
        guard let view = view, let mapFeatureQueryable = mapFeatureQueryable, let style = style else {
            fatalError("Style must be present when creating an annotation manager")
        }
        
        return PolygonAnnotationManager(id: id,
                                        style: style,
                                        view: view,
                                        mapFeatureQueryable: mapFeatureQueryable,
                                        layerPosition: layerPosition)
    }
    
    public func makePolylineAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                              layerPosition: LayerPosition? = nil) -> PolylineAnnotationManager {
        
        guard let view = view, let mapFeatureQueryable = mapFeatureQueryable, let style = style else {
            fatalError("Style must be present when creating an annotation manager")
        }
        
        return PolylineAnnotationManager(id: id,
                                         style: style,
                                         view: view,
                                         mapFeatureQueryable: mapFeatureQueryable,
                                         layerPosition: layerPosition)
    }
    
    public func makeCircleAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                            layerPosition: LayerPosition? = nil) -> CircleAnnotationManager {
        
        guard let view = view, let mapFeatureQueryable = mapFeatureQueryable, let style = style else {
            fatalError("Style must be present when creating an annotation manager")
        }
        
        return CircleAnnotationManager(id: id,
                                       style: style,
                                       view: view,
                                       mapFeatureQueryable: mapFeatureQueryable,
                                       layerPosition: layerPosition)
    }
}

