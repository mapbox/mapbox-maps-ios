// This file is generated.
import UIKit

public struct PolylineAnnotation: Annotation, Equatable, AnnotationInternal {
    /// Identifier for this annotation
    internal(set) public var id: String

    /// The geometry backing this annotation
    public var geometry: Geometry { lineString.geometry }

    /// The LineString backing this annotation
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
    public var tapHandler: ((InteractionContext) -> Bool)? {
        get { gestureHandlers.value.tap }
        set { gestureHandlers.value.tap = newValue }
    }

    /// Handles long press gesture on this annotation.
    ///
    /// Should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    public var longPressHandler: ((InteractionContext) -> Bool)? {
        get { gestureHandlers.value.longPress }
        set { gestureHandlers.value.longPress = newValue }
    }

    /// The handler is invoked when the user begins to drag the annotation.
    ///
    /// The annotation should have `isDraggable` set to `true` to make id draggable.
    ///
    /// - Note: In SwiftUI, draggable annotations are not supported.
    ///
    /// The handler receives the `annotation` and the `context` parameters of the gesture:
    /// - Use the `annotation` inout property to update properties of the annotation.
    /// - The `context` contains position of the gesture.
    /// Return `true` to allow dragging to begin, or `false` to prevent it and propagate the gesture to the map's other annotations or layers.
    public var dragBeginHandler: ((inout PolylineAnnotation, InteractionContext) -> Bool)? {
        get { gestureHandlers.value.dragBegin }
        set { gestureHandlers.value.dragBegin = newValue }
    }

    /// The handler is invoked when annotation is being dragged.
    ///
    /// The handler receives the `annotation` and the `context` parameters of the gesture:
    /// - Use the `annotation` inout property to update properties of the annotation.
    /// - The `context` contains position of the gesture.
    public var dragChangeHandler: ((inout PolylineAnnotation, InteractionContext) -> Void)? {
        get { gestureHandlers.value.dragChange }
        set { gestureHandlers.value.dragChange = newValue }
    }

    /// The handler receives the `annotation` and the `context` parameters of the gesture:
    /// - Use the `annotation` inout property to update properties of the annotation.
    /// - The `context` contains position of the gesture.
    public var dragEndHandler: ((inout PolylineAnnotation, InteractionContext) -> Void)? {
        get { gestureHandlers.value.dragEnd }
        set { gestureHandlers.value.dragEnd = newValue }
    }

    /// JSON convertible properties associated with the annotation, used to enrich Feature GeoJSON `properties["custom_data"]` field.
    public var customData = JSONObject()

    /// Properties associated with the annotation.
    ///
    /// - Note: This property doesn't participate in `Equatable` comparisions and will strip non-JSON values when encoding to Feature GeoJSON.
    @available(*, deprecated, message: "Use customData instead.")
    public var userInfo: [String: Any]? {
        get { _userInfo.value }
        set { _userInfo.value = newValue }
    }

    private var _userInfo: AlwaysEqual<[String: Any]?> = nil
    private var gestureHandlers = AlwaysEqual(value: AnnotationGestureHandlers<PolylineAnnotation>())

    var layerProperties: [String: Any] {
        var properties: [String: Any] = [:]
        properties["line-join"] = lineJoin?.rawValue
        properties["line-sort-key"] = lineSortKey
        properties["line-z-offset"] = lineZOffset
        properties["line-blur"] = lineBlur
        properties["line-blur-transition"] = lineBlurTransition?.asDictionary
        properties["line-border-color"] = lineBorderColor?.rawValue
        properties["line-border-color-use-theme"] = lineBorderColorUseTheme?.rawValue
        properties["line-border-color-transition"] = lineBorderColorTransition?.asDictionary
        properties["line-border-width"] = lineBorderWidth
        properties["line-border-width-transition"] = lineBorderWidthTransition?.asDictionary
        properties["line-color"] = lineColor?.rawValue
        properties["line-color-use-theme"] = lineColorUseTheme?.rawValue
        properties["line-color-transition"] = lineColorTransition?.asDictionary
        properties["line-gap-width"] = lineGapWidth
        properties["line-gap-width-transition"] = lineGapWidthTransition?.asDictionary
        properties["line-offset"] = lineOffset
        properties["line-offset-transition"] = lineOffsetTransition?.asDictionary
        properties["line-opacity"] = lineOpacity
        properties["line-opacity-transition"] = lineOpacityTransition?.asDictionary
        properties["line-pattern"] = linePattern
        properties["line-width"] = lineWidth
        properties["line-width-transition"] = lineWidthTransition?.asDictionary
        return properties
    }

    var feature: Feature {
        var feature = Feature(geometry: geometry)
        feature.identifier = .string(id)
        var properties = JSONObject()
        properties["layerProperties"] = JSONValue(rawValue: layerProperties)
        properties["custom_data"] = .object(customData)
        if let userInfoValue = _userInfo.value.flatMap(JSONValue.init) {
            properties["userInfo"] = userInfoValue
        }
        feature.properties = properties
        return feature
    }

    mutating func drag(translation: CGPoint, in map: MapboxMapProtocol) {
        lineString = GeometryType.projection(of: lineString, for: translation, in: map)
    }

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
    /// Default value: "miter".
    public var lineJoin: LineJoin?

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var lineSortKey: Double?

    /// Vertical offset from ground, in meters. Defaults to 0. This is an experimental property with some known issues:
    ///  - Not supported for globe projection at the moment
    ///  - Elevated line discontinuity is possible on tile borders with terrain enabled
    ///  - Rendering artifacts can happen near line joins and line caps depending on the line styling
    ///  - Rendering artifacts relating to `line-opacity` and `line-blur`
    ///  - Elevated line visibility is determined by layer order
    ///  - Z-fighting issues can happen with intersecting elevated lines
    ///  - Elevated lines don't cast shadows
    /// Default value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var lineZOffset: Double?

    /// Transition property for `lineBlur`
    public var lineBlurTransition: StyleTransition?

    /// Blur applied to the line, in pixels.
    /// Default value: 0. Minimum value: 0. The unit of lineBlur is in pixels.
    public var lineBlur: Double?

    /// This property defines whether the `lineBorderColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var lineBorderColorUseTheme: ColorUseTheme?

    /// Transition property for `lineBorderColor`
    public var lineBorderColorTransition: StyleTransition?

    /// The color of the line border. If line-border-width is greater than zero and the alpha value of this color is 0 (default), the color for the border will be selected automatically based on the line color.
    /// Default value: "rgba(0, 0, 0, 0)".
    public var lineBorderColor: StyleColor?

    /// Transition property for `lineBorderWidth`
    public var lineBorderWidthTransition: StyleTransition?

    /// The width of the line border. A value of zero means no border.
    /// Default value: 0. Minimum value: 0.
    public var lineBorderWidth: Double?

    /// This property defines whether the `lineColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var lineColorUseTheme: ColorUseTheme?

    /// Transition property for `lineColor`
    public var lineColorTransition: StyleTransition?

    /// The color with which the line will be drawn.
    /// Default value: "#000000".
    public var lineColor: StyleColor?

    /// Transition property for `lineGapWidth`
    public var lineGapWidthTransition: StyleTransition?

    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
    /// Default value: 0. Minimum value: 0. The unit of lineGapWidth is in pixels.
    public var lineGapWidth: Double?

    /// Transition property for `lineOffset`
    public var lineOffsetTransition: StyleTransition?

    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
    /// Default value: 0. The unit of lineOffset is in pixels.
    public var lineOffset: Double?

    /// Transition property for `lineOpacity`
    public var lineOpacityTransition: StyleTransition?

    /// The opacity at which the line will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public var lineOpacity: Double?

    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var linePattern: String?

    /// Transition property for `lineWidth`
    public var lineWidthTransition: StyleTransition?

    /// Stroke thickness.
    /// Default value: 1. Minimum value: 0. The unit of lineWidth is in pixels.
    public var lineWidth: Double?

}

