import SwiftUI

/// Displays a view annotation.
///
/// Use view annotations if you need to display interactive UIView bound to
/// a geographical coordinate or map feature. The `MapViewAnnotation` is a SwiftUI analog to ``ViewAnnotation``.
///
/// ```swift
/// Map {
///     MapViewAnnotation(coordinate: CLLocationCoordinate2D(...)) {
///        Text("🚀")
///           .background(Circle().fill(.red))
///     }
///     .allowOverlap(false)
///     .variableAnchors([ViewAnnotationAnchorConfig(anchor: .bottom)])
/// }
/// ```
///
/// The view annotations are great for displaying unique interactive features. However, they may be suboptimal for large amounts of data and don't support clustering. For those cases use ``PointAnnotation`` or Runtime Styling API, for example, ``SymbolLayer`` with ``GeoJSONSource``.
///
/// - Note: View Annotations appear above all content of MapView (e.g. layers, annotations, puck). If you need to display annotation between layers or below puck, use ``PointAnnotation``.
@_documentation(visibility: public)
@_spi(Experimental)
@available(iOS 13.0, *)
public struct MapViewAnnotation {
    struct Actions {
        var visibility: ((Bool) -> Void)?
        var anchor: ((ViewAnnotationAnchorConfig) -> Void)?
        var anchorCoordinate: ((CLLocationCoordinate2D) -> Void)?
    }
    var annotatedFeature: AnnotatedFeature
    var allowOverlap: Bool = false
    var visible: Bool = true
    var allowHitTesting: Bool = true
    var selected: Bool = false
    var allowOverlapWithPuck: Bool = false
    var ignoreCameraPadding: Bool = false
    var variableAnchors: [ViewAnnotationAnchorConfig] = .center
    var actions = Actions()
    var content: AnyView

    /// Creates a view annotation at geographical coordinate.
    ///
    /// - Parameters:
    ///   - coordinate: Coordinate the view annotation is bound to.
    ///   - content: The view to place on the map.
    @_documentation(visibility: public)
    @available(iOS 13.0, *)
    public init<Content: View>(
        coordinate: CLLocationCoordinate2D,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(annotatedFeature: .geometry(Point(coordinate)), content: content)
    }

    /// Creates a view annotation on feature rendered on a layer.
    ///
    /// - Parameters:
    ///   - layerId: Layer identifier which renders the feature.
    ///   - featureId: Feature identifier. If not specified, the annotation will appear on any feature from that layer.
    ///   - content: The view to place on the map.
    @_documentation(visibility: public)
    @available(iOS 13.0, *)
    public init<Content: View>(
        layerId: String,
        featureId: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(annotatedFeature: .layerFeature(layerId: layerId, featureId: featureId), content: content)
    }

    /// Creates a view annotation.
    ///
    /// - Parameters:
    ///   - annotatedFeature: Associates the view annotation with the feature geometry. The geometry may be any `Geometry`, or a feature rendered on a specified layer.
    ///   - content: The view to place on the map.
    @_documentation(visibility: public)
    @available(iOS 13.0, *)
    public init<Content: View>(
        annotatedFeature: AnnotatedFeature,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.annotatedFeature = annotatedFeature
        self.content = AnyView(content())
    }

    /// If true, the annotation will be visible even if it collides with other annotations. Defaults to `false`.
    @_documentation(visibility: public)
    public func allowOverlap(_ allowOverlap: Bool) -> MapViewAnnotation {
        with(self, setter(\.allowOverlap, allowOverlap))
    }

    /// Configures whether this view participates in hit test operations.  Defaults to `true`.
    @_documentation(visibility: public)
    public func allowHitTesting(_ allowHitTesting: Bool) -> MapViewAnnotation {
        with(self, setter(\.allowHitTesting, allowHitTesting))
    }

    /// When `false`, the annotation won't be shown on top of Puck.
    ///
    /// Default value is `false`.
    @_documentation(visibility: public)
    public func allowOverlapWithPuck(_ allowOverlapWithPuck: Bool) -> MapViewAnnotation {
        with(self, setter(\.allowOverlapWithPuck, allowOverlapWithPuck))
    }

    /// When `false`, the annotation will be displayed even if it go beyond camera padding.
    ///
    /// Default value is `false`.
    @_documentation(visibility: public)
    public func ignoreCameraPadding(_ ignoreCameraPadding: Bool) -> MapViewAnnotation {
        with(self, setter(\.ignoreCameraPadding, ignoreCameraPadding))
    }

    /// Specifies if this view annotation is visible or not. Defaults to `true`.
    @_documentation(visibility: public)
    public func visible(_ visible: Bool) -> MapViewAnnotation {
        with(self, setter(\.visible, visible))
    }

    /// Specifies if this view annotation is selected meaning it should be placed on top of others. Defaults to `false`.
    @_documentation(visibility: public)
    public func selected(_ selected: Bool = false) -> MapViewAnnotation {
        with(self, setter(\.selected, selected))
    }

    /// A list of anchor configurations available.
    ///
    /// The annotation will automatically pick the first best anchor position depending on position
    /// relative to other elements on the map.
    ///
    /// The ``ViewAnnotation/onAnchorChanged`` is called when the
    /// effective position is updated.
    ///
    /// If not specified, the annotation will be placed in center.
    @_documentation(visibility: public)
    public func variableAnchors(_ variableAnchors: [ViewAnnotationAnchorConfig]) -> MapViewAnnotation {
        with(self, setter(\.variableAnchors, variableAnchors))
    }

    /// Called when anchor configuration is changed.
    ///
    /// See ``variableAnchors(_:)``.
    ///
    /// The callback takes the `anchorConfig` parameter which represents the selected anchor configuration.
    @_documentation(visibility: public)
    public func onAnchorChanged(action: @escaping (ViewAnnotationAnchorConfig) -> Void) -> MapViewAnnotation {
        with(self, setter(\.actions.anchor, action))
    }

    /// Called when visibility of annotation is changed.
    ///
    /// The annotation becomes hidden when it goes out of MapView's bounds or ``visible(_:)`` is changed.
    ///
    /// The callback takes `true` when annotation is visible.
    @_documentation(visibility: public)
    public func onVisibilityChanged(action: @escaping (Bool) -> Void) -> MapViewAnnotation {
        with(self, setter(\.actions.visibility, action))
    }

    /// Called when geographical coordinate of annotation anchor is changed.
    @_documentation(visibility: public)
    public func onAnchorCoordinateChanged(action: @escaping (CLLocationCoordinate2D) -> Void) -> MapViewAnnotation {
        with(self, setter(\.actions.anchorCoordinate, action))
    }
}

@available(iOS 13.0, *)
extension MapViewAnnotation: MapContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedViewAnnotation(mapViewAnnotation: self))
    }
}
