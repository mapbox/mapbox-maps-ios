// This file is generated.

import Foundation
import MapboxCoreMaps
import MapboxCommon

/**
 * A heatmap.
 *
 * @see <a href="https://www.mapbox.com/mapbox-gl-style-spec/#layers-heatmap">The online documentation</a>
 *
 */
public struct HeatmapLayer: Layer {

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
    public var layout: HeatmapLayer.Layout?

    public struct Layout: Codable {

      /// Whether this layer is displayed.
      public var visibility: Value<Visibility>?
      
      public init() {
        self.visibility = .constant(.visible)
      }

       
      enum CodingKeys: String, CodingKey {
        case visibility = "visibility"
      }
    }

    /// Changes to a paint property are cheap and happen synchronously.
    public var paint: HeatmapLayer.Paint?
  
    public struct Paint: Codable {

      public init() {}
          
      /// Defines the color of each pixel based on its density value in a heatmap.  Should be an expression that uses `["heatmap-density"]` as input.
      public var heatmapColor: Value<ColorRepresentable>?
            
      /// Similar to `heatmap-weight` but controls the intensity of the heatmap globally. Primarily used for adjusting the heatmap based on zoom level.
      public var heatmapIntensity: Value<Double>?
      
      /// Transition options for `heatmapIntensity`.
      public var heatmapIntensityTransition: StyleTransition?
            
      /// The global opacity at which the heatmap layer will be drawn.
      public var heatmapOpacity: Value<Double>?
      
      /// Transition options for `heatmapOpacity`.
      public var heatmapOpacityTransition: StyleTransition?
            
      /// Radius of influence of one heatmap point in pixels. Increasing the value makes the heatmap smoother, but less detailed.
      public var heatmapRadius: Value<Double>?
      
      /// Transition options for `heatmapRadius`.
      public var heatmapRadiusTransition: StyleTransition?
            
      /// A measure of how much an individual point contributes to the heatmap. A value of 10 would be equivalent to having 10 points of weight 1 in the same spot. Especially useful when combined with clustering.
      public var heatmapWeight: Value<Double>?
      

      enum CodingKeys: String, CodingKey {
        case heatmapColor = "heatmap-color"
        case heatmapIntensity = "heatmap-intensity"
        case heatmapIntensityTransition = "heatmap-intensity-transition"
        case heatmapOpacity = "heatmap-opacity"
        case heatmapOpacityTransition = "heatmap-opacity-transition"
        case heatmapRadius = "heatmap-radius"
        case heatmapRadiusTransition = "heatmap-radius-transition"
        case heatmapWeight = "heatmap-weight"
      }
    }

    public init(id: String) {
      self.id = id
      self.type = LayerType.heatmap
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