import UIKit
import MapboxCoreMaps
import Turf

/// Stores layout and visibilty settings for a `ViewAnnotation`
public struct ViewAnnotationOptions: Hashable {
    /// Geometry the view annotation is bound to. Currently only support 'point' geometry type.
    /// Note: geometry must be set when adding a new view annotation, otherwise an operation error will be returned from the call that is associated to this option.
    public var geometry: Geometry?

    /// View annotation width in pixels.
    public var width: CGFloat?

    /// View annotation height in pixels.
    public var height: CGFloat?

    /// Optional style symbol id connected to given view annotation.
    ///
    /// View annotation's visibility behaviour becomes tied to feature visibility where feature could represent an icon or a text label.
    /// E.g. if the bounded symbol is not visible view annotation also becomes not visible.
    ///
    /// Note: Invalid associatedFeatureId (meaning no actual symbol has such feature id) will lead to the cooresponding annotation to be invisible.
    public var associatedFeatureId: String?

    /// If true, the annotation will be visible even if it collides with other previously drawn annotations.
    /// If allowOverlap is null, default value `false` will be applied.
    /// Note: When the value is true, the ordering of the views are determined by the order of their addition.
    public var allowOverlap: Bool?

    /// Specifies if this view annotation is visible or not.
    ///
    /// Note: If this property is not specified explicitly when creating / updating view annotation, visibility will be
    /// handled automatically based on the `ViewAnnotation` view's visibility e.g. if actual view is set to be not visible the SDK
    /// will automatically update view annotation to have `visible = false`.
    ///
    /// If visible is null, default value `true` will be applied.
    public var visible: Bool?

    /// Anchor describing where the view annotation will be located relatively to given geometry.
    /// If anchor is null, default value `CENTER` will be applied.
    public var anchor: ViewAnnotationAnchor?

    /// Extra X offset in `platform pixels`.
    /// Providing positive value moves view annotation to the right while negative moves it to the left.
    public var offsetX: CGFloat?

    /// Extra Y offset in `platform pixels`.
    /// Providing positive value moves view annotation to the top while negative moves it to the bottom.
    public var offsetY: CGFloat?

    /// Specifies if this view annotation is selected meaning it should be placed on top of others.
    /// If selected in null, default value `false` will be applied.
    public var selected: Bool?

    /// Initializes a `ViewAnnotationOptions`
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
        self.geometry = geometry?.geometry
        self.width = width
        self.height = height
        self.associatedFeatureId = associatedFeatureId
        self.allowOverlap = allowOverlap
        self.visible = visible
        self.anchor = anchor
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.selected = selected
    }

    internal init(_ objcValue: MapboxCoreMaps.ViewAnnotationOptions) {
        self.init(
            geometry: objcValue.__geometry.flatMap(Geometry.init(_:)),
            width: objcValue.__width?.CGFloat,
            height: objcValue.__height?.CGFloat,
            associatedFeatureId: objcValue.__associatedFeatureId,
            allowOverlap: objcValue.__allowOverlap?.boolValue,
            visible: objcValue.__visible?.boolValue,
            anchor: objcValue.__anchor.flatMap { ViewAnnotationAnchor(rawValue: $0.intValue) },
            offsetX: objcValue.__offsetX?.CGFloat,
            offsetY: objcValue.__offsetY?.CGFloat,
            selected: objcValue.__selected?.boolValue
        )
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(associatedFeatureId)
        hasher.combine(allowOverlap)
        hasher.combine(visible)
        hasher.combine(anchor)
        hasher.combine(offsetX)
        hasher.combine(offsetY)
        hasher.combine(selected)
    }

    internal var frame: CGRect {
        guard let width = width, let height = height else { return .zero }

        let offset: (x: CGFloat, y: CGFloat) = (width * 0.5, height * 0.5)
        var frame = CGRect(x: -offset.x, y: -offset.y, width: width, height: height)
        let anchor = anchor ?? .center

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

        return frame.offsetBy(dx: offsetX ?? 0, dy: offsetY ?? 0)
    }
}

extension MapboxCoreMaps.ViewAnnotationOptions {
    internal convenience init(_ swiftValue: ViewAnnotationOptions) {
        self.init(__geometry: swiftValue.geometry.map(MapboxCommon.Geometry.init),
                  associatedFeatureId: swiftValue.associatedFeatureId,
                  width: swiftValue.width as NSNumber?,
                  height: swiftValue.height as NSNumber?,
                  allowOverlap: swiftValue.allowOverlap as NSNumber?,
                  visible: swiftValue.visible as NSNumber?,
                  anchor: swiftValue.anchor?.rawValue as NSNumber?,
                  offsetX: swiftValue.offsetX as NSNumber?,
                  offsetY: swiftValue.offsetY as NSNumber?,
                  selected: swiftValue.selected as NSNumber?)
    }
}
