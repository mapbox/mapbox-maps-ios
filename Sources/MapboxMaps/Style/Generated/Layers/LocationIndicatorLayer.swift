// This file is generated.
import Foundation

/// Location Indicator layer.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-location-indicator)
public struct LocationIndicatorLayer: Layer {

    // MARK: - Conformance to `Layer` protocol
    public var id: String
    public let type: LayerType
    public var filter: Expression?
    public var source: String?
    public var sourceLayer: String?
    public var minZoom: Double?
    public var maxZoom: Double?

    /// Whether this layer is displayed.
    public var visibility: Value<Visibility>?

    /// Name of image in sprite to use as the middle of the location indicator.
    public var bearingImage: Value<ResolvedImage>?

    /// Name of image in sprite to use as the background of the location indicator.
    public var shadowImage: Value<ResolvedImage>?

    /// Name of image in sprite to use as the top of the location indicator.
    public var topImage: Value<ResolvedImage>?

    /// The accuracy, in meters, of the position source used to retrieve the position of the location indicator.
    public var accuracyRadius: Value<Double>?

    /// Transition options for `accuracyRadius`.
    public var accuracyRadiusTransition: StyleTransition?

    /// The color for drawing the accuracy radius border. To adjust transparency, set the alpha component of the color accordingly.
    public var accuracyRadiusBorderColor: Value<StyleColor>?

    /// Transition options for `accuracyRadiusBorderColor`.
    public var accuracyRadiusBorderColorTransition: StyleTransition?

    /// The color for drawing the accuracy radius, as a circle. To adjust transparency, set the alpha component of the color accordingly.
    public var accuracyRadiusColor: Value<StyleColor>?

    /// Transition options for `accuracyRadiusColor`.
    public var accuracyRadiusColorTransition: StyleTransition?

    /// The bearing of the location indicator.
    public var bearing: Value<Double>?

    /// Transition options for `bearing`.
    public var bearingTransition: StyleTransition?

    /// The size of the bearing image, as a scale factor applied to the size of the specified image.
    public var bearingImageSize: Value<Double>?

    /// Transition options for `bearingImageSize`.
    public var bearingImageSizeTransition: StyleTransition?

    /// The color of the circle emphasizing the indicator. To adjust transparency, set the alpha component of the color accordingly.
    public var emphasisCircleColor: Value<StyleColor>?

    /// Transition options for `emphasisCircleColor`.
    public var emphasisCircleColorTransition: StyleTransition?

    /// The radius, in pixel, of the circle emphasizing the indicator, drawn between the accuracy radius and the indicator shadow.
    public var emphasisCircleRadius: Value<Double>?

    /// Transition options for `emphasisCircleRadius`.
    public var emphasisCircleRadiusTransition: StyleTransition?

    /// The displacement off the center of the top image and the shadow image when the pitch of the map is greater than 0. This helps producing a three-dimensional appearence.
    public var imagePitchDisplacement: Value<Double>?

    /// An array of [latitude, longitude, altitude] position of the location indicator.
    public var location: Value<[Double]>?

    /// Transition options for `location`.
    public var locationTransition: StyleTransition?

    /// The amount of the perspective compensation, between 0 and 1. A value of 1 produces a location indicator of constant width across the screen. A value of 0 makes it scale naturally according to the viewing projection.
    public var perspectiveCompensation: Value<Double>?

    /// The size of the shadow image, as a scale factor applied to the size of the specified image.
    public var shadowImageSize: Value<Double>?

    /// Transition options for `shadowImageSize`.
    public var shadowImageSizeTransition: StyleTransition?

    /// The size of the top image, as a scale factor applied to the size of the specified image.
    public var topImageSize: Value<Double>?

    /// Transition options for `topImageSize`.
    public var topImageSizeTransition: StyleTransition?

    public init(id: String) {
        self.id = id
        self.type = LayerType.locationIndicator
        self.visibility = .constant(.visible)
    }

