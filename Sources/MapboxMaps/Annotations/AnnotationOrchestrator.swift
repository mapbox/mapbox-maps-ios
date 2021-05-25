import Foundation
import Turf

public protocol AnnotationInteractionDelegate {
    func didSelectAnnotation(annotation: Annotation_Legacy)
    func didDeselectAnnotation(annotation: Annotation_Legacy)
}

public enum AnnotationType {
    case point
    case polyline
    case polygon
    case circle
}

public protocol Annotation {
    
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


public struct AnnotationOrchestrator {
    
    private weak var view: UIView?
    
    private weak var style: Style?
    
    private weak var mapFeatureQueryable: MapFeatureQueryable?
     
    internal init(view: UIView, mapFeatureQueryable: MapFeatureQueryable, style: Style) {
        self.view = view
        self.mapFeatureQueryable = mapFeatureQueryable
        self.style = style
    }
    
    public func makePointAnnotationManager(id: String = String(UUID().uuidString.prefix(5)), layerPosition: LayerPosition? = nil) -> PointAnnotationManager {
        
        guard let style = style else {
            fatalError("Style must be present when creating an annotation manager")
        }
        
        return PointAnnotationManager(id: id,
                                      style: style, layerPosition: layerPosition)
    }
    
    public func makePolygonAnnotationManager(id: String = String(UUID().uuidString.prefix(5)), layerPosition: LayerPosition? = nil) -> PolygonAnnotationManager {
        
        guard let style = style else {
            fatalError("Style must be present when creating an annotation manager")
        }
        
        return PolygonAnnotationManager(id: id,
                                        style: style, layerPosition: layerPosition)
    }
    
    public func makePolylineAnnotationManager(id: String = String(UUID().uuidString.prefix(5)), layerPosition: LayerPosition? = nil) -> PolylineAnnotationManager {
        
        guard let style = style else {
            fatalError("Style must be present when creating an annotation manager")
        }
        
        return PolylineAnnotationManager(id: id,
                                         style: style, layerPosition: layerPosition)
    }
    
    public func makeCircleAnnotationManager(id: String = String(UUID().uuidString.prefix(5)), layerPosition: LayerPosition? = nil) -> CircleAnnotationManager {
        
        guard let style = style else {
            fatalError("Style must be present when creating an annotation manager")
        }
        
        return CircleAnnotationManager(id: id,
                                       style: style, layerPosition: layerPosition)
    }
}

