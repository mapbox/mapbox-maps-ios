// This file is generated.
import UIKit

public struct CircleAnnotation: Annotation, Equatable, AnnotationInternal {
    /// Identifier for this annotation
    internal(set) public var id: String

    /// The geometry backing this annotation
    public var geometry: Geometry { point.geometry }

    /// The Point backing this annotation
    public var point: Point

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
    public var dragBeginHandler: ((inout CircleAnnotation, InteractionContext) -> Bool)? {
        get { gestureHandlers.value.dragBegin }
        set { gestureHandlers.value.dragBegin = newValue }
    }

    /// The handler is invoked when annotation is being dragged.
    ///
    /// The handler receives the `annotation` and the `context` parameters of the gesture:
    /// - Use the `annotation` inout property to update properties of the annotation.
    /// - The `context` contains position of the gesture.
    public var dragChangeHandler: ((inout CircleAnnotation, InteractionContext) -> Void)? {
        get { gestureHandlers.value.dragChange }
        set { gestureHandlers.value.dragChange = newValue }
    }

    /// The handler receives the `annotation` and the `context` parameters of the gesture:
    /// - Use the `annotation` inout property to update properties of the annotation.
    /// - The `context` contains position of the gesture.
    public var dragEndHandler: ((inout CircleAnnotation, InteractionContext) -> Void)? {
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
    private var gestureHandlers = AlwaysEqual(value: AnnotationGestureHandlers<CircleAnnotation>())

    var layerProperties: [String: Any] {
        var properties: [String: Any] = [:]
        properties["circle-sort-key"] = circleSortKey
        properties["circle-blur"] = circleBlur
        properties["circle-blur-transition"] = circleBlurTransition?.asDictionary
        properties["circle-color"] = circleColor?.rawValue
        properties["circle-color-use-theme"] = circleColorUseTheme?.rawValue
        properties["circle-color-transition"] = circleColorTransition?.asDictionary
        properties["circle-opacity"] = circleOpacity
        properties["circle-opacity-transition"] = circleOpacityTransition?.asDictionary
        properties["circle-radius"] = circleRadius
        properties["circle-radius-transition"] = circleRadiusTransition?.asDictionary
        properties["circle-stroke-color"] = circleStrokeColor?.rawValue
        properties["circle-stroke-color-use-theme"] = circleStrokeColorUseTheme?.rawValue
        properties["circle-stroke-color-transition"] = circleStrokeColorTransition?.asDictionary
        properties["circle-stroke-opacity"] = circleStrokeOpacity
        properties["circle-stroke-opacity-transition"] = circleStrokeOpacityTransition?.asDictionary
        properties["circle-stroke-width"] = circleStrokeWidth
        properties["circle-stroke-width-transition"] = circleStrokeWidthTransition?.asDictionary
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
        point = GeometryType.projection(of: point, for: translation, in: map)
    }

    /// Create a circle annotation with a `Point` and an optional identifier.
    public init(id: String = UUID().uuidString, point: Point, isSelected: Bool = false, isDraggable: Bool = false) {
        self.id = id
        self.point = point
        self.isSelected = isSelected
        self.isDraggable = isDraggable
    }

    /// Create a circle annotation with a center coordinate and an optional identifier
    /// - Parameters:
    ///   - id: Optional identifier for this annotation
    ///   - centerCoordinate: Coordinate where this circle annotation should be centered
    ///   - isDraggable: Determines whether annotation can be manually moved around map
    ///   - isSelected: Passes the annotation's selection state
    public init(id: String = UUID().uuidString, centerCoordinate: CLLocationCoordinate2D, isSelected: Bool = false, isDraggable: Bool = false) {
        let point = Point(centerCoordinate)
        self.init(id: id, point: point, isSelected: isSelected, isDraggable: isDraggable)
    }

    // MARK: - Style Properties -

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var circleSortKey: Double?

    /// Transition property for `circleBlur`
    public var circleBlurTransition: StyleTransition?

    /// Amount to blur the circle. 1 blurs the circle such that only the centerpoint is full opacity. Setting a negative value renders the blur as an inner glow effect.
    /// Default value: 0.
    public var circleBlur: Double?

    /// This property defines whether the `circleColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var circleColorUseTheme: ColorUseTheme?

    /// Transition property for `circleColor`
    public var circleColorTransition: StyleTransition?

    /// The fill color of the circle.
    /// Default value: "#000000".
    public var circleColor: StyleColor?

    /// Transition property for `circleOpacity`
    public var circleOpacityTransition: StyleTransition?

    /// The opacity at which the circle will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public var circleOpacity: Double?

    /// Transition property for `circleRadius`
    public var circleRadiusTransition: StyleTransition?

    /// Circle radius.
    /// Default value: 5. Minimum value: 0. The unit of circleRadius is in pixels.
    public var circleRadius: Double?

    /// This property defines whether the `circleStrokeColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var circleStrokeColorUseTheme: ColorUseTheme?

    /// Transition property for `circleStrokeColor`
    public var circleStrokeColorTransition: StyleTransition?

    /// The stroke color of the circle.
    /// Default value: "#000000".
    public var circleStrokeColor: StyleColor?

    /// Transition property for `circleStrokeOpacity`
    public var circleStrokeOpacityTransition: StyleTransition?

    /// The opacity of the circle's stroke.
    /// Default value: 1. Value range: [0, 1]
    public var circleStrokeOpacity: Double?

    /// Transition property for `circleStrokeWidth`
    public var circleStrokeWidthTransition: StyleTransition?

    /// The width of the circle's stroke. Strokes are placed outside of the `circle-radius`.
    /// Default value: 0. Minimum value: 0. The unit of circleStrokeWidth is in pixels.
    public var circleStrokeWidth: Double?

}

extension CircleAnnotation {

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

extension CircleAnnotation {
    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public func circleSortKey(_ newValue: Double) -> Self {
        with(self, setter(\.circleSortKey, newValue))
    }

