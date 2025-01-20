import UIKit
import MapboxCoreMaps
import MapboxCommon

/// Creates a view annotation.
///
/// Use view annotations if you need to display interactive UIView bound to
/// a geographical coordinate or map feature.
///
/// The view annotations are great for displaying unique interactive features. However, they may be suboptimal for large amounts of data and don't support clustering. For those cases use ``PointAnnotation`` or Runtime Styling API, for example, ``SymbolLayer`` with ``GeoJSONSource``.
///
///- Note: View Annotations appear above all content of MapView (e.g. layers, annotations, puck). If you need to display annotation between layers or below puck, use ``PointAnnotation``.
///
/// To display a view annotation configure a UIView, create `ViewAnnotation`, and add it to the view annotation manager:
///
/// ```swift
/// let view = CustomView()
/// view.icon = UIImage(named: "traffic-icon")
/// let annotation = ViewAnnotation(
///   coordinate: CLLocationCoordinate(latitude: 10, longitude: 10),
///   view: view)
/// mapView.viewAnnotations.add(annotation)
/// ```
///
/// The annotation can be displayed on a layer feature referenced by it's `layerId` and `featureId`:
/// ```swift
/// annotation.annotatedFeature = .layerFeature(layerId: "route-line", featureId: "sf-la")
/// ```
///
/// The view annotation automatically inserts and removes it's view into the view hierarchy and updates its `isHidden` property.
///
/// - Important: Don't set `UIView.isHidden` property to hide the annotation. Instead, use ``visible`` property.
///
/// When view content or layout is updated, use ``setNeedsUpdateSize()`` to update the the annotation size. It's safe to use it multiple times, only one update will be performed.
///
/// ```swift
/// view.hintText = "Less Traffic"
/// annotation.setNeedsUpdateSize() // Updates the annotation size.
/// ```
///
/// - Note: The `ViewAnnotation` uses `UIView.systemLayoutSizeFitting(_:)` to measure the view size. Make sure that your view returns the correct size (e.g. implemented using AutoLayout, or returns correct size from `UIView.sizeThatFits(_:)` when layout is manual).
///
/// To remove annotation when it's no longer needed, use ``remove()`` method.
public final class ViewAnnotation {
    struct Deps {
        var superview: UIView
        var mapboxMap: MapboxMapProtocol
        var displayLink: Signal<Void>
        var onRemove: () -> Void
    }

    /// Annotation view.
    public let view: UIView

    /// Associates the view annotation with the feature geometry.
    ///
    /// The geometry may be any `Geometry` or a feature rendered on a specified layer.
    public var annotatedFeature: AnnotatedFeature {
        get { options.annotatedFeature! }
        set { setProperty(\.annotatedFeature, value: newValue, oldValue: annotatedFeature) }
    }

    /// If true, the annotation will be visible even if it collides with other previously drawn annotations.
    ///
    /// The property is `false` by default.
    public var allowOverlap: Bool {
        get { property(\.allowOverlap, default: false) }
        set { setProperty(\.allowOverlap, value: newValue, oldValue: allowOverlap) }
    }

    /// When `false`, the annotation won't be shown on top of Puck.
    ///
    /// Default value is `false`.
    public var allowOverlapWithPuck: Bool {
        get { property(\.allowOverlapWithPuck, default: false) }
        set { setProperty(\.allowOverlapWithPuck, value: newValue, oldValue: allowOverlapWithPuck) }
    }

    /// When true, position annotation on buildings' (both fill extrusions and models) rooftops.
    ///
    /// By default, the effective value is `false`. If annotation is associated with a symbol layer ``SymbolLayer`` and the
    ///  ``ViewAnnotation/allowZElevate`` is `nil`, the effective value will be taken from ``SymbolLayer/symbolZElevate``.
    ///
    /// See also: [`symbol-z-elevate`](https://docs.mapbox.com/style-spec/reference/layers/#layout-symbol-symbol-z-elevate).
    public var allowZElevate: Bool? {
        get { options.allowZElevate }
        set { setProperty(\.allowZElevate, value: newValue, oldValue: allowZElevate) }
    }

    /// When `false`, the annotation will be displayed even if it go beyond camera padding.
    ///
    /// The camera padding is set via ``MapboxMap/setCamera(to:)``.
    ///
    /// Default value is `false`.
    public var ignoreCameraPadding: Bool {
        get { property(\.ignoreCameraPadding, default: false) }
        set { setProperty(\.ignoreCameraPadding, value: newValue, oldValue: ignoreCameraPadding) }
    }

    /// Specifies if this view annotation is visible or not.
    ///
    /// The property is `true` by default.
    public var visible: Bool {
        get { property(\.visible, default: true) }
        set { setProperty(\.visible, value: newValue, oldValue: visible) }
    }

