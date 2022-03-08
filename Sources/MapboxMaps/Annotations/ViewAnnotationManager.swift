import UIKit
@_implementationOnly import MapboxCommon_Private
@_implementationOnly import MapboxCoreMaps_Private

public enum ViewAnnotationManagerError: Error {
    case viewIsAlreadyAdded
    case associatedFeatureIdIsAlreadyInUse
    case annotationNotFound
    case geometryFieldMissing
}

/// An interface you use to detect when the map view lays out or updates visibility of annotation views.
///
/// When visible portion of a map changes, e.g. responding to the user interaction, the map view adjusts the positions and visibility of its annotation views.
/// Implement methods of ``ViewAnnotationUpdateObserver`` to detect when the map view updates position/size for supplied annotation views.
/// As well as when annotation views get show/hidden when going in/out of visible portion of the map.
///
/// To register an observer for view annotation updates, call the ``ViewAnnotationManager/addViewAnnotationUpdateObserver(_:)`` method.
public protocol ViewAnnotationUpdateObserver: AnyObject {

    /// Tells the observer that the frames of the annotation views changed.
    ///
    /// - Parameters:
    ///   - annotationViews: The annotation views whose frames changed.
    ///
    func framesDidChange(for annotationViews: [UIView])

    /// Tells the observer that the visibility of the annotation views changed.
    ///
    /// Use `isHidden` property to determine whether a view is visible or not.
    /// - Parameters:
    ///   - annotationsViews: The annotation vies whose visibility changed.
    func visibilityDidChange(for annotationViews: [UIView])
}

/// Manager API to control View Annotations.
///
/// View annotations are `UIView` instances that are drawn on top of the ``MapView`` and bound to some `Geometry` (only `Point` is supported for now).
/// In case some view annotations intersect on the screen Z-index is based on addition order.
///
/// View annotations are invariant to map camera transformations however such properties as size, visibility etc
/// could be controlled by the user using update operation.
///
/// View annotations are not explicitly bound to any sources however ``ViewAnnotationOptions/associatedFeatureId`` could be
/// used to bind given view annotation with some `Feature` by `Feature.identifier` meaning visibility of view annotation will be driven
/// by visibility of given feature.
public final class ViewAnnotationManager {

    private let containerView: UIView
    private let mapboxMap: MapboxMapProtocol
    private var currentViewId = 0
    private var viewsById: [String: UIView] = [:]
    private var idsByView: [UIView: String] = [:]
    private var expectedHiddenByView: [UIView: Bool] = [:]
    private var viewsByFeatureIds: [String: UIView] = [:]

    private var observers = [ObjectIdentifier: ViewAnnotationUpdateObserver]()

    /// If the superview or the `UIView.isHidden` property of a custom view annotation is changed manually by the users
    /// the SDK prints a warning and reverts the changes, as the view is still considered for layout calculation.
    /// The default value is true, and setting this value to false will disable the validation.
    public var validatesViews = true

    internal init(containerView: UIView, mapboxMap: MapboxMapProtocol) {
        self.containerView = containerView
        self.mapboxMap = mapboxMap
        let delegatingPositionsListener = DelegatingViewAnnotationPositionsUpdateListener()
        delegatingPositionsListener.delegate = self
        mapboxMap.setViewAnnotationPositionsUpdateListener(delegatingPositionsListener)
    }

    deinit {
        mapboxMap.setViewAnnotationPositionsUpdateListener(nil)
    }

    // MARK: - Public APIs

    /// Add a `UIView` instance which will be displayed as an annotation.
    /// View dimensions will be taken as width / height from the bounds of the view
    /// unless they are not specified explicitly with ``ViewAnnotationOptions/width`` and ``ViewAnnotationOptions/height``.
    ///
    /// Annotation `options` must include Geometry where we want to bind our view annotation.
    ///
    /// Width and height could be specified explicitly but better idea will be not specifying them
    /// as they will be calculated automatically based on view layout.
    ///
    /// > Important: The annotation view to be added should have `UIView.transform` property set to `.identity`.
    /// Providing a transformed view can result in annotation views being misplaced, overlapped and other layout artifacts.
    ///
    /// - Note: Use ``ViewAnnotationManager/update(_:options:)`` for changing the visibilty of the view, instead
    /// of `UIView.isHidden` so that it is removed from the layout calculation.
    ///
    /// - Parameters:
    ///   - view: `UIView` to be added to the map
    ///   - options: ``ViewAnnotationOptions`` to control the layout and visibility of the annotation
    ///
    /// - Throws:
    ///   -  ``ViewAnnotationManagerError/viewIsAlreadyAdded`` if the supplied view is already added as an annotation
    ///   -  ``ViewAnnotationManagerError/geometryFieldMissing`` if options did not include geometry
    ///   -  ``ViewAnnotationManagerError/associatedFeatureIdIsAlreadyInUse`` if the
    ///   supplied ``ViewAnnotationOptions/associatedFeatureId`` is already used by another annotation view
    ///   - ``MapError``: errors during insertion
    public func add(_ view: UIView, options: ViewAnnotationOptions) throws {
        guard idsByView[view] == nil else {
            throw ViewAnnotationManagerError.viewIsAlreadyAdded
        }
        guard options.geometry != nil else {
            throw ViewAnnotationManagerError.geometryFieldMissing
        }
        if let associatedFeatureId = options.associatedFeatureId, viewsByFeatureIds[associatedFeatureId] != nil {
            throw ViewAnnotationManagerError.associatedFeatureIdIsAlreadyInUse
        }
        var creationOptions = options
        if creationOptions.width == nil {
            creationOptions.width = view.bounds.size.width
        }
        if creationOptions.height == nil {
            creationOptions.height = view.bounds.size.height
        }

        let id = String(currentViewId)
        currentViewId += 1

        view.translatesAutoresizingMaskIntoConstraints = false

        try mapboxMap.addViewAnnotation(withId: id, options: creationOptions)
        viewsById[id] = view
        idsByView[view] = id
        expectedHiddenByView[view] = !(creationOptions.visible ?? true)
        if let featureId = creationOptions.associatedFeatureId {
            viewsByFeatureIds[featureId] = view
        }
        containerView.addSubview(view)
    }

