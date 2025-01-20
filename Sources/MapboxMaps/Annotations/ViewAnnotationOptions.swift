import UIKit
import Turf

/// Stores layout and visibility settings for a view annotation.
///
/// - Important: `ViewAnnotationOptions` is deprecated and will be removed in future releases. Use ``ViewAnnotation`` instead.
public struct ViewAnnotationOptions: Equatable {
    /// Geometry the view annotation is bound to. Currently only support 'point' geometry type.
    /// Note: geometry must be set when adding a new view annotation, otherwise an operation error will be returned from the call that is associated to this option.
    @available(*, unavailable, message: "Use annotatedFeature instead.")
    public var geometry: Geometry? { fatalError() }

    public var annotatedFeature: AnnotatedFeature?

    /// View annotation width in pixels.
    public var width: CGFloat?

    /// View annotation height in pixels.
    public var height: CGFloat?

    /// Optional style symbol id connected to given view annotation.
    ///
    /// View annotation's visibility behavior becomes tied to feature visibility where feature could represent an icon or a text label.
    /// E.g. if the bounded symbol is not visible view annotation also becomes not visible.
    ///
    /// Note: Invalid associatedFeatureId (meaning no actual symbol has such feature id) will lead to the cooresponding annotation to be invisible.
    @available(*, unavailable, message: "Use annotatedFeature instead.")
    public var associatedFeatureId: String? { fatalError() }

    /// If true, the annotation will be visible even if it collides with other previously drawn annotations.
    /// If allowOverlap is null, default value `false` will be applied.
    /// Note: When the value is true, the ordering of the views are determined by the order of their addition.
    public var allowOverlap: Bool?

    /// When `false`, the annotation won't be shown on top of the Puck.
    public var allowOverlapWithPuck: Bool?

    /// When `true`, the annotation will respect Z-axis elevation and be rendered on top of elevated objects.
    public var allowZElevate: Bool?

    /// Specifies if this view annotation is visible or not.
    ///
    /// Note: If this property is not specified explicitly when creating / updating view annotation, visibility will be
    /// handled automatically based on the `ViewAnnotation` view's visibility e.g. if actual view is set to be not visible the SDK
    /// will automatically update view annotation to have `visible = false`.
    ///
    /// If visible is null, default value `true` will be applied.
    public var visible: Bool?

    /// A list of anchor configurations available.
    ///
    /// The annotation will automatically pick the first best anchor position depending on position
    /// relative to other elements on the map.
    ///
    /// The ``ViewAnnotation/onAnchorChanged`` is called when the
    /// effective position is updated.
    ///
    /// If not specified, the annotation will be placed in center.
    public var variableAnchors: [ViewAnnotationAnchorConfig]?

    /// Anchor describing where the view annotation will be located relatively to given geometry.
    /// If anchor is null, default value `CENTER` will be applied.
    @available(*, unavailable, message: "Use variableAnchors instead.")
    public var anchor: ViewAnnotationAnchor? { fatalError() }

    /// Extra X offset in `platform pixels`.
    /// Providing positive value moves view annotation to the right while negative moves it to the left.
    @available(*, unavailable, message: "Use variableAnchors instead.")
    public var offsetX: CGFloat? { fatalError() }

    /// Extra Y offset in `platform pixels`.
    /// Providing positive value moves view annotation to the top while negative moves it to the bottom.
    @available(*, unavailable, message: "Use variableAnchors instead.")
    public var offsetY: CGFloat? { fatalError() }

    /// Specifies if this view annotation is selected meaning it should be placed on top of others.
    /// If selected in null, default value `false` will be applied.
    @available(*, deprecated, message: "Use priority instead.")
    public var selected: Bool?

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
    public var priority: Int?

    /// When `false`, the annotation will be displayed even if it go beyond camera padding.
    public var ignoreCameraPadding: Bool?

