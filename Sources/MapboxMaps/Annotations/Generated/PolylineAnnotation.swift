// This file is generated.
import UIKit

public struct PolylineAnnotation: Annotation, Equatable {

    /// Identifier for this annotation
    internal(set) public var id: String

    /// The geometry backing this annotation
    public var geometry: Geometry {
        return .lineString(lineString)
    }

    /// The line string backing this annotation
    public var lineString: LineString

    /// Toggles the annotation's selection state.
    /// If the annotation is deselected, it becomes selected.
    /// If the annotation is selected, it becomes deselected.
    public var isSelected: Bool = false

    /// Property to determine whether annotation can be manually moved around map
    public var isDraggable: Bool = false

    /// Handles tap gesture on this annotation.
    ///
    /// Should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    public var tapHandler: ((MapContentGestureContext) -> Bool)? {
        get { gestureHandlers.tap }
        set { gestureHandlers.tap = newValue }
    }

    /// Handles long press gesture on this annotation.
    ///
    /// Should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    public var longPressHandler: ((MapContentGestureContext) -> Bool)? {
        get { gestureHandlers.longPress }
        set { gestureHandlers.longPress = newValue }
    }

    /// Properties associated with the annotation
    public var userInfo: [String: Any]? {
        get { _userInfo?.rawValue as? [String: Any] }
        set {
            let newValue = newValue ?? [:]
            _userInfo = JSONObject(rawValue: newValue)
        }
    }
    private var _userInfo: JSONObject?

    internal var layerProperties: [String: Any] {
        var properties: [String: Any] = [:]
        properties["line-join"] = lineJoin?.rawValue
        properties["line-sort-key"] = lineSortKey
        properties["line-blur"] = lineBlur
        properties["line-border-color"] = lineBorderColor?.rawValue
        properties["line-border-width"] = lineBorderWidth
        properties["line-color"] = lineColor?.rawValue
        properties["line-gap-width"] = lineGapWidth
        properties["line-offset"] = lineOffset
        properties["line-opacity"] = lineOpacity
        properties["line-pattern"] = linePattern
        properties["line-width"] = lineWidth
        return properties
    }

    internal var feature: Feature {
        var feature = Feature(geometry: geometry)
        feature.identifier = .string(id)
        var properties = JSONObject()
        properties["layerProperties"] = JSONValue(rawValue: layerProperties)
        if let _userInfo {
            properties["userInfo"] = .object(_userInfo)
        }
        feature.properties = properties
        return feature
    }

    private var gestureHandlers = AnnotationGestureHandlers()

    /// Create a polyline annotation with a `LineString` and an optional identifier.
    public init(id: String = UUID().uuidString, lineString: LineString, isSelected: Bool = false, isDraggable: Bool = false) {
        self.id = id
        self.lineString = lineString
        self.isSelected = isSelected
        self.isDraggable = isDraggable
    }

    /// Create a polyline annotation with an array of coordinates and an optional identifier.
    public init(id: String = UUID().uuidString, lineCoordinates: [CLLocationCoordinate2D], isSelected: Bool = false, isDraggable: Bool = false) {
        let lineString = LineString(lineCoordinates)
        self.init(id: id, lineString: lineString, isSelected: isSelected, isDraggable: isDraggable)
    }

    // MARK: - Style Properties -

    /// The display of lines when joining.
    public var lineJoin: LineJoin?

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var lineSortKey: Double?

    /// Blur applied to the line, in pixels.
    public var lineBlur: Double?

    /// The color of the line border. If line-border-width is greater than zero and the alpha value of this color is 0 (default), the color for the border will be selected automatically based on the line color.
    public var lineBorderColor: StyleColor?

    /// The width of the line border. A value of zero means no border.
    public var lineBorderWidth: Double?

    /// The color with which the line will be drawn.
    public var lineColor: StyleColor?

    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
    public var lineGapWidth: Double?

    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
    public var lineOffset: Double?

    /// The opacity at which the line will be drawn.
    public var lineOpacity: Double?

    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var linePattern: String?

    /// Stroke thickness.
    public var lineWidth: Double?

}

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental) extension PolylineAnnotation {

    /// The display of lines when joining.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func lineJoin(_ newValue: LineJoin) -> Self {
        with(self, setter(\.lineJoin, newValue))
    }

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func lineSortKey(_ newValue: Double) -> Self {
        with(self, setter(\.lineSortKey, newValue))
    }

    /// Blur applied to the line, in pixels.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func lineBlur(_ newValue: Double) -> Self {
        with(self, setter(\.lineBlur, newValue))
    }

    /// The color of the line border. If line-border-width is greater than zero and the alpha value of this color is 0 (default), the color for the border will be selected automatically based on the line color.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func lineBorderColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.lineBorderColor, newValue))
    }

    /// The width of the line border. A value of zero means no border.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func lineBorderWidth(_ newValue: Double) -> Self {
        with(self, setter(\.lineBorderWidth, newValue))
    }

    /// The color with which the line will be drawn.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func lineColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.lineColor, newValue))
    }

    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func lineGapWidth(_ newValue: Double) -> Self {
        with(self, setter(\.lineGapWidth, newValue))
    }

    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func lineOffset(_ newValue: Double) -> Self {
        with(self, setter(\.lineOffset, newValue))
    }

    /// The opacity at which the line will be drawn.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func lineOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.lineOpacity, newValue))
    }

    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func linePattern(_ newValue: String) -> Self {
        with(self, setter(\.linePattern, newValue))
    }

    /// Stroke thickness.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func lineWidth(_ newValue: Double) -> Self {
        with(self, setter(\.lineWidth, newValue))
    }


    /// Adds a handler for tap gesture on current annotation.
    ///
    /// The handler should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    ///
    /// - Parameters:
    ///   - handler: A handler for tap gesture.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func onTapGesture(handler: @escaping (MapContentGestureContext) -> Bool) -> Self {
        with(self, setter(\.tapHandler, handler))
    }

    /// Adds a handler for tap gesture on current annotation.
    ///
    /// - Parameters:
    ///   - handler: A handler for tap gesture.
    #if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func onTapGesture(handler: @escaping () -> Void) -> Self {
        onTapGesture { _ in
            handler()
            return true
        }
    }

    /// Adds a handler for long press gesture on current annotation.
    ///
    /// The handler should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    ///
    /// - Parameters:
    ///   - handler: A handler for long press gesture.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func onLongPressGesture(handler: @escaping (MapContentGestureContext) -> Bool) -> Self {
        with(self, setter(\.longPressHandler, handler))
    }

    /// Adds a handler for long press gesture on current annotation.
    ///
    /// - Parameters:
    ///   - handler: A handler for long press gesture.
    #if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func onLongPressGesture(handler: @escaping () -> Void) -> Self {
        onLongPressGesture { _ in
            handler()
            return true
        }
    }
}

// End of generated file.
