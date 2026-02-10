// This file is generated.
import UIKit

/// - SeeAlso: [Mapbox Style Specification](https://docs.mapbox.com/style-spec/reference/types#modelSourceModels)
public struct Model: Codable, StyleEncodable, Equatable, Sendable {

    /// The model's identifier.
    public var id: String? = UUID().uuidString

    /// A URL to a model resource. Supported protocols are `http:`, `https:`, and `mapbox://<Model ID>`.
    public var uri: URL?

    /// Position of the model in longitude and latitude [lng, lat].
    /// Default value: [0,0]. Minimum value: [-180,-90]. Maximum value: [180,90].
    public var position: [Double]?

    /// Orientation of the model in euler angles [x, y, z].
    /// Default value: [0,0,0]. The unit of orientation is in degrees.
    public var orientation: [Double]?

    /// A collection of node overrides.
    public var nodeOverrides: [ModelNodeOverride]?

    /// An array of one or more model node names whose transform will be overridden from model layer paint properties.
    public var nodeOverrideNames: [String]?

    /// A collection of material overrides.
    public var materialOverrides: [ModelMaterialOverride]?

    /// An array of one or more model material names whose properties will be overridden from model layer paint properties.
    public var materialOverrideNames: [String]?

    /// An object defining custom properties of the model. Properties are accessible as feature properties in expressions.
    ///
    /// Example usage:
    /// ```swift
    /// Model(id: "car-1")
    ///     .uri(URL(string: "https://example.com/car.glb")!)
    ///     .featureProperties([
    ///         "vehicleType": "sedan",
    ///         "fleetId": 42
    ///     ])
    /// ```
    ///
    /// These properties can then be accessed in layer expressions:
    /// ```swift
    /// ModelLayer(id: "car-layer", source: "car-source")
    ///     .modelColor(
    ///         Exp(.switchCase) {
    ///             Exp(.eq) {
    ///                 Exp(.get) { "vehicleType" }
    ///                 "sedan"
    ///             }
    ///             UIColor.blue
    ///             UIColor.red
    ///         }
    ///     )
    /// ```
    public var featureProperties: JSONObject?

    /// Creates a new Model.
    @available(*, deprecated)
    public init(
        id: String? = nil,
        uri: URL? = nil,
        position: [Double]? = nil,
        orientation: [Double]? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.uri = uri
        self.position = position
        self.orientation = orientation
    }

    /// Creates a new Model.
    public init(
        id: String,
        uri: URL? = nil,
        position: [Double]? = nil,
        orientation: [Double]? = nil,
        nodeOverrides: [ModelNodeOverride]? = nil,
        nodeOverrideNames: [String]? = nil,
        materialOverrides: [ModelMaterialOverride]? = nil,
        materialOverrideNames: [String]? = nil,
        featureProperties: JSONObject? = nil
    ) {
        self.id = id
        self.uri = uri
        self.position = position
        self.orientation = orientation
        self.nodeOverrides = nodeOverrides
        self.nodeOverrideNames = nodeOverrideNames
        self.materialOverrides = materialOverrides
        self.materialOverrideNames = materialOverrideNames
        self.featureProperties = featureProperties
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(uri, forKey: .uri)
        try container.encodeIfPresent(position, forKey: .position)
        try container.encodeIfPresent(orientation, forKey: .orientation)
        let nodeOverridesMap = nodeOverrides?.reduce(into: [:]) { partialResult, value in
            partialResult[value.name] = value
        }
        try container.encodeIfPresent(nodeOverridesMap, forKey: .nodeOverrides)
        try container.encodeIfPresent(nodeOverrideNames, forKey: .nodeOverrideNames)
        let materialOverridesMap = materialOverrides?.reduce(into: [:]) { partialResult, value in
            partialResult[value.name] = value
        }
        try container.encodeIfPresent(materialOverridesMap, forKey: .materialOverrides)
        try container.encodeIfPresent(materialOverrideNames, forKey: .materialOverrideNames)
        try container.encodeIfPresent(featureProperties, forKey: .featureProperties)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.uri = try container.decodeIfPresent(URL.self, forKey: .uri)
        self.position = try container.decodeIfPresent([Double].self, forKey: .position)
        self.orientation = try container.decodeIfPresent([Double].self, forKey: .orientation)
        let nodeOverridesMap = try container.decodeIfPresent([String: ModelNodeOverride].self, forKey: .nodeOverrides)
        let nodeOverrides = nodeOverridesMap?.map { (name, value) in
            var c = value
            c.name = name
            return c
        }
        self.nodeOverrides = nodeOverrides
        self.nodeOverrideNames = try container.decodeIfPresent([String].self, forKey: .nodeOverrideNames)
        let materialOverridesMap = try container.decodeIfPresent([String: ModelMaterialOverride].self, forKey: .materialOverrides)
        let materialOverrides = materialOverridesMap?.map { (name, value) in
            var c = value
            c.name = name
            return c
        }
        self.materialOverrides = materialOverrides
        self.materialOverrideNames = try container.decodeIfPresent([String].self, forKey: .materialOverrideNames)
        self.featureProperties = try container.decodeIfPresent(JSONObject.self, forKey: .featureProperties)
    }

