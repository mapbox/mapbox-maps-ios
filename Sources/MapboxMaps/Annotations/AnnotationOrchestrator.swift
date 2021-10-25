import UIKit
@_implementationOnly import MapboxCommon_Private
@_implementationOnly import MapboxCoreMaps_Private

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
    func destroy()
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

public protocol MapViewAnnotationInterface: AnyObject {

    func calculateViewAnnotationsPosition(callback: @escaping ([ViewAnnotationPositionDescriptor]) -> Void)

    /**
     * Add view annotation.
     *
     * @return position for all views that need to be updated on the screen or null if views' placement remained the same.
     */
    func addViewAnnotation(forIdentifier identifier: String, options: ViewAnnotationOptions)

    /**
     * Update view annotation if it exists.
     *
     * @return position for all views that need to be updated on the screen or null if views' placement remained the same.
     */
    func updateViewAnnotation(forIdentifier identifier: String, options: ViewAnnotationOptions)

    /**
     * Remove view annotation if it exists.
     *
     * @return position for all views that need to be updated on the screen or null if views' placement remained the same.
     */
    func removeViewAnnotation(forIdentifier identifier: String)
}

public class AnnotationOrchestrator {

    private weak var view: UIView?

    private let gestureRecognizer: UIGestureRecognizer

    private let style: Style

    private let mapFeatureQueryable: MapFeatureQueryable

    private let mapViewAnnotationHandler: MapViewAnnotationInterface

    private weak var displayLinkCoordinator: DisplayLinkCoordinator?

    internal init(view: UIView,
                  gestureRecognizer: UIGestureRecognizer,
                  mapFeatureQueryable: MapFeatureQueryable,
                  style: Style,
                  displayLinkCoordinator: DisplayLinkCoordinator,
                  mapViewAnnotationHandler: MapViewAnnotationInterface) {
        self.view = view
        self.gestureRecognizer = gestureRecognizer
        self.mapFeatureQueryable = mapFeatureQueryable
        self.style = style
        self.displayLinkCoordinator = displayLinkCoordinator
        self.mapViewAnnotationHandler = mapViewAnnotationHandler
    }

    /// Dictionary of annotation managers keyed by their identifiers.
    public var annotationManagersById: [String: AnnotationManager] {
        annotationManagersByIdInternal
    }

    private var annotationManagersByIdInternal = [String: AnnotationManagerInternal]()

    /// Creates a `PointAnnotationManager` which is used to manage a collection of
    /// `PointAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called.
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
            gestureRecognizer: gestureRecognizer,
            mapFeatureQueryable: mapFeatureQueryable,
            layerPosition: layerPosition,
            displayLinkCoordinator: displayLinkCoordinator)
        annotationManagersByIdInternal[id] = annotationManager
        return annotationManager
    }

    /// Creates a `PolygonAnnotationManager` which is used to manage a collection of
    /// `PolygonAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called.
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
            gestureRecognizer: gestureRecognizer,
            mapFeatureQueryable: mapFeatureQueryable,
            layerPosition: layerPosition,
            displayLinkCoordinator: displayLinkCoordinator)
        annotationManagersByIdInternal[id] = annotationManager
        return annotationManager
    }

    /// Creates a `PolylineAnnotationManager` which is used to manage a collection of
    /// `PolylineAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called.
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
            gestureRecognizer: gestureRecognizer,
            mapFeatureQueryable: mapFeatureQueryable,
            layerPosition: layerPosition,
            displayLinkCoordinator: displayLinkCoordinator)
        annotationManagersByIdInternal[id] = annotationManager
        return annotationManager
    }

    /// Creates a `CircleAnnotationManager` which is used to manage a collection of
    /// `CircleAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called.
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
            gestureRecognizer: gestureRecognizer,
            mapFeatureQueryable: mapFeatureQueryable,
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

    // MARK: - View backed annotations -

    // TODO: Maybe convert to a weak dictionary?
    internal var viewAnnotationsById: [String: ViewAnnotation] = [:]

    public func addViewAnnotation(_ viewAnnotation: ViewAnnotation) {
        guard let view = view else { return }

        mapViewAnnotationHandler.addViewAnnotation(
            forIdentifier: viewAnnotation.id,
            options: viewAnnotation.options)

        viewAnnotationsById[viewAnnotation.id] = viewAnnotation
        viewAnnotation.isHidden = false
        view.addSubview(viewAnnotation)

        placeAnnotations()
    }

    public func removeViewAnnotation(_ viewAnnotation: ViewAnnotation) {
        mapViewAnnotationHandler.removeViewAnnotation(
            forIdentifier: viewAnnotation.id)
        viewAnnotation.removeFromSuperview()
        viewAnnotationsById.removeValue(forKey: viewAnnotation.id)
        placeAnnotations()
    }

    public func updateViewAnnotation(_ viewAnnotation: ViewAnnotation) {
        mapViewAnnotationHandler.updateViewAnnotation(forIdentifier: viewAnnotation.id, options: viewAnnotation.options)

        viewAnnotationsById[viewAnnotation.id] = viewAnnotation
        placeAnnotations()
    }

    internal func placeAnnotations() {

        mapViewAnnotationHandler.calculateViewAnnotationsPosition { [weak self] positions in

            DispatchQueue.main.async { [weak self] in

                guard let self = self else { return }

                var visibleAnnotationIds: Set<String> = []

                for position in positions {

                    // Approach:
                    // 1. Get the view for this position's identifier
                    // 2. Adjust the origin of the view. If the view's center is off screen, then hide the view

                    guard let viewAnnotation = self.viewAnnotationsById[position.identifier] else {
                        fatalError()
                    }

                    // TODO: Check if position depends on the device's pixel ratio. (In a previous commit this was divided by two for some reason.)
                    viewAnnotation.frame = CGRect(
                        origin: CGPoint(
                            x: position.leftTopCoordinate.point.x,
                            y: position.leftTopCoordinate.point.y),
                        size: viewAnnotation.frame.size)

                    viewAnnotation.isHidden = false

                    visibleAnnotationIds.insert(position.identifier)
                }

                // Hide annotations that are off screen
                for id in Set(self.viewAnnotationsById.keys) {
                    guard let viewAnnotation = self.viewAnnotationsById[id] else {
                        fatalError()
                    }

                    if !visibleAnnotationIds.contains(id) {
                        viewAnnotation.isHidden = true
                    }

                }
            }
        }
    }
}

public protocol ViewAnnotation: UIView {
    var id: String { get }
    var options: ViewAnnotationOptions { get }
}