extension PolylineAnnotation {

    /// Adds a handler for tap gesture on current annotation.
    ///
    /// The handler should return `true` if the gesture is handled, or `false` to propagate it to the annotations or layers below.
    ///
    /// - Parameters:
    ///   - handler: A handler for tap gesture.
    public func onTapGesture(handler: @escaping (InteractionContext) -> Bool) -> Self {
        with(self, setter(\.tapHandler, handler))
    }

    /// Adds a handler for tap gesture on current annotation.
    ///
    /// - Parameters:
    ///   - handler: A handler for tap gesture.
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
    public func onLongPressGesture(handler: @escaping (InteractionContext) -> Bool) -> Self {
        with(self, setter(\.longPressHandler, handler))
    }

    /// Adds a handler for long press gesture on current annotation.
    ///
    /// - Parameters:
    ///   - handler: A handler for long press gesture.
    public func onLongPressGesture(handler: @escaping () -> Void) -> Self {
        onLongPressGesture { _ in
            handler()
            return true
        }
    }
}

extension PolylineAnnotation {
    /// The display of lines when joining.
    /// Default value: "miter".
    public func lineJoin(_ newValue: LineJoin) -> Self {
        with(self, setter(\.lineJoin, newValue))
    }

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public func lineSortKey(_ newValue: Double) -> Self {
        with(self, setter(\.lineSortKey, newValue))
    }