    /// Minimum zoom value in range [0, 22] to display View Annotation.
    /// If not provided or is out of range, defaults to 0.
    public var minZoom: Double?

    /// Maximum zoom value in range [0, 22] to display View Annotation.
    /// Should be greater than or equal to minZoom.
    /// If not provided or is out of range, defaults to 22.
    public var maxZoom: Double?

    /// Initializes a `ViewAnnotationOptions`
    public init(
        annotatedFeature: AnnotatedFeature? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        allowOverlap: Bool? = nil,
        allowOverlapWithPuck: Bool? = nil,
        visible: Bool? = nil,
        priority: Int? = nil,
        variableAnchors: [ViewAnnotationAnchorConfig]? = nil,
        ignoreCameraPadding: Bool? = nil,
        minZoom: Double? = nil,
        maxZoom: Double? = nil
    ) {
        self.init(
            annotatedFeature: annotatedFeature,
            width: width,
            height: height,
            allowOverlap: allowOverlap,
            allowOverlapWithPuck: allowOverlapWithPuck,
            visible: visible,
            selected: nil,
            priority: priority,
            variableAnchors: variableAnchors,
            ignoreCameraPadding: ignoreCameraPadding,
            minZoom: minZoom,
            maxZoom: maxZoom
        )
    }

    @available(*, deprecated, message: "Use priority instead.")
    /// Initializes a `ViewAnnotationOptions`
    public init(
        annotatedFeature: AnnotatedFeature? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        allowOverlap: Bool? = nil,
        allowOverlapWithPuck: Bool? = nil,
        visible: Bool? = nil,
        selected: Bool?,
        variableAnchors: [ViewAnnotationAnchorConfig]? = nil,
        ignoreCameraPadding: Bool? = nil,
        minZoom: Double? = nil,
        maxZoom: Double? = nil
    ) {
        self.init(
            annotatedFeature: annotatedFeature,
            width: width,
            height: height,
            allowOverlap: allowOverlap,
            allowOverlapWithPuck: allowOverlapWithPuck,
            visible: visible,
            selected: selected,
            priority: nil,
            variableAnchors: variableAnchors,
            ignoreCameraPadding: ignoreCameraPadding,
            minZoom: minZoom,
            maxZoom: maxZoom
        )
    }

    private init(
        annotatedFeature: AnnotatedFeature? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        allowOverlap: Bool? = nil,
        allowOverlapWithPuck: Bool? = nil,
        visible: Bool? = nil,
        selected: Bool? = nil,
        priority: Int? = nil,
        variableAnchors: [ViewAnnotationAnchorConfig]? = nil,
        ignoreCameraPadding: Bool? = nil,
        minZoom: Double? = nil,
        maxZoom: Double? = nil
    ) {
        self.annotatedFeature = annotatedFeature
        self.width = width
        self.height = height
        self.variableAnchors = variableAnchors
        self.allowOverlap = allowOverlap
        self.allowOverlapWithPuck = allowOverlapWithPuck
        self.visible = visible
        self.selected = selected
        self.priority = priority
        self.ignoreCameraPadding = ignoreCameraPadding
        self.minZoom = minZoom
        self.maxZoom = maxZoom
    }

    /// Initializes a `ViewAnnotationOptions` with geometry.
    @available(*, deprecated, message: "Use ViewAnnotation to create view annotations.")
    public init(geometry: GeometryConvertible? = nil,
                width: CGFloat? = nil,
                height: CGFloat? = nil,
                associatedFeatureId: String? = nil,
                allowOverlap: Bool? = nil,
                visible: Bool? = nil,
                anchor: ViewAnnotationAnchor? = nil,
                offsetX: CGFloat? = nil,
                offsetY: CGFloat? = nil,
                selected: Bool? = nil) {
        var anchorConfig: ViewAnnotationAnchorConfig?
        if anchor != nil || offsetX != nil || offsetY != nil {
            anchorConfig = ViewAnnotationAnchorConfig(
                anchor: anchor ?? .center,
                offsetX: offsetX ?? 0,
                offsetY: offsetY ?? 0)
        }

        self.init(
            annotatedFeature: geometry.map { .geometry($0) },
            width: width,
            height: height,
            allowOverlap: allowOverlap,
            visible: visible,
            selected: selected,
            variableAnchors: anchorConfig.map { [$0] })
    }

