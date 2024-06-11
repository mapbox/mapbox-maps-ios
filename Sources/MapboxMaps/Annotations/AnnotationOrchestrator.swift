import UIKit

public protocol AnnotationManager: AnyObject {

    /// The id of this annotation manager.
    var id: String { get }

    /// The id of the `GeoJSONSource` that this manager is responsible for.
    var sourceId: String { get }

    /// The id of the layer that this manager is responsible for.
    var layerId: String { get }

    /// Slot for the underlying layer.
    ///
    /// Use this property to position the annotations relative to other map features if you use Mapbox Standard Style.
    /// See <doc:Migrate-to-v11##21-The-Mapbox-Standard-Style> for more info.
    var slot: String? { get set }
}

protocol AnnotationManagerInternal: AnnotationManager {
    var allLayerIds: [String] { get }

    func destroy()

    func handleTap(layerId: String, feature: Feature, context: MapContentGestureContext) -> Bool

    func handleLongPress(layerId: String, feature: Feature, context: MapContentGestureContext) -> Bool

    func handleDragBegin(with featureId: String, context: MapContentGestureContext) -> Bool

    func handleDragChange(with translation: CGPoint, context: MapContentGestureContext)

    func handleDragEnd(context: MapContentGestureContext)
}

struct AnnotationGestureHandlers<T: Annotation> {
    var tap: ((MapContentGestureContext) -> Bool)?
    var longPress: ((MapContentGestureContext) -> Bool)?
    var dragBegin: ((inout T, MapContentGestureContext) -> Bool)?
    var dragChange: ((inout T, MapContentGestureContext) -> Void)?
    var dragEnd: ((inout T, MapContentGestureContext) -> Void)?
}

/// A delegate that is called when a tap is detected on an annotation (or on several of them).
///
/// - Important: This protocol is deprecated, use`tapHandler` property of `Annotation`.
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

    init(impl: AnnotationOrchestratorImplProtocol) {
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
    ///  - id: Optional string identifier for this manager.
    ///  - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    ///  - clusterOptions: Optionally set the `ClusterOptions` to cluster the Point Annotations
    ///  - onClusterTap: Closure that will be executed after the long press gesture processsed.
    ///  - onClusterLongPress: Closure that will be executed after the tap gesture will be processed on the map
    /// - Returns: An instance of `PointAnnotationManager`
    public func makePointAnnotationManager(
        id: String = String(UUID().uuidString.prefix(5)),
        layerPosition: LayerPosition? = nil,
        clusterOptions: ClusterOptions? = nil,
        onClusterTap: ((AnnotationClusterGestureContext) -> Void)? = nil,
        onClusterLongPress: ((AnnotationClusterGestureContext) -> Void)? = nil
    ) -> PointAnnotationManager {
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
