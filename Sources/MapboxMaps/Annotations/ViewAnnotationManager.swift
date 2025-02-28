// swiftlint:disable file_length
import UIKit
@_implementationOnly import MapboxCommon_Private
import Turf

public struct ViewAnnotationManagerError: Error, Equatable, Sendable {
    public let message: String

    /// This view has alread been added
    public static let viewIsAlreadyAdded = ViewAnnotationManagerError(message: "View is already added")

    /// The specified annotation was not found
    public static let annotationNotFound = ViewAnnotationManagerError(message: "Annotation not found")

    /// The annotated feature is missing
    public static let annotatedFeatureMissing = ViewAnnotationManagerError(message: "Annotated feature missing")
}

/// An interface you use to detect when the map view lays out or updates visibility of annotation views.
///
/// When visible portion of a map changes, e.g. responding to the user interaction, the map view adjusts the positions and visibility of its annotation views.
/// Implement methods of ``ViewAnnotationUpdateObserver`` to detect when the map view updates position/size for supplied annotation views.
/// As well as when annotation views get show/hidden when going in/out of visible portion of the map.
///
/// To register an observer for view annotation updates, call the ``ViewAnnotationManager/addViewAnnotationUpdateObserver(_:)`` method.
///
/// - Important: This protocol is deprecated and will be removed in future releases. Use ``ViewAnnotation`` instead.
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
    ///   - annotationViews: The annotation vies whose visibility changed.
    func visibilityDidChange(for annotationViews: [UIView])
}

/// Manager API to control View Annotations.
///
/// View annotations are `UIView` instances that are drawn on top of the ``MapView`` and bound to an arbitrary `Geometry` such as `Point`, or a `Feature` rendered on a layer.
/// In case some view annotations intersect on the screen Z-index is based on addition order.
///
/// View annotations are invariant to map camera transformations however such properties as size, visibility etc
/// could be controlled by the user using update operation.
public final class ViewAnnotationManager {
    private let containerView: UIView
    private let mapboxMap: MapboxMapProtocol
    private var displayLink: Signal<Void>
    private(set) var displaysAnnotations = CurrentValueSignalSubject<Bool>(false)

    private var objectAnnotations = [String: ViewAnnotation]() {
        didSet { updateDisplaysAnnotations() }
    }

    // deprecated properties
    private var viewsById: [String: UIView] = [:]
    private var idsByView: [UIView: String] = [:] {
        didSet { updateDisplaysAnnotations() }
    }
    private var expectedHiddenByView: [UIView: Bool] = [:]
    private var observers = [ObjectIdentifier: ViewAnnotationUpdateObserver]()

    /// If the superview or the `UIView.isHidden` property of a custom view annotation is changed manually by the users
    /// the SDK prints a warning and reverts the changes, as the view is still considered for layout calculation.
    /// The default value is true, and setting this value to false will disable the validation.
    @available(*, deprecated)
    public var validatesViews: Bool {
        get { _validatesViews }
        set { _validatesViews = newValue }
    }
    private var _validatesViews = true

    /// The list of view annotations added to the manager.
    public var allAnnotations: [ViewAnnotation] {
        Array(objectAnnotations.values)
    }

