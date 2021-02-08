// This file is generated.

import Foundation
import MapboxCoreMaps
import MapboxCommon

/**
 * The background color or pattern of the map.
 *
 * @see <a href="https://www.mapbox.com/mapbox-gl-style-spec/#layers-background">The online documentation</a>
 *
 */
public struct BackgroundLayer: Layer {

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
    public var layout: BackgroundLayer.Layout?

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
    public var paint: BackgroundLayer.Paint?
  
    public struct Paint: Codable {

      public init() {}
          
      /// The color with which the background will be drawn.
      public var backgroundColor: Value<ColorRepresentable>?
      
      /// Transition options for `backgroundColor`.
      public var backgroundColorTransition: StyleTransition?
            
      /// The opacity at which the background will be drawn.
      public var backgroundOpacity: Value<Double>?
      
      /// Transition options for `backgroundOpacity`.
      public var backgroundOpacityTransition: StyleTransition?
            
      /// Name of image in sprite to use for drawing an image background. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
      public var backgroundPattern: Value<ResolvedImage>?
      
      /// Transition options for `backgroundPattern`.
      public var backgroundPatternTransition: StyleTransition?
      

      enum CodingKeys: String, CodingKey {
        case backgroundColor = "background-color"
        case backgroundColorTransition = "background-color-transition"
        case backgroundOpacity = "background-opacity"
        case backgroundOpacityTransition = "background-opacity-transition"
        case backgroundPattern = "background-pattern"
        case backgroundPatternTransition = "background-pattern-transition"
      }
    }

    public init(id: String) {
      self.id = id
      self.type = LayerType.background
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