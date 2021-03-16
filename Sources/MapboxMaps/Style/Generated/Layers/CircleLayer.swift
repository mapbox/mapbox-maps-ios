// This file is generated.

import Foundation
import MapboxCoreMaps
import MapboxCommon

/**
 * A filled circle.
 *
 * @see <a href="https://www.mapbox.com/mapbox-gl-style-spec/#layers-circle">The online documentation</a>
 *
 */
public struct CircleLayer: Layer {

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
    public var layout: CircleLayer.Layout?

    public struct Layout: Codable {

      /// Whether this layer is displayed.
      public var visibility: Value<Visibility>?
      
      public init() {
        self.visibility = .constant(.visible)
      }

            
      /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
      public var circleSortKey: Value<Double>?
       
      enum CodingKeys: String, CodingKey {
        case circleSortKey = "circle-sort-key"
        case visibility = "visibility"
      }
    }

    /// Changes to a paint property are cheap and happen synchronously.
    public var paint: CircleLayer.Paint?
  
    public struct Paint: Codable {

      public init() {}
          
      /// Amount to blur the circle. 1 blurs the circle such that only the centerpoint is full opacity.
      public var circleBlur: Value<Double>?
      
      /// Transition options for `circleBlur`.
      public var circleBlurTransition: StyleTransition?
            
      /// The fill color of the circle.
      public var circleColor: Value<ColorRepresentable>?
      
      /// Transition options for `circleColor`.
      public var circleColorTransition: StyleTransition?
            
      /// The opacity at which the circle will be drawn.
      public var circleOpacity: Value<Double>?
      
      /// Transition options for `circleOpacity`.
      public var circleOpacityTransition: StyleTransition?
            
      /// Orientation of circle when map is pitched.
      public var circlePitchAlignment: Value<CirclePitchAlignment>?
            
      /// Controls the scaling behavior of the circle when the map is pitched.
      public var circlePitchScale: Value<CirclePitchScale>?
            
      /// Circle radius.
      public var circleRadius: Value<Double>?
      
      /// Transition options for `circleRadius`.
      public var circleRadiusTransition: StyleTransition?
            
      /// The stroke color of the circle.
      public var circleStrokeColor: Value<ColorRepresentable>?
      
      /// Transition options for `circleStrokeColor`.
      public var circleStrokeColorTransition: StyleTransition?
            
      /// The opacity of the circle's stroke.
      public var circleStrokeOpacity: Value<Double>?
      
      /// Transition options for `circleStrokeOpacity`.
      public var circleStrokeOpacityTransition: StyleTransition?
            
      /// The width of the circle's stroke. Strokes are placed outside of the `circle-radius`.
      public var circleStrokeWidth: Value<Double>?
      
      /// Transition options for `circleStrokeWidth`.
      public var circleStrokeWidthTransition: StyleTransition?
            
      /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
      public var circleTranslate: Value<[Double]>?
      
      /// Transition options for `circleTranslate`.
      public var circleTranslateTransition: StyleTransition?
            
      /// Controls the frame of reference for `circle-translate`.
      public var circleTranslateAnchor: Value<CircleTranslateAnchor>?
      

      enum CodingKeys: String, CodingKey {
        case circleBlur = "circle-blur"
        case circleBlurTransition = "circle-blur-transition"
        case circleColor = "circle-color"
        case circleColorTransition = "circle-color-transition"
        case circleOpacity = "circle-opacity"
        case circleOpacityTransition = "circle-opacity-transition"
        case circlePitchAlignment = "circle-pitch-alignment"
        case circlePitchScale = "circle-pitch-scale"
        case circleRadius = "circle-radius"
        case circleRadiusTransition = "circle-radius-transition"
        case circleStrokeColor = "circle-stroke-color"
        case circleStrokeColorTransition = "circle-stroke-color-transition"
        case circleStrokeOpacity = "circle-stroke-opacity"
        case circleStrokeOpacityTransition = "circle-stroke-opacity-transition"
        case circleStrokeWidth = "circle-stroke-width"
        case circleStrokeWidthTransition = "circle-stroke-width-transition"
        case circleTranslate = "circle-translate"
        case circleTranslateTransition = "circle-translate-transition"
        case circleTranslateAnchor = "circle-translate-anchor"
      }
    }

    public init(id: String) {
      self.id = id
      self.type = LayerType.circle
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