    /// Specify layers that view annotations should avoid. This applies to ALL view annotations associated to any layer.
    /// The API currently only supports line layers.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public var viewAnnotationAvoidLayers: Set<String> {
        get { mapboxMap.viewAnnotationAvoidLayers }
        set { mapboxMap.viewAnnotationAvoidLayers = newValue }
    }

    /// The complete list of annotations associated with the receiver.
    @available(*, deprecated, renamed: "allAnnotations", message: "Please use allAnnotations instead, or directly access ViewAnnotation itself")
    public var annotations: [UIView: ViewAnnotationOptions] {
        let values = idsByView.compactMapValues { [mapboxMap] id in
            try? mapboxMap.options(forViewAnnotationWithId: id)
        }
        return values
    }

    internal init(containerView: UIView, mapboxMap: MapboxMapProtocol, displayLink: Signal<Void>) {
        self.containerView = containerView
        self.mapboxMap = mapboxMap
        self.displayLink = displayLink
        mapboxMap.setViewAnnotationPositionsUpdateCallback { [weak self] positions in
            self?.placeAnnotations(positions: positions)
        }
    }

    deinit {
        mapboxMap.setViewAnnotationPositionsUpdateCallback(nil)
    }

    // MARK: - Public APIs

    /// Add a ``ViewAnnotation`` to the map.
    ///
    /// To remove the annotation use ``ViewAnnotation/remove()`` method.
    public func add(_ annotation: ViewAnnotation) {
        guard objectAnnotations[annotation.id] == nil else {
            return
        }
        objectAnnotations[annotation.id] = annotation

        let deps = ViewAnnotation.Deps(
            superview: containerView,
            mapboxMap: mapboxMap,
            displayLink: displayLink,
            onRemove: { [weak self, id = annotation.id] in
                guard let self else { return }
                objectAnnotations.removeValue(forKey: id)
            })

        annotation.bind(deps)
    }

    /// Add a `UIView` instance which will be displayed as an annotation.
    /// View dimensions will be taken as width / height from the bounds of the view
    /// unless they are not specified explicitly with ``ViewAnnotationOptions-swift.struct/width`` and ``ViewAnnotationOptions-swift.struct/height``.
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
    ///   - options: ``ViewAnnotationOptions-swift.struct`` to control the layout and visibility of the annotation
    ///
    /// - Throws:
    ///   -  ``ViewAnnotationManagerError/viewIsAlreadyAdded`` if the supplied view is already added as an annotation
    ///   -  ``ViewAnnotationManagerError/annotatedFeatureMissing`` if options did not include annotated feature
    ///   - ``MapError``: errors during insertion
    @available(*, deprecated, message: "Use add(_:) that takes ViewAnnotation")
    public func add(_ view: UIView, options: ViewAnnotationOptions) throws {
        try add(view, id: nil, options: options)
    }

    /// Add a `UIView` instance which will be displayed as an annotation.
    /// View dimensions will be taken as width / height from the bounds of the view
    /// unless they are not specified explicitly with ``ViewAnnotationOptions-swift.struct/width`` and ``ViewAnnotationOptions-swift.struct/height``.
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
    ///   - id: The unique string for the `view`.
    ///   - options: ``ViewAnnotationOptions-swift.struct`` to control the layout and visibility of the annotation
    ///
    /// - Throws:
    ///   -  ``ViewAnnotationManagerError/viewIsAlreadyAdded`` if the supplied view is already added as an annotation, or there is an existing annotation view with the same `id`.
    ///   -  ``ViewAnnotationManagerError/annotatedFeatureMissing`` if options did not include geometry
    ///   - ``MapError``: errors during insertion
    @available(*, deprecated, message: "Use add(_:) that takes ViewAnnotation")
    public func add(_ view: UIView, id: String?, options: ViewAnnotationOptions) throws {
        guard idsByView[view] == nil && id.flatMap(view(forId:)) == nil else {
            throw ViewAnnotationManagerError.viewIsAlreadyAdded
        }
        guard options.annotatedFeature != nil else {
            throw ViewAnnotationManagerError.annotatedFeatureMissing
        }

        var creationOptions = options
        if creationOptions.width == nil {
            creationOptions.width = view.bounds.size.width
        }
        if creationOptions.height == nil {
            creationOptions.height = view.bounds.size.height
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true

        let id = id ?? UUID().uuidString
        try mapboxMap.addViewAnnotation(withId: id, options: creationOptions)
        viewsById[id] = view
        idsByView[view] = id
        expectedHiddenByView[view] = true
        containerView.addSubview(view)
    }

    /// Remove given `UIView` from the map if it was present.
    ///
    /// - Parameters:
    ///   - view: `UIView` to be removed
    @available(*, deprecated, message: "Use ViewAnnotation.remove()")
    public func remove(_ view: UIView) {
        guard let id = idsByView[view], let annotatonView = viewsById[id] else {
            return
        }
        try? mapboxMap.removeViewAnnotation(withId: id)
        annotatonView.removeFromSuperview()
        viewsById.removeValue(forKey: id)
        idsByView.removeValue(forKey: annotatonView)
        expectedHiddenByView.removeValue(forKey: annotatonView)
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

        for annotation in objectAnnotations.values {
            annotation.remove()
        }
        assert(objectAnnotations.isEmpty)
    }

    /// Update given `UIView` with ``ViewAnnotationOptions-swift.struct``.
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
    ///   - ``MapError``: errors during the update of the view (eg. incorrect parameters)
    @available(*, deprecated, message: "Use ViewAnnotation properties")
    public func update(_ view: UIView, options: ViewAnnotationOptions) throws {
        guard let id = idsByView[view] else {
            throw ViewAnnotationManagerError.annotationNotFound
        }
        try mapboxMap.updateViewAnnotation(withId: id, options: options)

        if options.visible == false {
            expectedHiddenByView[view] = true
            view.isHidden = true
        }
    }

    /// Find view annotation by the given `id`.
    ///
    /// - Parameter id: The identifier of the view set in ``ViewAnnotationManager/add(_:id:options:)``.
    /// - Returns: `UIView` if view was found, otherwise `nil`.
    @available(*, deprecated, message: "Use ViewAnnotation.view")
    public func view(forId id: String) -> UIView? {
        viewsById[id]
    }

    /// :nodoc:
    @available(*, unavailable, message: "Store annotation references on calling site")
    public func view(forFeatureId identifier: String) -> UIView? { fatalError()
    }

    /// :nodoc:
    @available(*, unavailable, message: "Use options(for:) with UIView")
    public func options(forFeatureId identifier: String) -> ViewAnnotationOptions? {
        fatalError()
    }

    /// Get current ``ViewAnnotationOptions-swift.struct`` for given `UIView`.
    ///
    /// - Parameters:
    ///   - view: an `UIView` for which the associated ``ViewAnnotationOptions-swift.struct`` is looked up
    ///
    /// - Returns: ``ViewAnnotationOptions-swift.struct`` if view was found and `nil` otherwise.
    @available(*, deprecated, message: "Use ViewAnnotation properties")
    public func options(for view: UIView) -> ViewAnnotationOptions? {
        return idsByView[view].flatMap { try? mapboxMap.options(forViewAnnotationWithId: $0) }
    }

    /// Add an observer for annotation views updates
    ///
    /// Observers are held strongly.
    ///
    /// - Parameter observer: The object to notify when updates occur.
    @available(*, deprecated, message: "Use ViewAnnotation")
    public func addViewAnnotationUpdateObserver(_ observer: ViewAnnotationUpdateObserver) {
        observers[ObjectIdentifier(observer)] = observer
    }

    /// Remove an observer for annotation views updates.
    ///
    /// - Parameter observer: The object to stop sending notifications to.
    @available(*, deprecated, message: "Use ViewAnnotation")
    public func removeViewAnnotationUpdateObserver(_ observer: ViewAnnotationUpdateObserver) {
        observers.removeValue(forKey: ObjectIdentifier(observer))
    }

    // MARK: Framing

    /// Calculates ``CameraOptions-swift.struct`` to fit the list of view annotations.
    ///
    /// - Important: This API isn't supported by Globe projection.
    /// - Important: This method works only for annotations bound to point geometry. All other annotation will be ignored.
    ///
    /// If an annotation has multiple ``ViewAnnotation/variableAnchors``, the last picked anchor configuration
    /// will we used for bounding box calculation. If annotation is not yet rendered, the first first confit from the list will be used.
    ///
    /// - Parameter annotations: The list of annotations ids to be framed.
    /// - Parameter padding: See ``CameraOptions-swift.struct/padding``.
    /// - Parameter bearing: See ``CameraOptions-swift.struct/bearing``.
    /// - Parameter pitch: See ``CameraOptions-swift.struct/pitch``.
    public func camera(
        forAnnotations annotations: [ViewAnnotation],
        padding: UIEdgeInsets = .zero,
        bearing: CGFloat? = nil,
        pitch: CGFloat? = nil
    ) -> CameraOptions? {
        let corners: [CoordinateBoundsCorner] = annotations.compactMap { annotation in
            guard
                let geometry = annotation.options.annotatedFeature?.geometry,
                case .point(let point) = geometry else {
                return nil
            }
            return CoordinateBoundsCorner(
                id: annotation.id,
                anchorPoint: point.coordinates,
                frame: annotation.options.frame(with: annotation.anchorConfig))
        }
        return correctedCamera(forCorners: corners, padding: padding, bearing: bearing, pitch: pitch)
    }

    /// Calculates ``CameraOptions-swift.struct`` to fit the list of view annotations.
    ///
    /// - Important: This API isn't supported by Globe projection.
    ///
    /// - Parameter identifiers: The list of annotations ids to be framed.
    /// - Parameter padding: See ``CameraOptions-swift.struct/padding``.
    /// - Parameter bearing: See ``CameraOptions-swift.struct/bearing``.
    /// - Parameter pitch: See ``CameraOptions-swift.struct/pitch``.
    @available(*, deprecated, message: "Use camera(forAnnotations:...) that works with array of ViewAnnotation")
    public func camera(
        forAnnotations identifiers: [String],
        padding: UIEdgeInsets = .zero,
        bearing: CGFloat? = nil,
        pitch: CGFloat? = nil
    ) -> CameraOptions? {

        let corners: [CoordinateBoundsCorner] = identifiers.compactMap {
            guard
                let options = try? mapboxMap.options(forViewAnnotationWithId: $0),
                case .point(let point) = options.annotatedFeature?.geometry else {
                return nil
            }
            return CoordinateBoundsCorner(id: $0, anchorPoint: point.coordinates, frame: options.frame(with: nil))
        }
        return correctedCamera(forCorners: corners, padding: padding, bearing: bearing, pitch: pitch)
    }

    // MARK: - Private functions

    private func placeAnnotations(positions: [ViewAnnotationPositionDescriptor]) {
        // Iterate through and update all view annotations
        // First update the position of the views based on the placement info from GL-Native
        // Then hide the views which are off screen
        var visibleAnnotationIds: Set<String> = []
        var viewsWithUpdatedFrame: Set<UIView> = []
        var viewsWithUpdatedVisibility: Set<UIView> = []

        var hiddenObjectAnnotations = objectAnnotations
        for position in positions {
            if let annotation = objectAnnotations[position.identifier] {
                annotation.place(with: position)
                hiddenObjectAnnotations.removeValue(forKey: position.identifier)
                containerView.bringSubviewToFront(annotation.view)
                continue
            }

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
            containerView.bringSubviewToFront(view)
        }

        // hide the annotation managed by descriptors.
        for annotation in hiddenObjectAnnotations.values {
            annotation.isHidden = true
        }

        defer {
            assert(viewsWithUpdatedFrame.allSatisfy { !$0.isHidden })
            notifyViewAnnotationObserversFrameDidChange(for: Array(viewsWithUpdatedFrame))
        }

        let annotationsToHide = Set<String>(viewsById.keys).subtracting(visibleAnnotationIds)

        for id in annotationsToHide {
            guard let view = viewsById[id] else {
                assertionFailure("Couldn't find annotation view, id: \(id)")
                continue
            }
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
        guard _validatesViews else { return }
        validateAnnotationSuperview(view, expected: containerView)
        if let expectedHidden = expectedHiddenByView[view] {
            validateAnnotationHidden(view, expected: expectedHidden)
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

    private func updateDisplaysAnnotations() {
        displaysAnnotations.value = !idsByView.isEmpty || !objectAnnotations.isEmpty
    }
}

extension ViewAnnotationPositionDescriptor {
    var frame: CGRect {
        CGRect(origin: leftTopCoordinate.point, size: CGSize(width: CGFloat(width), height: CGFloat(height)))
    }
}

extension ViewAnnotationManager {
    private struct CoordinateBoundsCorner {
        let id: String
        let anchorPoint: LocationCoordinate2D
        let frame: CGRect
    }

    private func correctedCamera(
        forCorners corners: [CoordinateBoundsCorner],
        padding: UIEdgeInsets,
        bearing: CGFloat?,
        pitch: CGFloat?
    ) -> CameraOptions? {
        guard !corners.isEmpty else { return nil }

        // Calculate initial camera assuming annotations with edging coordinate being the bounds's corners.
        let initialCamera = camera(forCorners: corners, zoom: nil, padding: padding, bearing: bearing, pitch: pitch)
        return camera(forCorners: corners, zoom: initialCamera.zoom, padding: padding, bearing: bearing, pitch: pitch)
    }

    /// Calculates ``CameraOptions`` by corners with its bounds calculated with given `zoom`.
    /// - Returns: The camera with zoom adjusted, so that the cooridnate bounds for annotations
    /// at top, left, bottom , right at this adjusted zoom would fit into the projection (defined by padding, bearing and pitch).
    private func camera(
        forCorners corners: [CoordinateBoundsCorner],
        zoom: CGFloat?,
        padding: UIEdgeInsets,
        bearing: CGFloat?,
        pitch: CGFloat?
    ) -> CameraOptions {

        var north, east, south, west: CoordinateBoundsCorner!

        for corner in corners {
            let annotationBounds = coordinateBounds(for: corner, zoom: zoom)
            if north == nil || coordinateBounds(for: north, zoom: zoom).north < annotationBounds.north {
                north = corner
            }
            if east == nil || coordinateBounds(for: east, zoom: zoom).east < annotationBounds.east {
                east = corner
            }
            if south == nil || coordinateBounds(for: south, zoom: zoom).south > annotationBounds.south {
                south = corner
            }
            if west == nil || coordinateBounds(for: west, zoom: zoom).west > annotationBounds.west {
                west = corner
            }
        }

        let innerBounds = CoordinateBounds(
            southwest: .init(latitude: south.anchorPoint.latitude, longitude: west.anchorPoint.longitude),
            northeast: .init(latitude: north.anchorPoint.latitude, longitude: east.anchorPoint.longitude))

        var padding = padding
        padding.top += abs(north.frame.minY)
        padding.left += abs(west.frame.minX)
        // In case the view is completely above its anchor (maxY is negative), then bottom padding should be zero.
        padding.bottom += max(0, south.frame.maxY)
        // In case the view is completely on the left side of its anchor (max X is negative), then right padding should be zero.
        padding.right += max(0, east.frame.maxX)

        return mapboxMap.camera(
            for: innerBounds,
            padding: padding,
            bearing: bearing.map(Double.init),
            pitch: pitch.map(Double.init),
            maxZoom: nil,
            offset: nil)
    }

    /// Calculates the ``CoordinateBounds`` of an annotation at the given `zoom` level.
    ///
    /// - Parameter corner: The annotation to calculate coordinate bounds.
    /// - Parameter zoom: The zoom level to calculate coordinate bounds.
    /// - Returns: The ``CoordinateBounds`` of the `corner` at the given `zoom` if presented. else returns the ``CoordinateBounds``consisting of a single point at corner's anchor.
    private func coordinateBounds(for corner: CoordinateBoundsCorner, zoom: CGFloat?) -> CoordinateBounds {
        guard let zoom = zoom else { return CoordinateBounds.__singleton(forPoint: corner.anchorPoint) }

        let anchorPoint = corner.anchorPoint, frame = corner.frame
        // Calculates distance for anchor's coordinate in meters.
        let anchorProjectedMeters = Projection.projectedMeters(for: anchorPoint)
        let metersPerPoint = Projection.metersPerPoint(for: anchorPoint.latitude, zoom: zoom)

        // Shift anchor's projected meters by distance of frame's minY to anchor.
        // Because screen coordinate system is having y-axis in opposite direction of Sperical Mercator coordinate system,
        // thus we need to negate the value of frame's minY to get correct result for northing.
        let northing = anchorProjectedMeters.northing - frame.minY * metersPerPoint
        // Shift anchor's projected meters by distance of frame's minX to anchor.
        let easting = anchorProjectedMeters.easting + frame.maxX * metersPerPoint
        let southing = northing - frame.height * metersPerPoint
        let westing = easting - frame.width * metersPerPoint

        let northeast = Projection.coordinate(for: ProjectedMeters(northing: northing, easting: easting))
        let southwest = Projection.coordinate(for: ProjectedMeters(northing: southing, easting: westing))

        return CoordinateBounds(southwest: southwest, northeast: northeast, infiniteBounds: false)
    }
}

func validateAnnotationSuperview(_ view: UIView, expected: UIView?) {
    // Re-add the view if the superview of the annotation view is different than the container
    if view.superview != expected {
        Log.warning("Superview changed for annotation view. Use `ViewAnnotationManager.remove(_ view: UIView)` instead to remove it from the layout calculation.", category: "Annotations")
        view.removeFromSuperview()
        expected?.addSubview(view)
    }
}

func validateAnnotationHidden(_ view: UIView, expected: Bool) {
    // View is still considered for layout calculation, users should not modify the visibility of view directly
    if view.isHidden != expected {
        Log.warning("Visibility changed for annotation view. Use `ViewAnnotationManager.update(view: UIView, options: ViewAnnotationOptions)` instead to update visibility and remove the view from layout calculation.", category: "Annotations")
        view.isHidden = expected
    }
}
