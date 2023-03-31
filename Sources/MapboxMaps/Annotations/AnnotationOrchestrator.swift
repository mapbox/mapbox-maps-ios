import UIKit

/// A top-level interface for annotations.
public protocol Annotation {

    /// The unique identifier of the annotation.
    var id: String { get }

    /// The geometry that is backing this annotation.
    var geometry: Geometry { get }

    /// Properties associated with the annotation.
    var userInfo: [String: Any]? { get set }
}

public protocol AnnotationManager: AnyObject {

    /// The id of this annotation manager.
    var id: String { get }

    /// The id of the `GeoJSONSource` that this manager is responsible for.
    var sourceId: String { get }

    /// The id of the layer that this manager is responsible for.
    var layerId: String { get }
}

internal protocol AnnotationManagerInternal: AnnotationManager {
    var allLayerIds: [String] { get }

    func destroy()

    func handleQueriedFeatureIds(_ queriedFeatureIds: [String])

    func handleDragBegin(with featureIdentifiers: [String])

    func handleDragChanged(with translation: CGPoint)

    func handleDragEnded()
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

/// `AnnotationOrchestrator` provides a way to create annotation managers of different types.
public final class AnnotationOrchestrator {
    private let impl: AnnotationOrchestratorImplProtocol

    internal init(impl: AnnotationOrchestratorImplProtocol) {
        self.impl = impl
    }

    /// Dictionary of annotation managers keyed by their identifiers.
    public var annotationManagersById: [String: AnnotationManager] { impl.annotationManagersById }

    /// Creates a `PointAnnotationManager` which is used to manage a collection of
    /// `PointAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called. `AnnotationOrchestrator`
    ///  keeps a strong reference to any `PointAnnotationManager` until it is removed.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    ///   - clusterOptions: Optionally set the `ClusterOptions` to cluster the Point Annotations
    /// - Returns: An instance of `PointAnnotationManager`
    public func makePointAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                           layerPosition: LayerPosition? = nil,
                                           clusterOptions: ClusterOptions? = nil) -> PointAnnotationManager {
        // swiftlint:disable:next force_cast
        return impl.makePointAnnotationManager(id: id, layerPosition: layerPosition, clusterOptions: clusterOptions) as! PointAnnotationManager
    }

    /// Creates a `PolygonAnnotationManager` which is used to manage a collection of
    /// `PolygonAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called. `AnnotationOrchestrator`
    ///  keeps a strong reference to any `PolygonAnnotationManager` until it is removed.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager..
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `PolygonAnnotationManager`
    public func makePolygonAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                             layerPosition: LayerPosition? = nil) -> PolygonAnnotationManager {
        // swiftlint:disable:next force_cast
        return impl.makePolygonAnnotationManager(id: id, layerPosition: layerPosition) as! PolygonAnnotationManager
    }

    /// Creates a `PolylineAnnotationManager` which is used to manage a collection of
    /// `PolylineAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called. `AnnotationOrchestrator`
    ///  keeps a strong reference to any `PolylineAnnotationManager` until it is removed.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `PolylineAnnotationManager`
    public func makePolylineAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                              layerPosition: LayerPosition? = nil) -> PolylineAnnotationManager {
        // swiftlint:disable:next force_cast
        return impl.makePolylineAnnotationManager(id: id, layerPosition: layerPosition) as! PolylineAnnotationManager
    }

    /// Creates a `CircleAnnotationManager` which is used to manage a collection of
    /// `CircleAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called. `AnnotationOrchestrator`
    ///  keeps a strong reference to any `CircleAnnotationManager` until it is removed.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `CircleAnnotationManager`
    public func makeCircleAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                            layerPosition: LayerPosition? = nil) -> CircleAnnotationManager {
        // swiftlint:disable:next force_cast
        return impl.makeCircleAnnotationManager(id: id, layerPosition: layerPosition) as! CircleAnnotationManager
    }

    /// Removes an annotation manager, this will remove the underlying layer and source from the style.
    /// A removed annotation manager will not be able to reuse anymore, you will need to create new annotation manger to add annotations.
    /// - Parameter id: Identifer of annotation manager to remove
    public func removeAnnotationManager(withId id: String) {
        impl.removeAnnotationManager(withId: id)
    }
}