    /// Remove given `UIView` from the map if it was present.
    ///
    /// - Parameters:
    ///   - view: `UIView` to be removed
    public func remove(_ view: UIView) {
        guard let id = idsByView[view], let annotatonView = viewsById[id] else {
            return
        }
        let options = try? mapboxMap.options(forViewAnnotationWithId: id)
        try? mapboxMap.removeViewAnnotation(withId: id)
        annotatonView.removeFromSuperview()
        viewsById.removeValue(forKey: id)
        idsByView.removeValue(forKey: annotatonView)
        expectedHiddenByView.removeValue(forKey: annotatonView)
        if let featureId = options?.associatedFeatureId {
            viewsByFeatureIds.removeValue(forKey: featureId)
        }
    }

    /// Removes all annotations views from the map.
    public func removeAll() {
        for (id, view) in viewsById {
            try? mapboxMap.removeViewAnnotation(withId: id)
            view.removeFromSuperview()
        }

        expectedHiddenByView.removeAll()
        idsByView.removeAll()
        viewsById.removeAll()
        viewsByFeatureIds.removeAll()
    }

    /// Update given `UIView` with ``ViewAnnotationOptions``.
    /// Important thing to keep in mind that only properties present in `options` will be updated,
    /// all other will remain the same as specified before.
    ///
    /// - Parameters:
    ///   - view: `UIView` to be updated
    ///   - options: view annotation options with optional fields used for the update
    ///
    /// > Important: The annotation view to be updated should have `UIView.frame` property set to `identify`.
    /// Providing a transformed view can result in annotation views being misplaced, overlapped and other layout artifacts.
    ///
    /// - Throws:
    ///   - ``ViewAnnotationManagerError/annotationNotFound``: the supplied view was not found
    ///   -  ``ViewAnnotationManagerError/associatedFeatureIdIsAlreadyInUse`` if the
    ///   supplied ``ViewAnnotationOptions/associatedFeatureId`` is already used by another annotation view
    ///   - ``MapError``: errors during the update of the view (eg. incorrect parameters)
    public func update(_ view: UIView, options: ViewAnnotationOptions) throws {
        guard let id = idsByView[view] else {
            throw ViewAnnotationManagerError.annotationNotFound
        }
        if let associatedFeatureId = options.associatedFeatureId, viewsByFeatureIds[associatedFeatureId] != nil {
            throw ViewAnnotationManagerError.associatedFeatureIdIsAlreadyInUse
        }
        let currentFeatureId = try? mapboxMap.options(forViewAnnotationWithId: id).associatedFeatureId
        try mapboxMap.updateViewAnnotation(withId: id, options: options)
        let isHidden = !(options.visible ?? true)
        expectedHiddenByView[view] = isHidden
        viewsById[id]?.isHidden = isHidden
        if let id = currentFeatureId, id != options.associatedFeatureId {
            viewsByFeatureIds[id] = nil
        }
        if let featureId = options.associatedFeatureId {
            viewsByFeatureIds[featureId] = view
        }
    }

    /// Find `UIView` by feature id if it was specified as part of ``ViewAnnotationOptions/associatedFeatureId``.
    ///
    /// - Parameters:
    ///   - identifier: the identifier of the feature which will be used for finding the associated `UIView`
    ///
    /// - Returns: `UIView` if view was found and `nil` otherwise.
    public func view(forFeatureId identifier: String) -> UIView? {
        return viewsByFeatureIds[identifier]
    }

