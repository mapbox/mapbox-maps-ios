// This file is generated.
import UIKit

public struct PolygonAnnotation: Annotation, Equatable, AnnotationInternal {
    /// Identifier for this annotation
    internal(set) public var id: String

    /// The geometry backing this annotation
    public var geometry: Geometry { polygon.geometry }

    /// The Polygon backing this annotation
    public var polygon: Polygon

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
    public var dragBeginHandler: ((inout PolygonAnnotation, InteractionContext) -> Bool)? {
        get { gestureHandlers.value.dragBegin }
        set { gestureHandlers.value.dragBegin = newValue }
    }

    /// The handler is invoked when annotation is being dragged.
    ///
    /// The handler receives the `annotation` and the `context` parameters of the gesture:
    /// - Use the `annotation` inout property to update properties of the annotation.
    /// - The `context` contains position of the gesture.
    public var dragChangeHandler: ((inout PolygonAnnotation, InteractionContext) -> Void)? {
        get { gestureHandlers.value.dragChange }
        set { gestureHandlers.value.dragChange = newValue }
    }

    /// The handler receives the `annotation` and the `context` parameters of the gesture:
    /// - Use the `annotation` inout property to update properties of the annotation.
    /// - The `context` contains position of the gesture.
    public var dragEndHandler: ((inout PolygonAnnotation, InteractionContext) -> Void)? {
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
    private var gestureHandlers = AlwaysEqual(value: AnnotationGestureHandlers<PolygonAnnotation>())

    var layerProperties: [String: Any] {
        var properties: [String: Any] = [:]
        properties["fill-construct-bridge-guard-rail"] = fillConstructBridgeGuardRail
        properties["fill-sort-key"] = fillSortKey
        properties["fill-bridge-guard-rail-color"] = fillBridgeGuardRailColor?.rawValue
        properties["fill-bridge-guard-rail-color-use-theme"] = fillBridgeGuardRailColorUseTheme?.rawValue
        properties["fill-bridge-guard-rail-color-transition"] = fillBridgeGuardRailColorTransition?.asDictionary
        properties["fill-color"] = fillColor?.rawValue
        properties["fill-color-use-theme"] = fillColorUseTheme?.rawValue
        properties["fill-color-transition"] = fillColorTransition?.asDictionary
        properties["fill-opacity"] = fillOpacity
        properties["fill-opacity-transition"] = fillOpacityTransition?.asDictionary
        properties["fill-outline-color"] = fillOutlineColor?.rawValue
        properties["fill-outline-color-use-theme"] = fillOutlineColorUseTheme?.rawValue
        properties["fill-outline-color-transition"] = fillOutlineColorTransition?.asDictionary
        properties["fill-pattern"] = fillPattern
        properties["fill-tunnel-structure-color"] = fillTunnelStructureColor?.rawValue
        properties["fill-tunnel-structure-color-use-theme"] = fillTunnelStructureColorUseTheme?.rawValue
        properties["fill-tunnel-structure-color-transition"] = fillTunnelStructureColorTransition?.asDictionary
        properties["fill-z-offset"] = fillZOffset
        properties["fill-z-offset-transition"] = fillZOffsetTransition?.asDictionary
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
        polygon = GeometryType.projection(of: polygon, for: translation, in: map)
    }

    /// Create a polygon annotation with a `Polygon` and an optional identifier.
    public init(id: String = UUID().uuidString, polygon: Polygon, isSelected: Bool = false, isDraggable: Bool = false) {
        self.id = id
        self.polygon = polygon
        self.isSelected = isSelected
        self.isDraggable = isDraggable
    }

    // MARK: - Style Properties -

    /// Determines whether bridge guard rails are added for elevated roads.
    /// Default value: "true".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var fillConstructBridgeGuardRail: Bool?

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var fillSortKey: Double?

    /// This property defines whether the `fillBridgeGuardRailColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var fillBridgeGuardRailColorUseTheme: ColorUseTheme?

    /// Transition property for `fillBridgeGuardRailColor`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var fillBridgeGuardRailColorTransition: StyleTransition?

    /// The color of bridge guard rail.
    /// Default value: "rgba(241, 236, 225, 255)".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var fillBridgeGuardRailColor: StyleColor?

    /// This property defines whether the `fillColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var fillColorUseTheme: ColorUseTheme?

    /// Transition property for `fillColor`
    public var fillColorTransition: StyleTransition?

    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    /// Default value: "#000000".
    public var fillColor: StyleColor?

    /// Transition property for `fillOpacity`
    public var fillOpacityTransition: StyleTransition?

    /// The opacity of the entire fill layer. In contrast to the `fill-color`, this value will also affect the 1px stroke around the fill, if the stroke is used.
    /// Default value: 1. Value range: [0, 1]
    public var fillOpacity: Double?

    /// This property defines whether the `fillOutlineColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var fillOutlineColorUseTheme: ColorUseTheme?

    /// Transition property for `fillOutlineColor`
    public var fillOutlineColorTransition: StyleTransition?

    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    public var fillOutlineColor: StyleColor?

    /// Name of image in sprite to use for drawing image fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var fillPattern: String?

    /// This property defines whether the `fillTunnelStructureColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var fillTunnelStructureColorUseTheme: ColorUseTheme?

    /// Transition property for `fillTunnelStructureColor`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var fillTunnelStructureColorTransition: StyleTransition?

    /// The color of tunnel structures (tunnel entrance and tunnel walls).
    /// Default value: "rgba(241, 236, 225, 255)".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var fillTunnelStructureColor: StyleColor?

    /// Transition property for `fillZOffset`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var fillZOffsetTransition: StyleTransition?

    /// Specifies an uniform elevation in meters. Note: If the value is zero, the layer will be rendered on the ground. Non-zero values will elevate the layer from the sea level, which can cause it to be rendered below the terrain.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var fillZOffset: Double?

}

extension PolygonAnnotation {

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

extension PolygonAnnotation {
    /// Determines whether bridge guard rails are added for elevated roads.
    /// Default value: "true".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillConstructBridgeGuardRail(_ newValue: Bool) -> Self {
        with(self, setter(\.fillConstructBridgeGuardRail, newValue))
    }

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public func fillSortKey(_ newValue: Double) -> Self {
        with(self, setter(\.fillSortKey, newValue))
    }

