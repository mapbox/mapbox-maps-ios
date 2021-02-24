// This file is generated.

import Foundation
import MapboxCoreMaps
import MapboxCommon

/**
 * 
 *
 * @see <a href="https://www.mapbox.com/mapbox-gl-style-spec/#layers-model">The online documentation</a>
 *
 */
public struct ModelLayer: Layer {

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
    public var layout: ModelLayer.Layout?

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
    public var paint: ModelLayer.Paint?
  
    public struct Paint: Codable {

      public init() {}
          
      /// The opacity of the model layer.
      public var modelOpacity: Value<Double>?
      
      /// Transition options for `modelOpacity`.
      public var modelOpacityTransition: StyleTransition?
            
      /// The rotation of the model in euler angles [lon, lat, z].
      public var modelRotation: Value<[Double]>?
      
      /// Transition options for `modelRotation`.
      public var modelRotationTransition: StyleTransition?
            
      /// The scale of the model.
      public var modelScale: Value<[Double]>?
            
      /// The translation of the model [lon, lat, z]
      public var modelTranslation: Value<[Double]>?
      

      enum CodingKeys: String, CodingKey {
        case modelOpacity = "model-opacity"
        case modelOpacityTransition = "model-opacity-transition"
        case modelRotation = "model-rotation"
        case modelRotationTransition = "model-rotation-transition"
        case modelScale = "model-scale"
        case modelTranslation = "model-translation"
      }
    }

    public init(id: String) {
      self.id = id
      self.type = LayerType.model
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