    /// Find ``ViewAnnotationOptions`` of view annotation by feature id if it was specified as part of ``ViewAnnotationOptions/associatedFeatureId``.
    ///
    /// - Parameters:
    ///   - identifier: the identifier of the feature which will be used for finding the associated ``ViewAnnotationOptions``
    ///
    /// - Returns: ``ViewAnnotationOptions`` if view was found and `nil` otherwise.
    public func options(forFeatureId identifier: String) -> ViewAnnotationOptions? {
        return viewsByFeatureIds[identifier].flatMap { idsByView[$0] }.flatMap { try? mapboxMap.options(forViewAnnotationWithId: $0) }
    }

    /// Get current ``ViewAnnotationOptions`` for given `UIView`.
    ///
    /// - Parameters:
    ///   - view: an `UIView` for which the associated ``ViewAnnotationOptions`` is looked up
    ///
    /// - Returns: ``ViewAnnotationOptions`` if view was found and `nil` otherwise.
    public func options(for view: UIView) -> ViewAnnotationOptions? {
        return idsByView[view].flatMap { try? mapboxMap.options(forViewAnnotationWithId: $0) }
    }

    /// Add an observer for annotation views updates
    ///
    /// Observers are held strongly.
    ///
    /// - Parameter observer: The object to notify when updates occur.
    public func addViewAnnotationUpdateObserver(_ observer: ViewAnnotationUpdateObserver) {
        observers[ObjectIdentifier(observer)] = observer
    }

    /// Remove an observer for annotation views updates.
    ///
    /// - Parameter observer: The object to stop sending notifications to.
    public func removeViewAnnotationUpdateObserver(_ observer: ViewAnnotationUpdateObserver) {
        observers.removeValue(forKey: ObjectIdentifier(observer))
    }

    // MARK: - Private functions

    private func placeAnnotations(positions: [ViewAnnotationPositionDescriptor]) {
        // Iterate through and update all view annotations
        // First update the position of the views based on the placement info from GL-Native
        // Then hide the views which are off screen
        var visibleAnnotationIds: Set<String> = []
        var viewsWithUpdatedFrame: Set<UIView> = []
        var viewsWithUpdatedVisibility: Set<UIView> = []

        for position in positions {
            guard let view = viewsById[position.identifier] else {
                continue
            }
            validate(view)

            view.translatesAutoresizingMaskIntoConstraints = true
            if view.frame != position.frame {
                view.frame = position.frame
                viewsWithUpdatedFrame.insert(view)
            }
            if view.isHidden {
                viewsWithUpdatedVisibility.insert(view)
            }
            view.isHidden = false
            expectedHiddenByView[view] = false
            visibleAnnotationIds.insert(position.identifier)
        }

        defer {
            assert(viewsWithUpdatedFrame.allSatisfy { !$0.isHidden })
            notifyViewAnnotationObserversFrameDidChange(for: Array(viewsWithUpdatedFrame))
        }

        let annotationsToHide = Set<String>(viewsById.keys).subtracting(visibleAnnotationIds)

        for id in annotationsToHide {
            guard let view = viewsById[id] else { fatalError() }
            validate(view)
            if !view.isHidden {
                viewsWithUpdatedVisibility.insert(view)
            }
            view.isHidden = true
            expectedHiddenByView[view] = true
        }

        notifyViewAnnotationObserversVisibilityDidChange(for: Array(viewsWithUpdatedVisibility))
    }

    private func validate(_ view: UIView) {
        guard validatesViews else { return }
        // Re-add the view if the superview of the annotation view is different than the container
        if view.superview != containerView {
            Log.warning(forMessage: "Superview changed for annotation view. Use `ViewAnnotationManager.remove(_ view: UIView)` instead to remove it from the layout calculation.", category: "Annotations")
            view.removeFromSuperview()
            containerView.addSubview(view)
        }
        // View is still considered for layout calculation, users should not modify the visibility of view directly
        if let expectedHidden = expectedHiddenByView[view], view.isHidden != expectedHidden {
            Log.warning(forMessage: "Visibility changed for annotation view. Use `ViewAnnotationManager.update(view: UIView, options: ViewAnnotationOptions)` instead to update visibility and remove the view from layout calculation.", category: "Annotations")
            view.isHidden = expectedHidden
        }
    }

    private func notifyViewAnnotationObserversFrameDidChange(for annotationViews: [UIView]) {
        guard !annotationViews.isEmpty else { return }

        observers.values.forEach { observer in
            observer.framesDidChange(for: annotationViews)
        }
    }

    private func notifyViewAnnotationObserversVisibilityDidChange(for annotationViews: [UIView]) {
        guard !annotationViews.isEmpty else { return }

        observers.values.forEach { observer in
            observer.visibilityDidChange(for: annotationViews)
        }
    }
}

extension ViewAnnotationManager: DelegatingViewAnnotationPositionsUpdateListenerDelegate {

    internal func onViewAnnotationPositionsUpdate(forPositions positions: [ViewAnnotationPositionDescriptor]) {
        placeAnnotations(positions: positions)
    }

}

private extension ViewAnnotationPositionDescriptor {
    var frame: CGRect {
        CGRect(origin: leftTopCoordinate.point, size: CGSize(width: CGFloat(width), height: CGFloat(height)))
    }
}
