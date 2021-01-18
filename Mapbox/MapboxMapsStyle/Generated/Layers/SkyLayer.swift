// This file is generated.

import Foundation
import MapboxCoreMaps
import MapboxCommon

/**
 * A spherical dome around the map that is always rendered behind all other layers.
 *
 * @see <a href="https://www.mapbox.com/mapbox-gl-style-spec/#layers-sky">The online documentation</a>
 *
 */
public struct SkyLayer: Layer {

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
    public var layout: SkyLayer.Layout?

    public struct Layout: Codable {

      /// Whether this layer is displayed.
      public var visibility: Visibility
      
      public init() {
        self.visibility = .visible
      }

       
      enum CodingKeys: String, CodingKey {
        case visibility = "visibility"
      }
    }

    /// Changes to a paint property are cheap and happen synchronously.
    public var paint: SkyLayer.Paint?
  
    public struct Paint: Codable {

      public init() {}
          
      /// A color used to tweak the main atmospheric scattering coefficients. Using white applies the default coefficients giving the natural blue color to the atmosphere. This color affects how heavily the corresponding wavelength is represented during scattering. The alpha channel describes the density of the atmosphere, with 1 maximum density and 0 no density.
      public var skyAtmosphereColor: Value<ColorRepresentable>?
            
      /// A color applied to the atmosphere sun halo. The alpha channel describes how strongly the sun halo is represented in an atmosphere sky layer.
      public var skyAtmosphereHaloColor: Value<ColorRepresentable>?
            
      /// Position of the sun center [a azimuthal angle, p polar angle]. The azimuthal angle indicates the position of the sun relative to 0&#xB0; north, where degrees proceed clockwise. The polar angle indicates the height of the sun, where 0&#xB0; is directly above, at zenith, and 90&#xB0; at the horizon. When this property is ommitted, the sun center is directly inherited from the light position.
      public var skyAtmosphereSun: Value<[Double]>?
            
      /// Intensity of the sun as a light source in the atmosphere (on a scale from 0 to a 100). Setting higher values will brighten up the sky.
      public var skyAtmosphereSunIntensity: Value<Double>?
            
      /// Defines a radial color gradient with which to color the sky. The color values can be interpolated with an expression using `sky-radial-progress`. The range [0, 1] for the interpolant covers a radial distance (in degrees) of [0, `sky-gradient-radius`] centered at the position specified by `sky-gradient-center`.
      public var skyGradient: Value<String>?
            
      /// Position of the gradient center [a azimuthal angle, p polar angle]. The azimuthal angle indicates the position of the gradient center relative to 0&#xB0; north, where degrees proceed clockwise. The polar angle indicates the height of the gradient center, where 0&#xB0; is directly above, at zenith, and 90&#xB0; at the horizon.
      public var skyGradientCenter: Value<[Double]>?
            
      /// The angular distance (measured in degrees) from `sky-gradient-center` up to which the gradient extends. A value of 180 causes the gradient to wrap around to the opposite direction from `sky-gradient-center`.
      public var skyGradientRadius: Value<Double>?
            
      /// The opacity of the entire sky layer.
      public var skyOpacity: Value<Double>?
      
      /// Transition options for `skyOpacity`.
      public var skyOpacityTransition: StyleTransition?
            
      /// The type of the sky
      public var skyType: SkyType?
      

      enum CodingKeys: String, CodingKey {
        case skyAtmosphereColor = "sky-atmosphere-color"
        case skyAtmosphereHaloColor = "sky-atmosphere-halo-color"
        case skyAtmosphereSun = "sky-atmosphere-sun"
        case skyAtmosphereSunIntensity = "sky-atmosphere-sun-intensity"
        case skyGradient = "sky-gradient"
        case skyGradientCenter = "sky-gradient-center"
        case skyGradientRadius = "sky-gradient-radius"
        case skyOpacity = "sky-opacity"
        case skyOpacityTransition = "sky-opacity-transition"
        case skyType = "sky-type"
      }
    }

    public init(id: String) {
      self.id = id
      self.type = LayerType.sky
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