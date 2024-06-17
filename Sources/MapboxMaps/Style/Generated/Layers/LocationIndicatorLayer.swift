// This file is generated.
import UIKit

/// Location Indicator layer.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-location-indicator)
public struct LocationIndicatorLayer: Layer, Equatable {

    // MARK: - Conformance to `Layer` protocol
    /// Unique layer name
    public var id: String

    /// Rendering type of this layer.
    public let type: LayerType

    /// The slot this layer is assigned to. If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    public var slot: Slot?

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    public var minZoom: Double?

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    public var maxZoom: Double?

    /// Whether this layer is displayed.
    public var visibility: Value<Visibility>

    /// Name of image in sprite to use as the middle of the location indicator.
    public var bearingImage: Value<ResolvedImage>?

    /// Name of image in sprite to use as the background of the location indicator.
    public var shadowImage: Value<ResolvedImage>?

    /// Name of image in sprite to use as the top of the location indicator.
    public var topImage: Value<ResolvedImage>?

    /// The accuracy, in meters, of the position source used to retrieve the position of the location indicator.
    /// Default value: 0.
    public var accuracyRadius: Value<Double>?

    /// Transition options for `accuracyRadius`.
    public var accuracyRadiusTransition: StyleTransition?

    /// The color for drawing the accuracy radius border. To adjust transparency, set the alpha component of the color accordingly.
    /// Default value: "#ffffff".
    public var accuracyRadiusBorderColor: Value<StyleColor>?

    /// Transition options for `accuracyRadiusBorderColor`.
    public var accuracyRadiusBorderColorTransition: StyleTransition?

    /// The color for drawing the accuracy radius, as a circle. To adjust transparency, set the alpha component of the color accordingly.
    /// Default value: "#ffffff".
    public var accuracyRadiusColor: Value<StyleColor>?

    /// Transition options for `accuracyRadiusColor`.
    public var accuracyRadiusColorTransition: StyleTransition?

    /// The bearing of the location indicator.
    /// Default value: 0.
    public var bearing: Value<Double>?

    /// Transition options for `bearing`.
    public var bearingTransition: StyleTransition?

    /// The size of the bearing image, as a scale factor applied to the size of the specified image.
    /// Default value: 1.
    public var bearingImageSize: Value<Double>?

    /// Transition options for `bearingImageSize`.
    public var bearingImageSizeTransition: StyleTransition?

    /// The color of the circle emphasizing the indicator. To adjust transparency, set the alpha component of the color accordingly.
    /// Default value: "#ffffff".
    public var emphasisCircleColor: Value<StyleColor>?

    /// Transition options for `emphasisCircleColor`.
    public var emphasisCircleColorTransition: StyleTransition?

    /// The radius, in pixel, of the circle emphasizing the indicator, drawn between the accuracy radius and the indicator shadow.
    /// Default value: 0.
    public var emphasisCircleRadius: Value<Double>?

    /// Transition options for `emphasisCircleRadius`.
    public var emphasisCircleRadiusTransition: StyleTransition?

    /// The displacement off the center of the top image and the shadow image when the pitch of the map is greater than 0. This helps producing a three-dimensional appearence.
    /// Default value: "0".
    public var imagePitchDisplacement: Value<Double>?

    /// An array of [latitude, longitude, altitude] position of the location indicator.
    /// Default value: [0,0,0].
    public var location: Value<[Double]>?

    /// Transition options for `location`.
    public var locationTransition: StyleTransition?

    /// The opacity of the entire location indicator layer.
    /// Default value: 1. Value range: [0, 1]
    public var locationIndicatorOpacity: Value<Double>?

    /// Transition options for `locationIndicatorOpacity`.
    public var locationIndicatorOpacityTransition: StyleTransition?

    /// The amount of the perspective compensation, between 0 and 1. A value of 1 produces a location indicator of constant width across the screen. A value of 0 makes it scale naturally according to the viewing projection.
    /// Default value: "0.85".
    public var perspectiveCompensation: Value<Double>?

