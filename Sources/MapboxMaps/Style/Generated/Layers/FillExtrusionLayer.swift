// This file is generated.

import Foundation
import MapboxCoreMaps
import MapboxCommon

/**
 * An extruded (3D) polygon.
 *
 * @see <a href="https://www.mapbox.com/mapbox-gl-style-spec/#layers-fill-extrusion">The online documentation</a>
 *
 */
public struct FillExtrusionLayer: Layer {

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
    public var layout: FillExtrusionLayer.Layout?

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
    public var paint: FillExtrusionLayer.Paint?
  
    public struct Paint: Codable {

      public init() {}
          
      /// The height with which to extrude the base of this layer. Must be less than or equal to `fill-extrusion-height`.
      public var fillExtrusionBase: Value<Double>?
      
      /// Transition options for `fillExtrusionBase`.
      public var fillExtrusionBaseTransition: StyleTransition?
            
      /// The base color of the extruded fill. The extrusion's surfaces will be shaded differently based on this color in combination with the root `light` settings. If this color is specified as `rgba` with an alpha component, the alpha component will be ignored; use `fill-extrusion-opacity` to set layer opacity.
      public var fillExtrusionColor: Value<ColorRepresentable>?
      
      /// Transition options for `fillExtrusionColor`.
      public var fillExtrusionColorTransition: StyleTransition?
            
      /// The height with which to extrude this layer.
      public var fillExtrusionHeight: Value<Double>?
      
      /// Transition options for `fillExtrusionHeight`.
      public var fillExtrusionHeightTransition: StyleTransition?
            
      /// The opacity of the entire fill extrusion layer. This is rendered on a per-layer, not per-feature, basis, and data-driven styling is not available.
      public var fillExtrusionOpacity: Value<Double>?
      
      /// Transition options for `fillExtrusionOpacity`.
      public var fillExtrusionOpacityTransition: StyleTransition?
            
      /// Name of image in sprite to use for drawing images on extruded fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
      public var fillExtrusionPattern: Value<ResolvedImage>?
      
      /// Transition options for `fillExtrusionPattern`.
      public var fillExtrusionPatternTransition: StyleTransition?
            
      /// The geometry's offset. Values are [x, y] where negatives indicate left and up (on the flat plane), respectively.
      public var fillExtrusionTranslate: Value<[Double]>?
      
      /// Transition options for `fillExtrusionTranslate`.
      public var fillExtrusionTranslateTransition: StyleTransition?
            
      /// Controls the frame of reference for `fill-extrusion-translate`.
      public var fillExtrusionTranslateAnchor: Value<FillExtrusionTranslateAnchor>?
            
      /// Whether to apply a vertical gradient to the sides of a fill-extrusion layer. If true, sides will be shaded slightly darker farther down.
      public var fillExtrusionVerticalGradient: Value<Bool>?
      

      enum CodingKeys: String, CodingKey {
        case fillExtrusionBase = "fill-extrusion-base"
        case fillExtrusionBaseTransition = "fill-extrusion-base-transition"
        case fillExtrusionColor = "fill-extrusion-color"
        case fillExtrusionColorTransition = "fill-extrusion-color-transition"
        case fillExtrusionHeight = "fill-extrusion-height"
        case fillExtrusionHeightTransition = "fill-extrusion-height-transition"
        case fillExtrusionOpacity = "fill-extrusion-opacity"
        case fillExtrusionOpacityTransition = "fill-extrusion-opacity-transition"
        case fillExtrusionPattern = "fill-extrusion-pattern"
        case fillExtrusionPatternTransition = "fill-extrusion-pattern-transition"
        case fillExtrusionTranslate = "fill-extrusion-translate"
        case fillExtrusionTranslateTransition = "fill-extrusion-translate-transition"
        case fillExtrusionTranslateAnchor = "fill-extrusion-translate-anchor"
        case fillExtrusionVerticalGradient = "fill-extrusion-vertical-gradient"
      }
    }

    public init(id: String) {
      self.id = id
      self.type = LayerType.fillExtrusion
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