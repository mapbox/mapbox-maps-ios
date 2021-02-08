// This file is generated.

import Foundation
import MapboxCoreMaps
import MapboxCommon

/**
 * Raster map textures such as satellite imagery.
 *
 * @see <a href="https://www.mapbox.com/mapbox-gl-style-spec/#layers-raster">The online documentation</a>
 *
 */
public struct RasterLayer: Layer {

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
    public var layout: RasterLayer.Layout?

    public struct Layout: Codable {

      /// Whether this layer is displayed.
      public var visibility: Visibility?
      
      public init() {
        self.visibility = .visible
      }

       
      enum CodingKeys: String, CodingKey {
        case visibility = "visibility"
      }
    }

    /// Changes to a paint property are cheap and happen synchronously.
    public var paint: RasterLayer.Paint?
  
    public struct Paint: Codable {

      public init() {}
          
      /// Increase or reduce the brightness of the image. The value is the maximum brightness.
      public var rasterBrightnessMax: Value<Double>?
      
      /// Transition options for `rasterBrightnessMax`.
      public var rasterBrightnessMaxTransition: StyleTransition?
            
      /// Increase or reduce the brightness of the image. The value is the minimum brightness.
      public var rasterBrightnessMin: Value<Double>?
      
      /// Transition options for `rasterBrightnessMin`.
      public var rasterBrightnessMinTransition: StyleTransition?
            
      /// Increase or reduce the contrast of the image.
      public var rasterContrast: Value<Double>?
      
      /// Transition options for `rasterContrast`.
      public var rasterContrastTransition: StyleTransition?
            
      /// Fade duration when a new tile is added.
      public var rasterFadeDuration: Value<Double>?
            
      /// Rotates hues around the color wheel.
      public var rasterHueRotate: Value<Double>?
      
      /// Transition options for `rasterHueRotate`.
      public var rasterHueRotateTransition: StyleTransition?
            
      /// The opacity at which the image will be drawn.
      public var rasterOpacity: Value<Double>?
      
      /// Transition options for `rasterOpacity`.
      public var rasterOpacityTransition: StyleTransition?
            
      /// The resampling/interpolation method to use for overscaling, also known as texture magnification filter
      public var rasterResampling: RasterResampling?
            
      /// Increase or reduce the saturation of the image.
      public var rasterSaturation: Value<Double>?
      
      /// Transition options for `rasterSaturation`.
      public var rasterSaturationTransition: StyleTransition?
      

      enum CodingKeys: String, CodingKey {
        case rasterBrightnessMax = "raster-brightness-max"
        case rasterBrightnessMaxTransition = "raster-brightness-max-transition"
        case rasterBrightnessMin = "raster-brightness-min"
        case rasterBrightnessMinTransition = "raster-brightness-min-transition"
        case rasterContrast = "raster-contrast"
        case rasterContrastTransition = "raster-contrast-transition"
        case rasterFadeDuration = "raster-fade-duration"
        case rasterHueRotate = "raster-hue-rotate"
        case rasterHueRotateTransition = "raster-hue-rotate-transition"
        case rasterOpacity = "raster-opacity"
        case rasterOpacityTransition = "raster-opacity-transition"
        case rasterResampling = "raster-resampling"
        case rasterSaturation = "raster-saturation"
        case rasterSaturationTransition = "raster-saturation-transition"
      }
    }

    public init(id: String) {
      self.id = id
      self.type = LayerType.raster
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