    /// The color of bridge guard rail.
    /// Default value: "rgba(241, 236, 225, 255)".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillBridgeGuardRailColor(_ color: UIColor) -> Self {
        with(self, setter(\.fillBridgeGuardRailColor, StyleColor(color)))
    }

    /// This property defines whether the `fillBridgeGuardRailColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillBridgeGuardRailColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.fillBridgeGuardRailColorUseTheme, useTheme))
    }

    /// Transition property for `fillBridgeGuardRailColor`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillBridgeGuardRailColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillBridgeGuardRailColorTransition, transition))
    }

    /// The color of bridge guard rail.
    /// Default value: "rgba(241, 236, 225, 255)".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillBridgeGuardRailColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.fillBridgeGuardRailColor, newValue))
    }

    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    /// Default value: "#000000".
    public func fillColor(_ color: UIColor) -> Self {
        with(self, setter(\.fillColor, StyleColor(color)))
    }

    /// This property defines whether the `fillColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.fillColorUseTheme, useTheme))
    }

    /// Transition property for `fillColor`
    public func fillColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillColorTransition, transition))
    }

    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    /// Default value: "#000000".
    public func fillColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.fillColor, newValue))
    }

    /// Transition property for `fillOpacity`
    public func fillOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillOpacityTransition, transition))
    }

    /// The opacity of the entire fill layer. In contrast to the `fill-color`, this value will also affect the 1px stroke around the fill, if the stroke is used.
    /// Default value: 1. Value range: [0, 1]
    public func fillOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.fillOpacity, newValue))
    }

    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    public func fillOutlineColor(_ color: UIColor) -> Self {
        with(self, setter(\.fillOutlineColor, StyleColor(color)))
    }

    /// This property defines whether the `fillOutlineColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillOutlineColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.fillOutlineColorUseTheme, useTheme))
    }

    /// Transition property for `fillOutlineColor`
    public func fillOutlineColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillOutlineColorTransition, transition))
    }

    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    public func fillOutlineColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.fillOutlineColor, newValue))
    }

    /// Name of image in sprite to use for drawing image fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public func fillPattern(_ newValue: String) -> Self {
        with(self, setter(\.fillPattern, newValue))
    }

    /// The color of tunnel structures (tunnel entrance and tunnel walls).
    /// Default value: "rgba(241, 236, 225, 255)".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillTunnelStructureColor(_ color: UIColor) -> Self {
        with(self, setter(\.fillTunnelStructureColor, StyleColor(color)))
    }

    /// This property defines whether the `fillTunnelStructureColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillTunnelStructureColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.fillTunnelStructureColorUseTheme, useTheme))
    }

    /// Transition property for `fillTunnelStructureColor`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillTunnelStructureColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillTunnelStructureColorTransition, transition))
    }

    /// The color of tunnel structures (tunnel entrance and tunnel walls).
    /// Default value: "rgba(241, 236, 225, 255)".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillTunnelStructureColor(_ newValue: StyleColor) -> Self {
        with(self, setter(\.fillTunnelStructureColor, newValue))
    }

    /// Transition property for `fillZOffset`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillZOffsetTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillZOffsetTransition, transition))
    }

    /// Specifies an uniform elevation in meters. Note: If the value is zero, the layer will be rendered on the ground. Non-zero values will elevate the layer from the sea level, which can cause it to be rendered below the terrain.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func fillZOffset(_ newValue: Double) -> Self {
        with(self, setter(\.fillZOffset, newValue))
    }
}

extension PolygonAnnotation: MapContent, PrimitiveMapContent {

    func visit(_ node: MapContentNode) {
        PolygonAnnotationGroup { self }.visit(node)
    }
}

// End of generated file.
