import UIKit
@_implementationOnly import MapboxCommon_Private

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
    var delegate: AnnotationInteractionDelegate? { get }

    func destroy()

    func handleQueriedFeatureIds(_ queriedFeatureIds: [String])
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

    private let gestureRecognizer: UIGestureRecognizer

    private let style: Style

    private let mapFeatureQueryable: MapFeatureQueryable

    private weak var displayLinkCoordinator: DisplayLinkCoordinator?

    internal init(gestureRecognizer: UIGestureRecognizer,
                  mapFeatureQueryable: MapFeatureQueryable,
                  style: Style,
                  displayLinkCoordinator: DisplayLinkCoordinator) {
        self.gestureRecognizer = gestureRecognizer
        self.mapFeatureQueryable = mapFeatureQueryable
        self.style = style
        self.displayLinkCoordinator = displayLinkCoordinator

        gestureRecognizer.addTarget(self, action: #selector(handleTap(_:)))
    }

    /// Dictionary of annotation managers keyed by their identifiers.
    public var annotationManagersById: [String: AnnotationManager] {
        annotationManagersByIdInternal
    }

    private var annotationManagersByIdInternal = [String: AnnotationManagerInternal]()

    /// Creates a `PointAnnotationManager` which is used to manage a collection of
    /// `PointAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called. `AnnotationOrchestrator`
    ///  keeps a strong reference to any `PointAnnotationManager` until it is removed.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `PointAnnotationManager`
    public func makePointAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                           layerPosition: LayerPosition? = nil) -> PointAnnotationManager {
        guard let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("DisplayLinkCoordinator must be present when creating an annotation manager")
        }
        removeAnnotationManager(withId: id, warnIfRemoved: true, function: #function)
        let annotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: layerPosition,
            displayLinkCoordinator: displayLinkCoordinator)
        annotationManagersByIdInternal[id] = annotationManager
        return annotationManager
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
        guard let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("DisplayLinkCoordinator must be present when creating an annotation manager")
        }
        removeAnnotationManager(withId: id, warnIfRemoved: true, function: #function)
        let annotationManager = PolygonAnnotationManager(
            id: id,
            style: style,
            layerPosition: layerPosition,
            displayLinkCoordinator: displayLinkCoordinator)
        annotationManagersByIdInternal[id] = annotationManager
        return annotationManager
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
        guard let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("DisplayLinkCoordinator must be present when creating an annotation manager")
        }
        removeAnnotationManager(withId: id, warnIfRemoved: true, function: #function)
        let annotationManager = PolylineAnnotationManager(
            id: id,
            style: style,
            layerPosition: layerPosition,
            displayLinkCoordinator: displayLinkCoordinator)
        annotationManagersByIdInternal[id] = annotationManager
        return annotationManager
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
        guard let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("DisplayLinkCoordinator must be present when creating an annotation manager")
        }
        removeAnnotationManager(withId: id, warnIfRemoved: true, function: #function)
        let annotationManager = CircleAnnotationManager(
            id: id,
            style: style,
            layerPosition: layerPosition,
            displayLinkCoordinator: displayLinkCoordinator)
        annotationManagersByIdInternal[id] = annotationManager
        return annotationManager
    }

    /// Removes an annotation manager, this will remove the underlying layer and source from the style.
    /// A removed annotation manager will not be able to reuse anymore, you will need to create new annotation manger to add annotations.
    /// - Parameter id: Identifer of annotation manager to remove
    public func removeAnnotationManager(withId id: String) {
        removeAnnotationManager(withId: id, warnIfRemoved: false, function: #function)
    }

    private func removeAnnotationManager(withId id: String, warnIfRemoved: Bool, function: StaticString) {
        guard let annotationManager = annotationManagersByIdInternal.removeValue(forKey: id) else {
            return
        }
        annotationManager.destroy()
        if warnIfRemoved {
            Log.warning(
                forMessage: "\(type(of: annotationManager)) with id \(id) was removed implicitly when invoking \(function) with the same id.",
                category: "Annotations")
        }
    }

    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        let managers = annotationManagersByIdInternal.values.filter { $0.delegate != nil }
        guard !managers.isEmpty else { return }

        let layerIds = managers.map { $0.layerId }
        let options = RenderedQueryOptions(layerIds: layerIds, filter: nil)
        mapFeatureQueryable.queryRenderedFeatures(
            at: tap.location(in: tap.view),
            options: options) { (result) in

            switch result {

            case .success(let queriedFeatures):

                // Get the identifiers of all the queried features
                let queriedFeatureIds: [String] = queriedFeatures.compactMap {
                    guard case let .string(featureId) = $0.feature.identifier else {
                        return nil
                    }
                    return featureId
                }

                for manager in managers {
                    manager.handleQueriedFeatureIds(queriedFeatureIds)
                }
            case .failure(let error):
                Log.warning(forMessage: "Failed to query map for annotations due to error: \(error)",
                            category: "Annotations")
            }
        }
    }
}
