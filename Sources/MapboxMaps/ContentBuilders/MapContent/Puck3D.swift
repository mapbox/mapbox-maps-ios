/// Displays user location via 3D Puck.
///
/// Use a 3D model to display user location ``Map-swift.struct`` content.
///
/// ```swift
/// Map {
///     let model = Model(
///        uri: URL(string: /* url to glb model */),
///        orientation: [0, 0, 180] // orient source model to point the bearing property
///     )
///     Puck3D(model: model, bearing: .course)
/// }
/// ```
public struct Puck3D: MapContent, PrimitiveMapContent {
    private var configuration: Puck3DConfiguration
    private var bearing: PuckBearing?

    /// Creates puck.
    public init(model: Model, bearing: PuckBearing?) {
        self.configuration = Puck3DConfiguration(model: model)
        self.bearing = bearing
    }

    /// The scale of the model.
    public func modelScale(x: Double, y: Double, z: Double) -> Puck3D {
        copyAssigned(self, \.configuration.modelScale, .constant([x, y, z]))
    }

    /// The rotation of the model in euler angles [lon, lat, z].
    public func modelRotation(x: Double, y: Double, z: Double) -> Puck3D {
        copyAssigned(self, \.configuration.modelRotation, .constant([x, y, z]))
    }

    /// The opacity of the model used as the location puck
    public func modelOpacity(_ modelOpacity: Double) -> Puck3D {
        copyAssigned(self, \.configuration.modelOpacity, .constant(modelOpacity))
    }

    /// Enable/disable shadow casting for the puck model
    public func modelCastShadows(_ modelCastShadows: Bool) -> Puck3D {
        copyAssigned(self, \.configuration.modelCastShadows, .constant(modelCastShadows))
    }

    /// Enable/disable shadow receiving for the puck model
    public func modelReceiveShadows(_ modelReceiveShadows: Bool) -> Puck3D {
        copyAssigned(self, \.configuration.modelReceiveShadows, .constant(modelReceiveShadows))
    }

    /// Defines scaling mode. Only applies to location-indicator type layers. Defaults to ``ModelScaleMode/viewport``.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelScaleMode(_ modelScaleMode: ModelScaleMode) -> Puck3D {
        copyAssigned(self, \.configuration.modelScaleMode, .constant(modelScaleMode))
    }

    /// Selects the base of the model. Some modes might require precomputed elevation data in the tileset.
    /// Default value: "ground".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func modelElevationReference(_ value: ModelElevationReference) -> Puck3D {
        copyAssigned(self, \.configuration.modelElevationReference, .constant(value))
    }

    /// Strength of the emission.
    ///
    /// There is no emission for value 0. For value 1.0, only emissive component (no shading) is displayed and values above 1.0 produce light contribution to surrounding area, for some of the parts (e.g. windows).
    ///
    /// Default value is 1.
    public func modelEmissiveStrength(_ modelEmissiveStrength: Double) -> Puck3D {
        copyAssigned(self, \.configuration.modelEmissiveStrength, .constant(modelEmissiveStrength))
    }

    /// The scale of the model.
    public func modelScale(_ modelScale: Exp) -> Puck3D {
        copyAssigned(self, \.configuration.modelScale, .expression(modelScale))
    }

    /// The rotation of the model in euler angles [lon, lat, z].
    public func modelRotation(_ modelRotation: Exp) -> Puck3D {
        copyAssigned(self, \.configuration.modelRotation, .expression(modelRotation))
    }

    /// The opacity of the model used as the location puck
    public func modelOpacity(_ modelOpacity: Exp) -> Puck3D {
        copyAssigned(self, \.configuration.modelOpacity, .expression(modelOpacity))
    }

    /// Enable/disable shadow casting for the puck model
    public func modelCastShadows(_ modelCastShadows: Exp) -> Puck3D {
        copyAssigned(self, \.configuration.modelCastShadows, .expression(modelCastShadows))
    }

    /// Enable/disable shadow receiving for the puck model
    public func modelReceiveShadows(_ modelReceiveShadows: Exp) -> Puck3D {
        copyAssigned(self, \.configuration.modelReceiveShadows, .expression(modelReceiveShadows))
    }

    /// Defines scaling mode. Only applies to location-indicator type layers. Defaults to ``ModelScaleMode/viewport``.
    public func modelScaleMode(_ modelScaleMode: Exp) -> Puck3D {
        copyAssigned(self, \.configuration.modelScaleMode, .expression(modelScaleMode))
    }

    /// Strength of the emission.
    ///
    /// There is no emission for value 0. For value 1.0, only emissive component (no shading) is displayed and values above 1.0 produce light contribution to surrounding area, for some of the parts (e.g. windows).
    ///
    /// Default value is 1.
    public func modelEmissiveStrength(_ modelEmissiveStrength: Exp) -> Puck3D {
        copyAssigned(self, \.configuration.modelEmissiveStrength, .expression(modelEmissiveStrength))
    }

    /// The ``Slot`` where to put puck layers.
    ///
    /// If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    public func slot(_ slot: Slot?) -> Puck3D {
        copyAssigned(self, \.configuration.slot, slot)
    }

    func visit(_ node: MapContentNode) {
        let locationOptions = LocationOptions(
            puckType: .puck3D(configuration),
            puckBearing: bearing ?? .heading,
            puckBearingEnabled: bearing != nil
        )
        node.mount(MountedPuck(locationOptions: locationOptions))
    }
}
