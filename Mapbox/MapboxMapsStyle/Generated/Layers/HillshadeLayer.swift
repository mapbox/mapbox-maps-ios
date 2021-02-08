// This file is generated.

import Foundation
import MapboxCoreMaps
import MapboxCommon

/**
 * Client-side hillshading visualization based on DEM data. Currently, the implementation only supports Mapbox Terrain RGB and Mapzen Terrarium tiles.
 *
 * @see <a href="https://www.mapbox.com/mapbox-gl-style-spec/#layers-hillshade">The online documentation</a>
 *
 */
public struct HillshadeLayer: Layer {

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
    public var layout: HillshadeLayer.Layout?

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
    public var paint: HillshadeLayer.Paint?
  
    public struct Paint: Codable {

      public init() {}
          
      /// The shading color used to accentuate rugged terrain like sharp cliffs and gorges.
      public var hillshadeAccentColor: Value<ColorRepresentable>?
      
      /// Transition options for `hillshadeAccentColor`.
      public var hillshadeAccentColorTransition: StyleTransition?
            
      /// Intensity of the hillshade
      public var hillshadeExaggeration: Value<Double>?
      
      /// Transition options for `hillshadeExaggeration`.
      public var hillshadeExaggerationTransition: StyleTransition?
            
      /// The shading color of areas that faces towards the light source.
      public var hillshadeHighlightColor: Value<ColorRepresentable>?
      
      /// Transition options for `hillshadeHighlightColor`.
      public var hillshadeHighlightColorTransition: StyleTransition?
            
      /// Direction of light source when map is rotated.
      public var hillshadeIlluminationAnchor: HillshadeIlluminationAnchor?
            
      /// The direction of the light source used to generate the hillshading with 0 as the top of the viewport if `hillshade-illumination-anchor` is set to `viewport` and due north if `hillshade-illumination-anchor` is set to `map`.
      public var hillshadeIlluminationDirection: Value<Double>?
            
      /// The shading color of areas that face away from the light source.
      public var hillshadeShadowColor: Value<ColorRepresentable>?
      
      /// Transition options for `hillshadeShadowColor`.
      public var hillshadeShadowColorTransition: StyleTransition?
      

      enum CodingKeys: String, CodingKey {
        case hillshadeAccentColor = "hillshade-accent-color"
        case hillshadeAccentColorTransition = "hillshade-accent-color-transition"
        case hillshadeExaggeration = "hillshade-exaggeration"
        case hillshadeExaggerationTransition = "hillshade-exaggeration-transition"
        case hillshadeHighlightColor = "hillshade-highlight-color"
        case hillshadeHighlightColorTransition = "hillshade-highlight-color-transition"
        case hillshadeIlluminationAnchor = "hillshade-illumination-anchor"
        case hillshadeIlluminationDirection = "hillshade-illumination-direction"
        case hillshadeShadowColor = "hillshade-shadow-color"
        case hillshadeShadowColorTransition = "hillshade-shadow-color-transition"
      }
    }

    public init(id: String) {
      self.id = id
      self.type = LayerType.hillshade
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