    enum CodingKeys: String, CodingKey {
        case uri = "uri"
        case position = "position"
        case orientation = "orientation"
        case nodeOverrides = "nodeOverrides"
        case nodeOverrideNames = "nodeOverrideNames"
        case materialOverrides = "materialOverrides"
        case materialOverrideNames = "materialOverrideNames"
        case featureProperties = "featureProperties"
    }
}

extension Model {
    /// The model's identifier
    public func id(_ constant: String) -> Self {
        with(self, setter(\.id, constant))
    }

   /// A URL to a model resource. Supported protocols are `http:`, `https:`, and `mapbox://<Model ID>`.
    public func uri(_ constant: URL) -> Self {
        with(self, setter(\.uri, constant))
    }

    /// Position of the model in longitude and latitude [lng, lat].
    /// Default value: [0,0]. Minimum value: [-180,-90]. Maximum value: [180,90].
    public func position(longitude: Double, latitude: Double) -> Self {
        with(self, setter(\.position, [longitude, latitude]))
    }

    /// Orientation of the model in euler angles [x, y, z].
    /// Default value: [0,0,0]. The unit of orientation is in degrees.
    public func orientation(x: Double, y: Double, z: Double) -> Self {
        with(self, setter(\.orientation, [x, y, z]))
    }

    /// A collection of node overrides.
    public func nodeOverrides(_ constant: [ModelNodeOverride]) -> Self {
        with(self, setter(\.nodeOverrides, constant))
    }

    /// An array of one or more model node names whose transform will be overridden from model layer paint properties.
    public func nodeOverrideNames(_ constant: [String]) -> Self {
        with(self, setter(\.nodeOverrideNames, constant))
    }

    /// A collection of material overrides.
    public func materialOverrides(_ constant: [ModelMaterialOverride]) -> Self {
        with(self, setter(\.materialOverrides, constant))
    }

    /// An array of one or more model material names whose properties will be overridden from model layer paint properties.
    public func materialOverrideNames(_ constant: [String]) -> Self {
        with(self, setter(\.materialOverrideNames, constant))
    }

    /// An object defining custom properties of the model. Properties are accessible as feature properties in expressions.
    ///
    /// Example usage:
    /// ```swift
    /// Model(id: "car-1")
    ///     .uri(URL(string: "https://example.com/car.glb")!)
    ///     .featureProperties([
    ///         "vehicleType": "sedan",
    ///         "fleetId": 42
    ///     ])
    /// ```
    ///
    /// These properties can then be accessed in layer expressions:
    /// ```swift
    /// ModelLayer(id: "car-layer", source: "car-source")
    ///     .modelColor(
    ///         Exp(.switchCase) {
    ///             Exp(.eq) {
    ///                 Exp(.get) { "vehicleType" }
    ///                 "sedan"
    ///             }
    ///             UIColor.blue
    ///             UIColor.red
    ///         }
    ///     )
    /// ```
    public func featureProperties(_ constant: JSONObject) -> Self {
        with(self, setter(\.featureProperties, constant))
    }
}

@_spi(Experimental)
extension Model: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        guard id != nil, uri != nil else {
            Log.warning("Failed to add Model to StyleModel because it does not have an id or uri.", category: "styleDSL")
            return
        }
        node.mount(MountedModel(model: self))
    }
}

