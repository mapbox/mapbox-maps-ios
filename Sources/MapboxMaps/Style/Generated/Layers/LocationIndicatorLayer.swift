// This file is generated.

import Foundation
import MapboxCoreMaps
import MapboxCommon

/**
 * Location Indicator layer.
 *
 * @see <a href="https://www.mapbox.com/mapbox-gl-style-spec/#layers-location-indicator">The online documentation</a>
 *
 */
public struct LocationIndicatorLayer: Layer {

    // MARK: - Conformance to `Layer` protocol
    public var id: String
    public var type: LayerType
    public var filter: Expression?
    public var source: String?
    public var sourceLayer: String?
    public var minZoom: Double?
    public var maxZoom: Double?

    /// Layer layout properties are applied early in the rendering process and define how data for that layer is passed to the GPU.
    /// Changes to a layout property require an asynchronous "layout" step.
    public var layout: LocationIndicatorLayer.Layout?

    public struct Layout: Codable {

      /// Whether this layer is displayed.
      public var visibility: Value<Visibility>?
      
      public init() {
        self.visibility = .constant(.visible)
      }

            
      /// Name of image in sprite to use as the middle of the location indicator.
      public var bearingImage: Value<ResolvedImage>?
            
      /// Name of image in sprite to use as the background of the location indicator.
      public var shadowImage: Value<ResolvedImage>?
            
      /// Name of image in sprite to use as the top of the location indicator.
      public var topImage: Value<ResolvedImage>?
       
      enum CodingKeys: String, CodingKey {
        case bearingImage = "bearing-image"
        case shadowImage = "shadow-image"
        case topImage = "top-image"
        case visibility = "visibility"
      }
    }

    /// Changes to a paint property are cheap and happen synchronously.
    public var paint: LocationIndicatorLayer.Paint?
  
    public struct Paint: Codable {

      public init() {}
          
      /// The accuracy, in meters, of the position source used to retrieve the position of the location indicator.
      public var accuracyRadius: Value<Double>?
      
      /// Transition options for `accuracyRadius`.
      public var accuracyRadiusTransition: StyleTransition?
            
      /// The color for drawing the accuracy radius border. To adjust transparency, set the alpha component of the color accordingly.
      public var accuracyRadiusBorderColor: Value<ColorRepresentable>?
      
      /// Transition options for `accuracyRadiusBorderColor`.
      public var accuracyRadiusBorderColorTransition: StyleTransition?
            
      /// The color for drawing the accuracy radius, as a circle. To adjust transparency, set the alpha component of the color accordingly.
      public var accuracyRadiusColor: Value<ColorRepresentable>?
      
      /// Transition options for `accuracyRadiusColor`.
      public var accuracyRadiusColorTransition: StyleTransition?
            
      /// The bearing of the location indicator.
      public var bearing: Value<Double>?
            
      /// The size of the bearing image, as a scale factor applied to the size of the specified image.
      public var bearingImageSize: Value<Double>?
      
      /// Transition options for `bearingImageSize`.
      public var bearingImageSizeTransition: StyleTransition?
            
      /// The color of the circle emphasizing the indicator. To adjust transparency, set the alpha component of the color accordingly.
      public var emphasisCircleColor: Value<ColorRepresentable>?
      
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
      
      /// The bearing transition of the location indicator.
      public var bearingTransition: StyleTransition?
      
      enum CodingKeys: String, CodingKey {
        case accuracyRadius = "accuracy-radius"
        case accuracyRadiusTransition = "accuracy-radius-transition"
        case accuracyRadiusBorderColor = "accuracy-radius-border-color"
        case accuracyRadiusBorderColorTransition = "accuracy-radius-border-color-transition"
        case accuracyRadiusColor = "accuracy-radius-color"
        case accuracyRadiusColorTransition = "accuracy-radius-color-transition"
        case bearing = "bearing"
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
        case bearingTransition = "bearing-transition"
      }
    }

    public init(id: String) {
      self.id = id
      self.type = LayerType.locationIndicator
      self.paint = Paint()
      self.layout = Layout()
    }

    enum CodingKeys: String, CodingKey {
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
}

// End of generated file.