    /// The size of the shadow image, as a scale factor applied to the size of the specified image.
    /// Default value: 1.
    public var shadowImageSize: Value<Double>?

    /// Transition options for `shadowImageSize`.
    public var shadowImageSizeTransition: StyleTransition?

    /// The size of the top image, as a scale factor applied to the size of the specified image.
    /// Default value: 1.
    public var topImageSize: Value<Double>?

    /// Transition options for `topImageSize`.
    public var topImageSizeTransition: StyleTransition?

    public init(id: String) {
        self.id = id
        self.type = LayerType.locationIndicator
        self.visibility = .constant(.visible)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(slot, forKey: .slot)
        try container.encodeIfPresent(minZoom, forKey: .minZoom)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encodeIfPresent(accuracyRadius, forKey: .accuracyRadius)
        try paintContainer.encodeIfPresent(accuracyRadiusTransition, forKey: .accuracyRadiusTransition)
        try paintContainer.encodeIfPresent(accuracyRadiusBorderColor, forKey: .accuracyRadiusBorderColor)
        try paintContainer.encodeIfPresent(accuracyRadiusBorderColorTransition, forKey: .accuracyRadiusBorderColorTransition)
        try paintContainer.encodeIfPresent(accuracyRadiusColor, forKey: .accuracyRadiusColor)
        try paintContainer.encodeIfPresent(accuracyRadiusColorTransition, forKey: .accuracyRadiusColorTransition)
        try paintContainer.encodeIfPresent(bearing, forKey: .bearing)
        try paintContainer.encodeIfPresent(bearingTransition, forKey: .bearingTransition)
        try paintContainer.encodeIfPresent(bearingImageSize, forKey: .bearingImageSize)
        try paintContainer.encodeIfPresent(bearingImageSizeTransition, forKey: .bearingImageSizeTransition)
        try paintContainer.encodeIfPresent(emphasisCircleColor, forKey: .emphasisCircleColor)
        try paintContainer.encodeIfPresent(emphasisCircleColorTransition, forKey: .emphasisCircleColorTransition)
        try paintContainer.encodeIfPresent(emphasisCircleRadius, forKey: .emphasisCircleRadius)
        try paintContainer.encodeIfPresent(emphasisCircleRadiusTransition, forKey: .emphasisCircleRadiusTransition)
        try paintContainer.encodeIfPresent(imagePitchDisplacement, forKey: .imagePitchDisplacement)
        try paintContainer.encodeIfPresent(location, forKey: .location)
        try paintContainer.encodeIfPresent(locationTransition, forKey: .locationTransition)
        try paintContainer.encodeIfPresent(locationIndicatorOpacity, forKey: .locationIndicatorOpacity)
        try paintContainer.encodeIfPresent(locationIndicatorOpacityTransition, forKey: .locationIndicatorOpacityTransition)
        try paintContainer.encodeIfPresent(perspectiveCompensation, forKey: .perspectiveCompensation)
        try paintContainer.encodeIfPresent(shadowImageSize, forKey: .shadowImageSize)
        try paintContainer.encodeIfPresent(shadowImageSizeTransition, forKey: .shadowImageSizeTransition)
        try paintContainer.encodeIfPresent(topImageSize, forKey: .topImageSize)
        try paintContainer.encodeIfPresent(topImageSizeTransition, forKey: .topImageSizeTransition)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encode(visibility, forKey: .visibility)
        try layoutContainer.encodeIfPresent(bearingImage, forKey: .bearingImage)
        try layoutContainer.encodeIfPresent(shadowImage, forKey: .shadowImage)
        try layoutContainer.encodeIfPresent(topImage, forKey: .topImage)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(LayerType.self, forKey: .type)
        slot = try container.decodeIfPresent(Slot.self, forKey: .slot)
        minZoom = try container.decodeIfPresent(Double.self, forKey: .minZoom)
        maxZoom = try container.decodeIfPresent(Double.self, forKey: .maxZoom)

        if let paintContainer = try? container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint) {
            accuracyRadius = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .accuracyRadius)
            accuracyRadiusTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .accuracyRadiusTransition)
            accuracyRadiusBorderColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .accuracyRadiusBorderColor)
            accuracyRadiusBorderColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .accuracyRadiusBorderColorTransition)
            accuracyRadiusColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .accuracyRadiusColor)
            accuracyRadiusColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .accuracyRadiusColorTransition)
            bearing = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .bearing)
            bearingTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .bearingTransition)
            bearingImageSize = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .bearingImageSize)
            bearingImageSizeTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .bearingImageSizeTransition)
            emphasisCircleColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .emphasisCircleColor)
            emphasisCircleColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .emphasisCircleColorTransition)
            emphasisCircleRadius = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .emphasisCircleRadius)
            emphasisCircleRadiusTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .emphasisCircleRadiusTransition)
            imagePitchDisplacement = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .imagePitchDisplacement)
            location = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .location)
            locationTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .locationTransition)
            locationIndicatorOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .locationIndicatorOpacity)
            locationIndicatorOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .locationIndicatorOpacityTransition)
            perspectiveCompensation = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .perspectiveCompensation)
            shadowImageSize = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .shadowImageSize)
            shadowImageSizeTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .shadowImageSizeTransition)
            topImageSize = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .topImageSize)
            topImageSizeTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .topImageSizeTransition)
        }

        var visibilityEncoded: Value<Visibility>?
        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibilityEncoded = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
            bearingImage = try layoutContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .bearingImage)
            shadowImage = try layoutContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .shadowImage)
            topImage = try layoutContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .topImage)
        }
        visibility = visibilityEncoded ?? .constant(.visible)
    }

    enum RootCodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case slot = "slot"
        case minZoom = "minzoom"
        case maxZoom = "maxzoom"
        case layout = "layout"
        case paint = "paint"
    }

    enum LayoutCodingKeys: String, CodingKey {
        case bearingImage = "bearing-image"
        case shadowImage = "shadow-image"
        case topImage = "top-image"
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case accuracyRadius = "accuracy-radius"
        case accuracyRadiusTransition = "accuracy-radius-transition"
        case accuracyRadiusBorderColor = "accuracy-radius-border-color"
        case accuracyRadiusBorderColorTransition = "accuracy-radius-border-color-transition"
        case accuracyRadiusColor = "accuracy-radius-color"
        case accuracyRadiusColorTransition = "accuracy-radius-color-transition"
        case bearing = "bearing"
        case bearingTransition = "bearing-transition"
        case bearingImageSize = "bearing-image-size"
        case bearingImageSizeTransition = "bearing-image-size-transition"
        case emphasisCircleColor = "emphasis-circle-color"
        case emphasisCircleColorTransition = "emphasis-circle-color-transition"
        case emphasisCircleRadius = "emphasis-circle-radius"
        case emphasisCircleRadiusTransition = "emphasis-circle-radius-transition"
        case imagePitchDisplacement = "image-pitch-displacement"
        case location = "location"
        case locationTransition = "location-transition"
        case locationIndicatorOpacity = "location-indicator-opacity"
        case locationIndicatorOpacityTransition = "location-indicator-opacity-transition"
        case perspectiveCompensation = "perspective-compensation"
        case shadowImageSize = "shadow-image-size"
        case shadowImageSizeTransition = "shadow-image-size-transition"
        case topImageSize = "top-image-size"
        case topImageSizeTransition = "top-image-size-transition"
    }
}

