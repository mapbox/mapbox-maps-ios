import UIKit
@_implementationOnly import MapboxCommon_Private
@_implementationOnly import MapboxCoreMaps_Private

public enum ViewAnnotationManagerError: Error {
    case annotationNotFound
    case insertionFailure(reason: String)
    case updateFailure(reason: String)
    case removalFailure(reason: String)
    case optionsQueryFailure(reason: String)
}

/// Manager API to control View Annotations.
///
/// View annotations are `UIView` instances that are drawn on top of the `MapView` and bound to some `Geometry` (only `Point` is supported for now).
/// In case some view annotations intersect on the screen Z-index is based on addition order.
///
/// View annotations are invariant to map camera transformations however such properties as size, visibility etc
/// could be controlled by the user using update operation.
///
/// View annotations are not explicitly bound to any sources however `ViewAnnotationOptions.associatedFeatureId` could be
/// used to bind given view annotation with some `Feature` by `Feature.identifier` meaning visibility of view annotation will be driven
/// by visibility of given feature.
public final class ViewAnnotationManager {

    private let containerView: SubviewInteractionOnlyView
    private let mapboxMap: MapboxMapProtocol
    private var annotationViewsById: [String: AnnotationView] = [:]
    private var annotationIdByViews: [AnnotationView: String] = [:]

    internal init(containerView: SubviewInteractionOnlyView, mapboxMap: MapboxMapProtocol) {
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

    /// Add annotation to the map which wraps a supplied `UIView`
    /// View dimensions will be taken as width / height from the bounds of the view
    /// unless they are not specified explicitly with `ViewAnnotationOptions.width` and `ViewAnnotationOptions.height`.
    ///
    /// Annotation `options` must include Geometry where we want to bind our view annotation.
    ///
    /// Width and height could be specified explicitly but better idea will be not specifying them
    /// as they will be calculated automatically based on view layout.
    ///
    /// - Parameters:
    ///   - view: `UIView` to be wrapped in an `AnnotationView` and placed on the map
    ///   - options: view annotation options
    ///
    /// - Throws: `ViewAnnotationManagerError.insertionFailure` if options did not include geometry or contains incomplatible values.
    public func addAnnotationView(withContent view: UIView, options: ViewAnnotationOptions) throws -> AnnotationView {
        guard options.geometry != nil else {
            throw ViewAnnotationManagerError.insertionFailure(reason: "Geometry field is missing")
        }
        var creationOptions = options
        if creationOptions.width == nil {
            creationOptions.width = view.bounds.size.width
        }
        if creationOptions.height == nil {
            creationOptions.height = view.bounds.size.height
        }
        let annotatonView = AnnotationView(view: view, annotationManager: self)
        try mapboxMap.addViewAnnotation(withId: annotatonView.id, options: options)
        annotationViewsById[annotatonView.id] = annotatonView
        annotationIdByViews[annotatonView] = annotatonView.id
        containerView.addSubview(annotatonView)
        return annotatonView
    }

    /// Remove given `AnnotationView` from the map if it was present.
    ///
    /// - Throws:
    ///   - `ViewAnnotationManagerError.annotationNotFound`: the supplioed view was not found
    ///   - `ViewAnnotationManagerError.removalFailure`: errors during the removal of the view
    public func remove(_ annotatonView: AnnotationView) throws {
        guard let id = annotationIdByViews[annotatonView], let annotatonView = annotationViewsById[id] else {
            throw ViewAnnotationManagerError.annotationNotFound
        }
        try mapboxMap.removeViewAnnotation(withId: id)
        annotatonView.removeFromSuperview()
        annotationViewsById.removeValue(forKey: id)
        annotationIdByViews.removeValue(forKey: annotatonView)
    }

    /// Update given `AnnotationView` with `ViewAnnotationOptions`.
    /// Important thing to keep in mind that only properties present in `options` will be updated,
    /// all other will remain the same as specified before.
    ///
    /// - Throws:
    ///   - `ViewAnnotationManagerError.annotationNotFound`: the supplioed view was not found
    ///   - `ViewAnnotationManagerError.updateFailure`: errors during the up date of the view (eg. incorrect parameters)
    public func update(_ annotatonView: AnnotationView, options: ViewAnnotationOptions) throws {
        guard let id = annotationIdByViews[annotatonView] else {
            throw ViewAnnotationManagerError.annotationNotFound
        }
        try mapboxMap.updateViewAnnotation(withId: id, options: options)
    }

    /// Find `AnnotationView` by feature id if it was specified as part of `ViewAnnotationOptions.associatedFeatureId`.
    ///
    /// - Returns: `AnnotationView` if view was found and `nil` otherwise.
    public func viewAnnotation(byFeatureId identifier: String) -> AnnotationView? {
        guard let id = annotationViewsById.keys.first(where: { id in
            (try? mapboxMap.options(forViewAnnotationWithId: id).associatedFeatureId == identifier) ?? false
        }) else {
            return nil
        }
        return annotationViewsById[id]
    }

    /// Find `ViewAnnotationOptions` of view annotation by feature id if it was specified as part of `ViewAnnotationOptions.associatedFeatureId`.
    ///
    /// - Returns: `ViewAnnotationOptions` if view was found and `nil` otherwise.
    public func options(byFeatureId identifier: String) -> ViewAnnotationOptions? {
        return viewAnnotation(byFeatureId: identifier).flatMap { options(byAnnotationView: $0) }
    }

    /// Get current `ViewAnnotationOptions` for given `AnnotationView`.
    ///
    /// - Returns: `ViewAnnotationOptions` if view was found and `nil` otherwise.
    public func options(byAnnotationView view: AnnotationView) -> ViewAnnotationOptions? {
        return annotationIdByViews[view].flatMap { try? mapboxMap.options(forViewAnnotationWithId: $0) }
    }

    // MARK: - Internal functions

    internal func placeAnnotations(positions: [ViewAnnotationPositionDescriptor]) {
        // Iterate through and update all view annotations
        // First update the position of the views based on the placement info from GL-Native
        // Then hide the views which are off screen
        var visibleAnnotationIds: Set<String> = []

        for position in positions {
            validateAnnotation(byAnnotationId: position.identifier)
            guard let annotationView = annotationViewsById[position.identifier] else {
                continue
            }
            annotationView.translatesAutoresizingMaskIntoConstraints = true
            annotationView.frame = CGRect(
                origin: position.leftTopCoordinate.point,
                size: CGSize(width: CGFloat(position.width), height: CGFloat(position.height))
            )
            annotationView.setInternalVisibility(isHidden: false)
            visibleAnnotationIds.insert(position.identifier)
        }

        let annotationsToHide = Set<String>(annotationViewsById.keys).subtracting(visibleAnnotationIds)
        for id in annotationsToHide {
            validateAnnotation(byAnnotationId: id)
            if let annotationView = annotationViewsById[id] {
                annotationView.setInternalVisibility(isHidden: true)
            }
        }
    }

    internal func validateAnnotation(byAnnotationId id: String) {
        guard let annotationView = annotationViewsById[id] else { return }
        // If the user explicitly removed the ViewAnnotation or it's wrapped view
        // we need to remove it from our layout calculation
        if annotationView.subviews.isEmpty || annotationView.superview == nil {
            try? remove(annotationView)
        }
        // View is still considered for layout calculation, users should not modify the visibility of the wrapped view
        if let wrappedView = annotationView.subviews.first, wrappedView.isHidden {
            Log.warning(forMessage: "Visibility changed for wrapped view", category: "Annotations")
        }
    }

}

extension ViewAnnotationManager: DelegatingViewAnnotationPositionsUpdateListenerDelegate {

