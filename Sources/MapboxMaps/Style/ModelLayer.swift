// swiftlint:disable nesting

import Foundation
import MapboxCoreMaps
import MapboxCommon

/// - SeeAlso: [Online documentation](https://www.mapbox.com/mapbox-gl-style-spec/#layers-model)
internal struct ModelLayer: Layer {

    // MARK: - Conformance to `Layer` protocol
    internal var id: String
    internal var type: LayerType
    internal var filter: Expression?
    internal var source: String?
    internal var sourceLayer: String?
    internal var minZoom: Double?
    internal var maxZoom: Double?

    /// Layer layout properties are applied early in the rendering process and define how data for that layer is passed to the GPU.
    /// Changes to a layout property require an asynchronous "layout" step.
    internal var layout: ModelLayer.Layout?

    internal struct Layout: Codable {

        /// Whether this layer is displayed.
        internal var visibility: Value<Visibility>?

        internal init() {
            self.visibility = .constant(.visible)
        }

        enum CodingKeys: String, CodingKey {
            case visibility
        }
    }

    /// Changes to a paint property are cheap and happen synchronously.
    internal var paint: ModelLayer.Paint?

    internal struct Paint: Codable {

        internal init() {}

        /// Defines rendering behavior of model in respect to other 3D scene objects. Defaults to .common3D.
        internal var modelLayerType: Value<ModelLayerType>?

        /// The opacity of the model layer.
        internal var modelOpacity: Value<Double>?

        /// Transition options for `modelOpacity`.
        internal var modelOpacityTransition: StyleTransition?

        /// The rotation of the model in euler angles [lon, lat, z].
        internal var modelRotation: Value<[Double]>?

        /// Transition options for `modelRotation`.
        internal var modelRotationTransition: StyleTransition?

        /// The scale of the model.
        internal var modelScale: Value<[Double]>?

        /// The translation of the model [lon, lat, z]
        internal var modelTranslation: Value<[Double]>?

        enum CodingKeys: String, CodingKey {
            case modelLayerType = "model-type"
            case modelOpacity = "model-opacity"
            case modelOpacityTransition = "model-opacity-transition"
            case modelRotation = "model-rotation"
            case modelRotationTransition = "model-rotation-transition"
            case modelScale = "model-scale"
            case modelTranslation = "model-translation"
        }
    }

    internal init(id: String) {
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