    /// Transition property for `circleBlur`
    public func circleBlurTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.circleBlurTransition, transition))
    }

    /// Amount to blur the circle. 1 blurs the circle such that only the centerpoint is full opacity. Setting a negative value renders the blur as an inner glow effect.
    /// Default value: 0.
    public func circleBlur(_ newValue: Double) -> Self {
        with(self, setter(\.circleBlur, newValue))
    }

    /// The fill color of the circle.
    /// Default value: "#000000".
    public func circleColor(_ color: UIColor) -> Self {
        with(self, setter(\.circleColor, StyleColor(color)))
    }

    /// This property defines whether the `circleColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func circleColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.circleColorUseTheme, useTheme))
    }

    /// Transition property for `circleColor`
    public func circleColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.circleColorTransition, transition))
    }

    /// The fill color of the circle.
    /// Default value: "#000000".
    public func circleColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.circleColor, newValue))
    }

    /// Transition property for `circleOpacity`
    public func circleOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.circleOpacityTransition, transition))
    }

    /// The opacity at which the circle will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func circleOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.circleOpacity, newValue))
    }

    /// Transition property for `circleRadius`
    public func circleRadiusTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.circleRadiusTransition, transition))
    }

    /// Circle radius.
    /// Default value: 5. Minimum value: 0. The unit of circleRadius is in pixels.
    public func circleRadius(_ newValue: Double) -> Self {
        with(self, setter(\.circleRadius, newValue))
    }

    /// The stroke color of the circle.
    /// Default value: "#000000".
    public func circleStrokeColor(_ color: UIColor) -> Self {
        with(self, setter(\.circleStrokeColor, StyleColor(color)))
    }

    /// This property defines whether the `circleStrokeColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func circleStrokeColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.circleStrokeColorUseTheme, useTheme))
    }

    /// Transition property for `circleStrokeColor`
    public func circleStrokeColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.circleStrokeColorTransition, transition))
    }

    /// The stroke color of the circle.
    /// Default value: "#000000".
    public func circleStrokeColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.circleStrokeColor, newValue))
    }

    /// Transition property for `circleStrokeOpacity`
    public func circleStrokeOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.circleStrokeOpacityTransition, transition))
    }

    /// The opacity of the circle's stroke.
    /// Default value: 1. Value range: [0, 1]
    public func circleStrokeOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.circleStrokeOpacity, newValue))
    }

    /// Transition property for `circleStrokeWidth`
    public func circleStrokeWidthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.circleStrokeWidthTransition, transition))
    }

    /// The width of the circle's stroke. Strokes are placed outside of the `circle-radius`.
    /// Default value: 0. Minimum value: 0. The unit of circleStrokeWidth is in pixels.
    public func circleStrokeWidth(_ newValue: Double) -> Self {
        with(self, setter(\.circleStrokeWidth, newValue))
    }
}

extension CircleAnnotation: MapContent, PrimitiveMapContent {

    func visit(_ node: MapContentNode) {
        CircleAnnotationGroup { self }.visit(node)
    }
}

// End of generated file.