    internal func onViewAnnotationPositionsUpdate(forPositions positions: [ViewAnnotationPositionDescriptor]) {
        placeAnnotations(positions: positions)
    }

}

public final class AnnotationView: SubviewInteractionOnlyView {

    private static var currentId = 0
    internal let id: String = {
        let id = String(currentId)
        currentId += 1
        return id
    }()
    internal let wrappedView: UIView
    internal var ignoreUserEvents: Bool = false

    // In case the user changes the visibility of the AnnotationView, we should update the options to remove it from the layout calculation
    public override var isHidden: Bool {
        didSet {
            guard !ignoreUserEvents else { return }
            guard let manager = annotationManager else { return }
            let options = manager.options(byAnnotationView: self)
            let visible = !isHidden
            if visible != options?.visible {
                try? manager.update(self, options: ViewAnnotationOptions(visible: visible))
            }
        }
    }
    private weak var annotationManager: ViewAnnotationManager?

    internal init(view: UIView, annotationManager: ViewAnnotationManager) {
        wrappedView = view
        self.annotationManager = annotationManager
        super.init(frame: .zero)

        // Disable constraints until the first size information is received
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(wrappedView)
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wrappedView.topAnchor.constraint(equalTo: topAnchor),
            wrappedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            wrappedView.leftAnchor.constraint(equalTo: leftAnchor),
            wrappedView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }

    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func setInternalVisibility(isHidden: Bool) {
        ignoreUserEvents = true
        self.isHidden = isHidden
        ignoreUserEvents = false
    }

}
