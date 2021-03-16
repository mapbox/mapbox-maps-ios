// This file is generated.

import Foundation
import MapboxCoreMaps
import MapboxCommon

/**
 * A filled polygon with an optional stroked border.
 *
 * @see <a href="https://www.mapbox.com/mapbox-gl-style-spec/#layers-fill">The online documentation</a>
 *
 */
public struct FillLayer: Layer {

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
    public var layout: FillLayer.Layout?

    public struct Layout: Codable {

      /// Whether this layer is displayed.
      public var visibility: Value<Visibility>?
      
      public init() {
        self.visibility = .constant(.visible)
      }

            
      /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
      public var fillSortKey: Value<Double>?
       
      enum CodingKeys: String, CodingKey {
        case fillSortKey = "fill-sort-key"
        case visibility = "visibility"
      }
    }

    /// Changes to a paint property are cheap and happen synchronously.
    public var paint: FillLayer.Paint?
  
    public struct Paint: Codable {

      public init() {}
          
      /// Whether or not the fill should be antialiased.
      public var fillAntialias: Value<Bool>?
            
      /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
      public var fillColor: Value<ColorRepresentable>?
      
      /// Transition options for `fillColor`.
      public var fillColorTransition: StyleTransition?
            
      /// The opacity of the entire fill layer. In contrast to the `fill-color`, this value will also affect the 1px stroke around the fill, if the stroke is used.
      public var fillOpacity: Value<Double>?
      
      /// Transition options for `fillOpacity`.
      public var fillOpacityTransition: StyleTransition?
            
      /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
      public var fillOutlineColor: Value<ColorRepresentable>?
      
      /// Transition options for `fillOutlineColor`.
      public var fillOutlineColorTransition: StyleTransition?
            
      /// Name of image in sprite to use for drawing image fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
      public var fillPattern: Value<ResolvedImage>?
      
      /// Transition options for `fillPattern`.
      public var fillPatternTransition: StyleTransition?
            
      /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
      public var fillTranslate: Value<[Double]>?
      
      /// Transition options for `fillTranslate`.
      public var fillTranslateTransition: StyleTransition?
            
      /// Controls the frame of reference for `fill-translate`.
      public var fillTranslateAnchor: Value<FillTranslateAnchor>?
      

      enum CodingKeys: String, CodingKey {
        case fillAntialias = "fill-antialias"
        case fillColor = "fill-color"
        case fillColorTransition = "fill-color-transition"
        case fillOpacity = "fill-opacity"
        case fillOpacityTransition = "fill-opacity-transition"
        case fillOutlineColor = "fill-outline-color"
        case fillOutlineColorTransition = "fill-outline-color-transition"
        case fillPattern = "fill-pattern"
        case fillPatternTransition = "fill-pattern-transition"
        case fillTranslate = "fill-translate"
        case fillTranslateTransition = "fill-translate-transition"
        case fillTranslateAnchor = "fill-translate-anchor"
      }
    }

    public init(id: String) {
      self.id = id
      self.type = LayerType.fill
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