/// - SeeAlso: [Mapbox Style Specification](https://docs.mapbox.com/style-spec/reference/types#modelMaterialOverrides)
public struct ModelMaterialOverride: Codable, StyleEncodable, Equatable, Sendable {

    /// The override's name.
    public var name: String = UUID().uuidString

    /// Override the tint color of the material.
    public var modelColor: StyleColor?

    /// Override the intensity of model-color (on a scale from 0 to 1) in color mix with original 3D model's colors.
    public var modelColorMixIntensity: Double?

    /// Override strength of the emission of material.
    /// The unit of modelEmissiveStrength is in intensity.
    public var modelEmissiveStrength: Double?

    /// Override the opacity of the material.
    public var modelOpacity: Double?

    /// Creates a new ModelMaterialOverride.
    public init(
        name: String,
        modelColor: StyleColor? = nil,
        modelColorMixIntensity: Double? = nil,
        modelEmissiveStrength: Double? = nil,
        modelOpacity: Double? = nil
    ) {
        self.name = name
        self.modelColor = modelColor
        self.modelColorMixIntensity = modelColorMixIntensity
        self.modelEmissiveStrength = modelEmissiveStrength
        self.modelOpacity = modelOpacity
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(modelColor, forKey: .modelColor)
        try container.encodeIfPresent(modelColorMixIntensity, forKey: .modelColorMixIntensity)
        try container.encodeIfPresent(modelEmissiveStrength, forKey: .modelEmissiveStrength)
        try container.encodeIfPresent(modelOpacity, forKey: .modelOpacity)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.modelColor = try container.decodeIfPresent(StyleColor.self, forKey: .modelColor)
        self.modelColorMixIntensity = try container.decodeIfPresent(Double.self, forKey: .modelColorMixIntensity)
        self.modelEmissiveStrength = try container.decodeIfPresent(Double.self, forKey: .modelEmissiveStrength)
        self.modelOpacity = try container.decodeIfPresent(Double.self, forKey: .modelOpacity)
    }

    enum CodingKeys: String, CodingKey {
        case modelColor = "model-color"
        case modelColorMixIntensity = "model-color-mix-intensity"
        case modelEmissiveStrength = "model-emissive-strength"
        case modelOpacity = "model-opacity"
    }
}

extension ModelMaterialOverride {
    /// Override the tint color of the material.
    public func modelColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.modelColor, constant))
    }

    /// Override the tint color of the material.
    public func modelColor(_ color: UIColor) -> Self {
        with(self, setter(\.modelColor, StyleColor(color)))
    }

    /// Override the intensity of model-color (on a scale from 0 to 1) in color mix with original 3D model's colors.
    public func modelColorMixIntensity(_ constant: Double) -> Self {
        with(self, setter(\.modelColorMixIntensity, constant))
    }

    /// Override strength of the emission of material.
    /// The unit of modelEmissiveStrength is in intensity.
    public func modelEmissiveStrength(_ constant: Double) -> Self {
        with(self, setter(\.modelEmissiveStrength, constant))
    }

    /// Override the opacity of the material.
    public func modelOpacity(_ constant: Double) -> Self {
        with(self, setter(\.modelOpacity, constant))
    }
}


/// - SeeAlso: [Mapbox Style Specification](https://docs.mapbox.com/style-spec/reference/types#modelNodeOverrides)
public struct ModelNodeOverride: Codable, StyleEncodable, Equatable, Sendable {

    /// The override's name.
    public var name: String = UUID().uuidString

    /// Override the orientation of the model node in euler angles [x, y, z].
    /// Default value: [0,0,0]. The unit of orientation is in degrees.
    public var orientation: [Double]?

    /// Creates a new ModelNodeOverride.
    public init(
        name: String,
        orientation: [Double]? = nil
    ) {
        self.name = name
        self.orientation = orientation
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(orientation, forKey: .orientation)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.orientation = try container.decodeIfPresent([Double].self, forKey: .orientation)
    }

    enum CodingKeys: String, CodingKey {
        case orientation = "orientation"
    }
}

extension ModelNodeOverride {
    /// Override the orientation of the model node in euler angles [x, y, z].
    /// Default value: [0,0,0]. The unit of orientation is in degrees.
    public func orientation(x: Double, y: Double, z: Double) -> Self {
        with(self, setter(\.orientation, [x, y, z]))
    }
}


// End of generated file.