@_documentation(visibility: public)
@_spi(Experimental) extension LocationIndicatorLayer {

    /// The slot this layer is assigned to.
    /// If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    @_documentation(visibility: public)
    public func slot(_ newValue: Slot?) -> Self {
        with(self, setter(\.slot, newValue))
    }

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    @_documentation(visibility: public)
    public func minZoom(_ newValue: Double) -> Self {
        with(self, setter(\.minZoom, newValue))
    }

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    @_documentation(visibility: public)
    public func maxZoom(_ newValue: Double) -> Self {
        with(self, setter(\.maxZoom, newValue))
    }

    /// Name of image in sprite to use as the middle of the location indicator.
    @_documentation(visibility: public)
    public func bearingImage(_ constant: String) -> Self {
        with(self, setter(\.bearingImage, .constant(.name(constant))))
    }

    /// Name of image in sprite to use as the middle of the location indicator.
    @_documentation(visibility: public)
    public func bearingImage(_ expression: Expression) -> Self {
        with(self, setter(\.bearingImage, .expression(expression)))
    }

    /// Name of image in sprite to use as the background of the location indicator.
    @_documentation(visibility: public)
    public func shadowImage(_ constant: String) -> Self {
        with(self, setter(\.shadowImage, .constant(.name(constant))))
    }