    /// Vertical offset from ground, in meters. Defaults to 0. This is an experimental property with some known issues:
    ///  - Not supported for globe projection at the moment
    ///  - Elevated line discontinuity is possible on tile borders with terrain enabled
    ///  - Rendering artifacts can happen near line joins and line caps depending on the line styling
    ///  - Rendering artifacts relating to `line-opacity` and `line-blur`
    ///  - Elevated line visibility is determined by layer order
    ///  - Z-fighting issues can happen with intersecting elevated lines
    ///  - Elevated lines don't cast shadows
    /// Default value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineZOffset(_ newValue: Double) -> Self {
        with(self, setter(\.lineZOffset, newValue))
    }

    /// Transition property for `lineBlur`
    public func lineBlurTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineBlurTransition, transition))
    }

    /// Blur applied to the line, in pixels.
    /// Default value: 0. Minimum value: 0. The unit of lineBlur is in pixels.
    public func lineBlur(_ newValue: Double) -> Self {
        with(self, setter(\.lineBlur, newValue))
    }

    /// The color of the line border. If line-border-width is greater than zero and the alpha value of this color is 0 (default), the color for the border will be selected automatically based on the line color.
    /// Default value: "rgba(0, 0, 0, 0)".
    public func lineBorderColor(_ color: UIColor) -> Self {
        with(self, setter(\.lineBorderColor, StyleColor(color)))
    }

    /// This property defines whether the `lineBorderColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineBorderColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.lineBorderColorUseTheme, useTheme))
    }

    /// Transition property for `lineBorderColor`
    public func lineBorderColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineBorderColorTransition, transition))
    }

    /// The color of the line border. If line-border-width is greater than zero and the alpha value of this color is 0 (default), the color for the border will be selected automatically based on the line color.
    /// Default value: "rgba(0, 0, 0, 0)".
    public func lineBorderColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.lineBorderColor, newValue))
    }

    /// Transition property for `lineBorderWidth`
    public func lineBorderWidthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineBorderWidthTransition, transition))
    }

    /// The width of the line border. A value of zero means no border.
    /// Default value: 0. Minimum value: 0.
    public func lineBorderWidth(_ newValue: Double) -> Self {
        with(self, setter(\.lineBorderWidth, newValue))
    }

    /// The color with which the line will be drawn.
    /// Default value: "#000000".
    public func lineColor(_ color: UIColor) -> Self {
        with(self, setter(\.lineColor, StyleColor(color)))
    }

    /// This property defines whether the `lineColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.lineColorUseTheme, useTheme))
    }

    /// Transition property for `lineColor`
    public func lineColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineColorTransition, transition))
    }

    /// The color with which the line will be drawn.
    /// Default value: "#000000".
    public func lineColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.lineColor, newValue))
    }

    /// Transition property for `lineGapWidth`
    public func lineGapWidthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineGapWidthTransition, transition))
    }

    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
    /// Default value: 0. Minimum value: 0. The unit of lineGapWidth is in pixels.
    public func lineGapWidth(_ newValue: Double) -> Self {
        with(self, setter(\.lineGapWidth, newValue))
    }

    /// Transition property for `lineOffset`
    public func lineOffsetTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineOffsetTransition, transition))
    }

    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
    /// Default value: 0. The unit of lineOffset is in pixels.
    public func lineOffset(_ newValue: Double) -> Self {
        with(self, setter(\.lineOffset, newValue))
    }

    /// Transition property for `lineOpacity`
    public func lineOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineOpacityTransition, transition))
    }

    /// The opacity at which the line will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func lineOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.lineOpacity, newValue))
    }

    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public func linePattern(_ newValue: String) -> Self {
        with(self, setter(\.linePattern, newValue))
    }

    /// Transition property for `lineWidth`
    public func lineWidthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.lineWidthTransition, transition))
    }

    /// Stroke thickness.
    /// Default value: 1. Minimum value: 0. The unit of lineWidth is in pixels.
    public func lineWidth(_ newValue: Double) -> Self {
        with(self, setter(\.lineWidth, newValue))
    }
}

extension PolylineAnnotation: MapContent, PrimitiveMapContent {

    func visit(_ node: MapContentNode) {
        PolylineAnnotationGroup { self }.visit(node)
    }
}

// End of generated file.
