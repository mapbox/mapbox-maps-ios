// This file is generated.

import Foundation
import MapboxCoreMaps
import MapboxCommon

/**
 * A stroked line.
 *
 * @see <a href="https://www.mapbox.com/mapbox-gl-style-spec/#layers-line">The online documentation</a>
 *
 */
public struct LineLayer: Layer {

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
    public var layout: LineLayer.Layout?

    public struct Layout: Codable {

      /// Whether this layer is displayed.
      public var visibility: Visibility?
      
      public init() {
        self.visibility = .visible
      }

            
      /// The display of line endings.
      public var lineCap: LineCap?
            
      /// The display of lines when joining.
      public var lineJoin: LineJoin?
            
      /// Used to automatically convert miter joins to bevel joins for sharp angles.
      public var lineMiterLimit: Value<Double>?
            
      /// Used to automatically convert round joins to miter joins for shallow angles.
      public var lineRoundLimit: Value<Double>?
            
      /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
      public var lineSortKey: Value<Double>?
       
      enum CodingKeys: String, CodingKey {
        case lineCap = "line-cap"
        case lineJoin = "line-join"
        case lineMiterLimit = "line-miter-limit"
        case lineRoundLimit = "line-round-limit"
        case lineSortKey = "line-sort-key"
        case visibility = "visibility"
      }
    }

    /// Changes to a paint property are cheap and happen synchronously.
    public var paint: LineLayer.Paint?
  
    public struct Paint: Codable {

      public init() {}
          
      /// Blur applied to the line, in pixels.
      public var lineBlur: Value<Double>?
      
      /// Transition options for `lineBlur`.
      public var lineBlurTransition: StyleTransition?
            
      /// The color with which the line will be drawn.
      public var lineColor: Value<ColorRepresentable>?
      
      /// Transition options for `lineColor`.
      public var lineColorTransition: StyleTransition?
            
      /// Specifies the lengths of the alternating dashes and gaps that form the dash pattern. The lengths are later scaled by the line width. To convert a dash length to pixels, multiply the length by the current line width. Note that GeoJSON sources with `lineMetrics: true` specified won't render dashed lines to the expected scale. Also note that zoom-dependent expressions will be evaluated only at integer zoom levels.
      public var lineDasharray: Value<[Double]>?
      
      /// Transition options for `lineDasharray`.
      public var lineDasharrayTransition: StyleTransition?
            
      /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
      public var lineGapWidth: Value<Double>?
      
      /// Transition options for `lineGapWidth`.
      public var lineGapWidthTransition: StyleTransition?
            
      /// Defines a gradient with which to color a line feature. Can only be used with GeoJSON sources that specify `"lineMetrics": true`.
      public var lineGradient: Value<ColorRepresentable>?
            
      /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
      public var lineOffset: Value<Double>?
      
      /// Transition options for `lineOffset`.
      public var lineOffsetTransition: StyleTransition?
            
      /// The opacity at which the line will be drawn.
      public var lineOpacity: Value<Double>?
      
      /// Transition options for `lineOpacity`.
      public var lineOpacityTransition: StyleTransition?
            
      /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
      public var linePattern: Value<ResolvedImage>?
      
      /// Transition options for `linePattern`.
      public var linePatternTransition: StyleTransition?
            
      /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
      public var lineTranslate: Value<[Double]>?
      
      /// Transition options for `lineTranslate`.
      public var lineTranslateTransition: StyleTransition?
            
      /// Controls the frame of reference for `line-translate`.
      public var lineTranslateAnchor: LineTranslateAnchor?
            
      /// Stroke thickness.
      public var lineWidth: Value<Double>?
      
      /// Transition options for `lineWidth`.
      public var lineWidthTransition: StyleTransition?
      

      enum CodingKeys: String, CodingKey {
        case lineBlur = "line-blur"
        case lineBlurTransition = "line-blur-transition"
        case lineColor = "line-color"
        case lineColorTransition = "line-color-transition"
        case lineDasharray = "line-dasharray"
        case lineDasharrayTransition = "line-dasharray-transition"
        case lineGapWidth = "line-gap-width"
        case lineGapWidthTransition = "line-gap-width-transition"
        case lineGradient = "line-gradient"
        case lineOffset = "line-offset"
        case lineOffsetTransition = "line-offset-transition"
        case lineOpacity = "line-opacity"
        case lineOpacityTransition = "line-opacity-transition"
        case linePattern = "line-pattern"
        case linePatternTransition = "line-pattern-transition"
        case lineTranslate = "line-translate"
        case lineTranslateTransition = "line-translate-transition"
        case lineTranslateAnchor = "line-translate-anchor"
        case lineWidth = "line-width"
        case lineWidthTransition = "line-width-transition"
      }
    }

    public init(id: String) {
      self.id = id
      self.type = LayerType.line
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