    /// Name of image in sprite to use as the background of the location indicator.
    @_documentation(visibility: public)
    public func shadowImage(_ expression: Expression) -> Self {
        with(self, setter(\.shadowImage, .expression(expression)))
    }

    /// Name of image in sprite to use as the top of the location indicator.
    @_documentation(visibility: public)
    public func topImage(_ constant: String) -> Self {
        with(self, setter(\.topImage, .constant(.name(constant))))
    }

    /// Name of image in sprite to use as the top of the location indicator.
    @_documentation(visibility: public)
    public func topImage(_ expression: Expression) -> Self {
        with(self, setter(\.topImage, .expression(expression)))
    }

    /// The accuracy, in meters, of the position source used to retrieve the position of the location indicator.
    /// Default value: 0.
    @_documentation(visibility: public)
    public func accuracyRadius(_ constant: Double) -> Self {
        with(self, setter(\.accuracyRadius, .constant(constant)))
    }

    /// Transition property for `accuracyRadius`
    @_documentation(visibility: public)
    public func accuracyRadiusTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.accuracyRadiusTransition, transition))
    }

    /// The accuracy, in meters, of the position source used to retrieve the position of the location indicator.
    /// Default value: 0.
    @_documentation(visibility: public)
    public func accuracyRadius(_ expression: Expression) -> Self {
        with(self, setter(\.accuracyRadius, .expression(expression)))
    }

    /// The color for drawing the accuracy radius border. To adjust transparency, set the alpha component of the color accordingly.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    public func accuracyRadiusBorderColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.accuracyRadiusBorderColor, .constant(constant)))
    }

    /// The color for drawing the accuracy radius border. To adjust transparency, set the alpha component of the color accordingly.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    public func accuracyRadiusBorderColor(_ color: UIColor) -> Self {
        with(self, setter(\.accuracyRadiusBorderColor, .constant(StyleColor(color))))
    }

    /// Transition property for `accuracyRadiusBorderColor`
    @_documentation(visibility: public)
    public func accuracyRadiusBorderColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.accuracyRadiusBorderColorTransition, transition))
    }

    /// The color for drawing the accuracy radius border. To adjust transparency, set the alpha component of the color accordingly.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    public func accuracyRadiusBorderColor(_ expression: Expression) -> Self {
        with(self, setter(\.accuracyRadiusBorderColor, .expression(expression)))
    }

    /// The color for drawing the accuracy radius, as a circle. To adjust transparency, set the alpha component of the color accordingly.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    public func accuracyRadiusColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.accuracyRadiusColor, .constant(constant)))
    }

    /// The color for drawing the accuracy radius, as a circle. To adjust transparency, set the alpha component of the color accordingly.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    public func accuracyRadiusColor(_ color: UIColor) -> Self {
        with(self, setter(\.accuracyRadiusColor, .constant(StyleColor(color))))
    }

    /// Transition property for `accuracyRadiusColor`
    @_documentation(visibility: public)
    public func accuracyRadiusColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.accuracyRadiusColorTransition, transition))
    }

    /// The color for drawing the accuracy radius, as a circle. To adjust transparency, set the alpha component of the color accordingly.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    public func accuracyRadiusColor(_ expression: Expression) -> Self {
        with(self, setter(\.accuracyRadiusColor, .expression(expression)))
    }

    /// The bearing of the location indicator.
    /// Default value: 0.
    @_documentation(visibility: public)
    public func bearing(_ constant: Double) -> Self {
        with(self, setter(\.bearing, .constant(constant)))
    }

    /// Transition property for `bearing`
    @_documentation(visibility: public)
    public func bearingTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.bearingTransition, transition))
    }

    /// The bearing of the location indicator.
    /// Default value: 0.
    @_documentation(visibility: public)
    public func bearing(_ expression: Expression) -> Self {
        with(self, setter(\.bearing, .expression(expression)))
    }

    /// The size of the bearing image, as a scale factor applied to the size of the specified image.
    /// Default value: 1.
    @_documentation(visibility: public)
    public func bearingImageSize(_ constant: Double) -> Self {
        with(self, setter(\.bearingImageSize, .constant(constant)))
    }

    /// Transition property for `bearingImageSize`
    @_documentation(visibility: public)
    public func bearingImageSizeTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.bearingImageSizeTransition, transition))
    }

    /// The size of the bearing image, as a scale factor applied to the size of the specified image.
    /// Default value: 1.
    @_documentation(visibility: public)
    public func bearingImageSize(_ expression: Expression) -> Self {
        with(self, setter(\.bearingImageSize, .expression(expression)))
    }

    /// The color of the circle emphasizing the indicator. To adjust transparency, set the alpha component of the color accordingly.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    public func emphasisCircleColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.emphasisCircleColor, .constant(constant)))
    }

    /// The color of the circle emphasizing the indicator. To adjust transparency, set the alpha component of the color accordingly.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    public func emphasisCircleColor(_ color: UIColor) -> Self {
        with(self, setter(\.emphasisCircleColor, .constant(StyleColor(color))))
    }

    /// Transition property for `emphasisCircleColor`
    @_documentation(visibility: public)
    public func emphasisCircleColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.emphasisCircleColorTransition, transition))
    }

    /// The color of the circle emphasizing the indicator. To adjust transparency, set the alpha component of the color accordingly.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    public func emphasisCircleColor(_ expression: Expression) -> Self {
        with(self, setter(\.emphasisCircleColor, .expression(expression)))
    }

    /// The radius, in pixel, of the circle emphasizing the indicator, drawn between the accuracy radius and the indicator shadow.
    /// Default value: 0.
    @_documentation(visibility: public)
    public func emphasisCircleRadius(_ constant: Double) -> Self {
        with(self, setter(\.emphasisCircleRadius, .constant(constant)))
    }

    /// Transition property for `emphasisCircleRadius`
    @_documentation(visibility: public)
    public func emphasisCircleRadiusTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.emphasisCircleRadiusTransition, transition))
    }

    /// The radius, in pixel, of the circle emphasizing the indicator, drawn between the accuracy radius and the indicator shadow.
    /// Default value: 0.
    @_documentation(visibility: public)
    public func emphasisCircleRadius(_ expression: Expression) -> Self {
        with(self, setter(\.emphasisCircleRadius, .expression(expression)))
    }

    /// The displacement off the center of the top image and the shadow image when the pitch of the map is greater than 0. This helps producing a three-dimensional appearence.
    /// Default value: "0".
    @_documentation(visibility: public)
    public func imagePitchDisplacement(_ constant: Double) -> Self {
        with(self, setter(\.imagePitchDisplacement, .constant(constant)))
    }

    /// The displacement off the center of the top image and the shadow image when the pitch of the map is greater than 0. This helps producing a three-dimensional appearence.
    /// Default value: "0".
    @_documentation(visibility: public)
    public func imagePitchDisplacement(_ expression: Expression) -> Self {
        with(self, setter(\.imagePitchDisplacement, .expression(expression)))
    }

    /// An array of [latitude, longitude, altitude] position of the location indicator.
    /// Default value: [0,0,0].
    @_documentation(visibility: public)
    public func location(_ coordinate: CLLocationCoordinate2D) -> Self {
        with(self, setter(\.location, .constant([coordinate.latitude, coordinate.longitude])))
    }

    /// Transition property for `location`
    @_documentation(visibility: public)
    public func locationTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.locationTransition, transition))
    }

    /// An array of [latitude, longitude, altitude] position of the location indicator.
    /// Default value: [0,0,0].
    @_documentation(visibility: public)
    public func location(_ expression: Expression) -> Self {
        with(self, setter(\.location, .expression(expression)))
    }

    /// The opacity of the entire location indicator layer.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    public func locationIndicatorOpacity(_ constant: Double) -> Self {
        with(self, setter(\.locationIndicatorOpacity, .constant(constant)))
    }

    /// Transition property for `locationIndicatorOpacity`
    @_documentation(visibility: public)
    public func locationIndicatorOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.locationIndicatorOpacityTransition, transition))
    }

    /// The opacity of the entire location indicator layer.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    public func locationIndicatorOpacity(_ expression: Expression) -> Self {
        with(self, setter(\.locationIndicatorOpacity, .expression(expression)))
    }

    /// The amount of the perspective compensation, between 0 and 1. A value of 1 produces a location indicator of constant width across the screen. A value of 0 makes it scale naturally according to the viewing projection.
    /// Default value: "0.85".
    @_documentation(visibility: public)
    public func perspectiveCompensation(_ constant: Double) -> Self {
        with(self, setter(\.perspectiveCompensation, .constant(constant)))
    }

    /// The amount of the perspective compensation, between 0 and 1. A value of 1 produces a location indicator of constant width across the screen. A value of 0 makes it scale naturally according to the viewing projection.
    /// Default value: "0.85".
    @_documentation(visibility: public)
    public func perspectiveCompensation(_ expression: Expression) -> Self {
        with(self, setter(\.perspectiveCompensation, .expression(expression)))
    }

    /// The size of the shadow image, as a scale factor applied to the size of the specified image.
    /// Default value: 1.
    @_documentation(visibility: public)
    public func shadowImageSize(_ constant: Double) -> Self {
        with(self, setter(\.shadowImageSize, .constant(constant)))
    }

    /// Transition property for `shadowImageSize`
    @_documentation(visibility: public)
    public func shadowImageSizeTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.shadowImageSizeTransition, transition))
    }

    /// The size of the shadow image, as a scale factor applied to the size of the specified image.
    /// Default value: 1.
    @_documentation(visibility: public)
    public func shadowImageSize(_ expression: Expression) -> Self {
        with(self, setter(\.shadowImageSize, .expression(expression)))
    }

    /// The size of the top image, as a scale factor applied to the size of the specified image.
    /// Default value: 1.
    @_documentation(visibility: public)
    public func topImageSize(_ constant: Double) -> Self {
        with(self, setter(\.topImageSize, .constant(constant)))
    }

    /// Transition property for `topImageSize`
    @_documentation(visibility: public)
    public func topImageSizeTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.topImageSizeTransition, transition))
    }

    /// The size of the top image, as a scale factor applied to the size of the specified image.
    /// Default value: 1.
    @_documentation(visibility: public)
    public func topImageSize(_ expression: Expression) -> Self {
        with(self, setter(\.topImageSize, .expression(expression)))
    }
}

@available(iOS 13.0, *)
@_spi(Experimental)
extension LocationIndicatorLayer: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

// End of generated file.