    /// Specifies if this view annotation is selected meaning it should be placed on top of others.
    ///
    /// The property is `false` by default.
    @available(*, deprecated, message: "Use priority instead.")
    public var selected: Bool {
        get { property(\.selected, default: false) }
        set { setProperty(\.selected, value: newValue, oldValue: selected) }
    }

    /// Sorts annotations in descending order based on this value.
    ///
    /// A replacement for the deprecated `selected` field.
    /// Simultaneous use of `priority` and `selected` fileds should be avoided.
    /// Annotations with higher priority keys are drawn and placed first.
    /// When equal priorities, less-anchor-options and least-recently-added sequentially used for annotations placement order.
    /// `priority` field defaults to 0 when not set explicitly.
    /// Negative, 0, positive values could be used in `priority` field.
    ///
    /// When updating existing annotations, if `priority` is not explicitly set, the current value will be retained.
    public var priority: Int? {
        get { options.priority }
        set { setProperty(\.priority, value: newValue, oldValue: priority)}
    }

    /// A list of anchor configurations available.
    ///
    /// The annotation will automatically pick the first best anchor position depending on position
    /// relative to other elements on the map.
    ///
    /// If not specified, the annotation will be placed in center.
    ///
    /// The ``onAnchorChanged`` is called when the effective position is updated:
    /// ```swift
    /// let view = CustomView()
    /// let annotation = ViewAnnotation(
    ///     annotatedFeature: .layerFeature(layerId: "route-line", featureId: "sf-la"),
    ///     view: view)
    ///
    /// // Allow top and bottom anchor directions.
    /// annotation.variableAnchors = [
    ///   ViewAnnotationAnchorConfig(anchor: .top),
    ///   ViewAnnotationAnchorConfig(anchor: .bottom)
    /// ]
    ///
    /// annotation.onAnchorChanged = { config in
    ///     // Update the view's anchor to the newly picked one.
    ///     view.anchor = config.anchor
    /// }
    /// ```
    public var variableAnchors: [ViewAnnotationAnchorConfig] {
        get { property(\.variableAnchors, default: .center) }
        set { setProperty(\.variableAnchors, value: newValue, oldValue: variableAnchors) }
    }

    /// Called when visibility of annotation is changed.
    ///
    /// The annotation becomes hidden when it goes out of MapView's bounds or ``visible`` property is changed.
    ///
    /// The callback takes `true` when annotation is visible.
    public var onVisibilityChanged: ((Bool) -> Void)?

    /// Called when ``anchorConfig`` is changed.
    ///
    /// See ``variableAnchors``.
    ///
    /// The callback takes the `anchorConfig` parameter which represents the selected anchor configuration.
    public var onAnchorChanged: ((ViewAnnotationAnchorConfig) -> Void)?

    /// Called when ``anchorCoordinate`` is changed.
    public var onAnchorCoordinateChanged: ((CLLocationCoordinate2D) -> Void)?

    /// Called when view frame is changed.
    ///
    /// The callback takes the `frame` parameter.
    public var onFrameChanged: ((CGRect) -> Void)?

    /// Currently selected anchor configuration.
    private(set) public var anchorConfig: ViewAnnotationAnchorConfig? {
        didSet {
            guard let anchorConfig, anchorConfig != oldValue else { return }
            onAnchorChanged?(anchorConfig)
        }
    }

    /// The actual geographical coordinate used for positioning this annotation.
    private(set) public var anchorCoordinate: CLLocationCoordinate2D? {
        didSet {
            guard let anchorCoordinate, anchorCoordinate != oldValue else { return }
            onAnchorCoordinateChanged?(anchorCoordinate)
        }
    }

    /// Minimum zoom value in range [0, 22] to display View Annotation.
    /// If not provided or is out of range, defaults to 0.
    public var minZoom: Double {
        get { property(\.minZoom, default: 0) }
        set { setProperty(\.minZoom, value: newValue, oldValue: minZoom) }
    }

    /// Maximum zoom value in range [0, 22] to display View Annotation.
    /// Should be greater than or equal to minZoom.
    /// If not provided or is out of range, defaults to 22.
    public var maxZoom: Double {
        get { property(\.maxZoom, default: 22) }
        set { setProperty(\.maxZoom, value: newValue, oldValue: maxZoom) }
    }

    let id = UUID().uuidString
    var isHidden = true {
        didSet {
            guard isHidden != oldValue else { return }
            view.isHidden = isHidden
            onVisibilityChanged?(!isHidden)
        }
    }

    /// Represents state that is relevant when annotation is added to the map.
    private struct State {
        var deps: Deps
        var displayLinkToken: AnyCancelable
        var needsUpdateSize = false
        /// Options that need to be set to core on next sync.
        var pendingOptions: ViewAnnotationOptions?
    }
    private var state: State?

    /// Actual, up to date options.
    private(set) var options = ViewAnnotationOptions()