    internal init(_ objcValue: CoreViewAnnotationOptions) {
        let annotatedFeature = objcValue.annotatedFeature.flatMap(AnnotatedFeature.from(core:))
        self.init(
            annotatedFeature: annotatedFeature,
            width: objcValue.__width?.CGFloat,
            height: objcValue.__height?.CGFloat,
            allowOverlap: objcValue.__allowOverlap?.boolValue,
            allowOverlapWithPuck: objcValue.__allowOverlapWithPuck?.boolValue,
            visible: objcValue.__visible?.boolValue,
            selected: objcValue.__selected?.boolValue,
            priority: objcValue.__priority?.intValue,
            variableAnchors: objcValue.variableAnchors,
            ignoreCameraPadding: objcValue.__ignoreCameraPadding?.boolValue,
            minZoom: objcValue.__minZoom?.doubleValue,
            maxZoom: objcValue.__maxZoom?.doubleValue
        )
    }

    internal func frame(with chosenAnchorConfig: ViewAnnotationAnchorConfig?) -> CGRect {
        guard let width = width, let height = height else { return .zero }

        let offset: (x: CGFloat, y: CGFloat) = (width * 0.5, height * 0.5)
        var frame = CGRect(x: -offset.x, y: -offset.y, width: width, height: height)
        let anchorConfig = chosenAnchorConfig ?? variableAnchors?.first
        let anchor = anchorConfig?.anchor ?? .center

        switch anchor {
        case .top:
            frame = frame.offsetBy(dx: 0, dy: offset.y)
        case .topLeft:
            frame = frame.offsetBy(dx: offset.x, dy: offset.y)
        case .topRight:
            frame = frame.offsetBy(dx: -offset.x, dy: offset.y)
        case .bottom:
            frame = frame.offsetBy(dx: 0, dy: -offset.y)
        case .bottomLeft:
            frame = frame.offsetBy(dx: offset.x, dy: -offset.y)
        case .bottomRight:
            frame = frame.offsetBy(dx: -offset.x, dy: -offset.y)
        case .left:
            frame = frame.offsetBy(dx: offset.x, dy: 0)
        case .right:
            frame = frame.offsetBy(dx: -offset.x, dy: 0)
        case .center:
            fallthrough
        @unknown default:
            break
        }

        return frame.offsetBy(dx: anchorConfig?.offsetX ?? 0, dy: anchorConfig?.offsetY ?? 0)
    }
}

extension CoreViewAnnotationOptions {
    internal convenience init(_ swiftValue: ViewAnnotationOptions) {
        self.init(__annotatedFeature: swiftValue.annotatedFeature?.asCoreFeature,
                  width: swiftValue.width as NSNumber?,
                  height: swiftValue.height as NSNumber?,
                  allowOverlap: swiftValue.allowOverlap as NSNumber?,
                  allowOverlapWithPuck: swiftValue.allowOverlapWithPuck as NSNumber?,
                  allowZElevate: swiftValue.allowZElevate as NSNumber?,
                  visible: swiftValue.visible as NSNumber?,
                  variableAnchors: swiftValue.variableAnchors,
                  selected: swiftValue.selected as NSNumber?,
                  priority: swiftValue.priority as NSNumber?,
                  ignoreCameraPadding: swiftValue.ignoreCameraPadding as NSNumber?,
                  minZoom: swiftValue.minZoom as NSNumber?,
                  maxZoom: swiftValue.maxZoom as NSNumber?
        )
    }
}