    public func encode(to encoder: Encoder) throws {
        let nilEncoder = NilEncoder(userInfo: encoder.userInfo)

        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try nilEncoder.encode(filter, forKey: .filter, to: &container)
        try nilEncoder.encode(source, forKey: .source, to: &container)
        try nilEncoder.encode(sourceLayer, forKey: .sourceLayer, to: &container)
        try nilEncoder.encode(minZoom, forKey: .minZoom, to: &container)
        try nilEncoder.encode(maxZoom, forKey: .maxZoom, to: &container)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try nilEncoder.encode(accuracyRadius, forKey: .accuracyRadius, to: &paintContainer)
        try nilEncoder.encode(accuracyRadiusTransition, forKey: .accuracyRadiusTransition, to: &paintContainer)
        try nilEncoder.encode(accuracyRadiusBorderColor, forKey: .accuracyRadiusBorderColor, to: &paintContainer)
        try nilEncoder.encode(accuracyRadiusBorderColorTransition, forKey: .accuracyRadiusBorderColorTransition, to: &paintContainer)
        try nilEncoder.encode(accuracyRadiusColor, forKey: .accuracyRadiusColor, to: &paintContainer)
        try nilEncoder.encode(accuracyRadiusColorTransition, forKey: .accuracyRadiusColorTransition, to: &paintContainer)
        try nilEncoder.encode(bearing, forKey: .bearing, to: &paintContainer)
        try nilEncoder.encode(bearingTransition, forKey: .bearingTransition, to: &paintContainer)
        try nilEncoder.encode(bearingImageSize, forKey: .bearingImageSize, to: &paintContainer)
        try nilEncoder.encode(bearingImageSizeTransition, forKey: .bearingImageSizeTransition, to: &paintContainer)
        try nilEncoder.encode(emphasisCircleColor, forKey: .emphasisCircleColor, to: &paintContainer)
        try nilEncoder.encode(emphasisCircleColorTransition, forKey: .emphasisCircleColorTransition, to: &paintContainer)
        try nilEncoder.encode(emphasisCircleRadius, forKey: .emphasisCircleRadius, to: &paintContainer)
        try nilEncoder.encode(emphasisCircleRadiusTransition, forKey: .emphasisCircleRadiusTransition, to: &paintContainer)
        try nilEncoder.encode(imagePitchDisplacement, forKey: .imagePitchDisplacement, to: &paintContainer)
        try nilEncoder.encode(location, forKey: .location, to: &paintContainer)
        try nilEncoder.encode(locationTransition, forKey: .locationTransition, to: &paintContainer)
        try nilEncoder.encode(perspectiveCompensation, forKey: .perspectiveCompensation, to: &paintContainer)
        try nilEncoder.encode(shadowImageSize, forKey: .shadowImageSize, to: &paintContainer)
        try nilEncoder.encode(shadowImageSizeTransition, forKey: .shadowImageSizeTransition, to: &paintContainer)
        try nilEncoder.encode(topImageSize, forKey: .topImageSize, to: &paintContainer)
        try nilEncoder.encode(topImageSizeTransition, forKey: .topImageSizeTransition, to: &paintContainer)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try nilEncoder.encode(visibility, forKey: .visibility, to: &layoutContainer)
        try nilEncoder.encode(bearingImage, forKey: .bearingImage, to: &layoutContainer)
        try nilEncoder.encode(shadowImage, forKey: .shadowImage, to: &layoutContainer)
        try nilEncoder.encode(topImage, forKey: .topImage, to: &layoutContainer)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(LayerType.self, forKey: .type)
        filter = try container.decodeIfPresent(Expression.self, forKey: .filter)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        sourceLayer = try container.decodeIfPresent(String.self, forKey: .sourceLayer)
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
            perspectiveCompensation = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .perspectiveCompensation)
            shadowImageSize = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .shadowImageSize)
            shadowImageSizeTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .shadowImageSizeTransition)
            topImageSize = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .topImageSize)
            topImageSizeTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .topImageSizeTransition)
        }

        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibility = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
            bearingImage = try layoutContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .bearingImage)
            shadowImage = try layoutContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .shadowImage)
            topImage = try layoutContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .topImage)
        }
    }

    enum RootCodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case filter = "filter"
        case source = "source"
        case sourceLayer = "source-layer"
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
        case perspectiveCompensation = "perspective-compensation"
        case shadowImageSize = "shadow-image-size"
        case shadowImageSizeTransition = "shadow-image-size-transition"
        case topImageSize = "top-image-size"
        case topImageSizeTransition = "top-image-size-transition"
    }
}

// End of generated file.