    /// Creates an annotation.
    ///
    /// - Parameters:
    ///  - annotatedFeature: The feature the annotation will be bound to. It may be a `Geometry`,
    ///   such as `Point`, `LineString`, `Polygon`, or a feature rendered on a layer.
    ///  - view: View to use as annotation.
    public init(annotatedFeature: AnnotatedFeature, view: UIView) {
        self.view = view
        options.annotatedFeature = annotatedFeature
        view.isHidden = true
    }

    /// Creates an annotation at specified coordinate.
    ///
    /// - Parameters:
    ///  - coordinate: Geographical coordinate of the annotation.
    ///  - view: View to use as annotation.
    public convenience init(coordinate: CLLocationCoordinate2D, view: UIView) {
        self.init(annotatedFeature: .geometry(Point(coordinate)), view: view)
    }

    /// Creates a view annotation on feature rendered on a layer.
    ///
    /// - Parameters:
    ///   - layerId: Layer identifier which renders the feature.
    ///   - featureId: Feature identifier. If not specified, the annotation will appear on any feature from that layer.
    ///   - view: The view to place on the map.
    public convenience init(layerId: String, featureId: String? = nil, view: UIView) {
        self.init(
            annotatedFeature: .layerFeature(layerId: layerId, featureId: featureId),
            view: view)
    }

    /// Removes view annotation.
    ///
    /// This method removes the view from its superview.
    public func remove() {
        guard let state else { return }
        view.removeFromSuperview()
        state.deps.onRemove()
        wrapError("remove") {
            try state.deps.mapboxMap.removeViewAnnotation(withId: id)
        }

        self.state = nil
    }

    /// Invalidates the current size of view annotation.
    ///
    /// Call this method when the managed view layout is updated. The annotation will be repositioned according to the new size in the next rendering call.
    public func setNeedsUpdateSize() {
        state?.needsUpdateSize = true
    }

    func bind(_ deps: Deps) {
        guard state == nil else {
            assertionFailure("Annotation \(id) is already added")
            return
        }

        state = State(
            deps: deps,
            displayLinkToken: deps.displayLink.observe { [weak self] in self?.sync() },
            needsUpdateSize: false,
            pendingOptions: nil)

        deps.superview.addSubview(view)

        updateSizeOptions()
        state?.pendingOptions = nil // clean after size updating size

        wrapError("add") {
            try deps.mapboxMap.addViewAnnotation(withId: id, options: options)
        }
    }

    func place(with descriptor: ViewAnnotationPositionDescriptor) {
        assert(descriptor.identifier == id)

        validateAnnotationHidden(view, expected: isHidden)
        if let parentView = state?.deps.superview {
            validateAnnotationSuperview(view, expected: parentView)
        }

        view.translatesAutoresizingMaskIntoConstraints = true
        var notify = false

        if view.frame != descriptor.frame {
            view.frame = descriptor.frame
            notify = true
        }

        anchorCoordinate = descriptor.anchorCoordinate
        anchorConfig = descriptor.anchorConfig
        isHidden = false
        if notify {
            onFrameChanged?(descriptor.frame)
        }
    }

    func property<Value>(_ keyPath: WritableKeyPath<ViewAnnotationOptions, Value?>, `default`: @autoclosure () -> Value) -> Value {
        if options[keyPath: keyPath] == nil {
            options[keyPath: keyPath] = `default`()
        }
        return options[keyPath: keyPath]!
    }

    func setProperty<Value: Equatable>(_ keyPath: WritableKeyPath<ViewAnnotationOptions, Value?>, value: Value?, oldValue: Value?) {
        if value == oldValue {
            return
        }
        if state != nil {
            // VA added to map, collect pending options for next update
            if state?.pendingOptions == nil {
                state?.pendingOptions = ViewAnnotationOptions()
            }
            state?.pendingOptions?[keyPath: keyPath] = value
        }
        options[keyPath: keyPath] = value
    }

    private func sync() {
        guard state != nil else { return }
        defer {
            self.state?.pendingOptions = nil
            self.state?.needsUpdateSize = false
        }
        if state?.needsUpdateSize ?? false {
            // Update size options if size changed.
            updateSizeOptions()
        }

        if let pendingOptions = state?.pendingOptions {
            wrapError("update") {
                try state?.deps.mapboxMap.updateViewAnnotation(withId: id, options: pendingOptions)
            }
        }
    }

    private func updateSizeOptions() {
        let availableSize = state?.deps.superview.bounds.size ?? UIView.layoutFittingCompressedSize

        var size = view.systemLayoutSizeFitting(availableSize)
        // AutoLayout views may shrink labels without rounding size
        size.width.round(.up)
        size.height.round(.up)
        setProperty(\.width, value: size.width, oldValue: options.width)
        setProperty(\.height, value: size.height, oldValue: options.height)
    }

    private func wrapError(_ action: String, _ body: () throws -> Void) {
        do {
            try body()
        } catch {
            Log.error("Failed to \(action) annotation \(id): \(error)", category: "ViewAnnotation")
        }
    }

}
