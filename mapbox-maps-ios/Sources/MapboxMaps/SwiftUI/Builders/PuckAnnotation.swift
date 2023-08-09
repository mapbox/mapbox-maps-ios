/// Shows 2D user location puck.
@_spi(Experimental)
public struct PuckAnnotation2D: MapContent {
    private var configuration: Puck2DConfiguration
    private var bearing: PuckBearing?

    /// Creates puck.
    public init(bearing: PuckBearing? = nil, configure: ((inout Puck2DConfiguration) -> Void)? = nil) {
        self.configuration = .makeDefault(showBearing: bearing != nil)
        self.bearing = bearing
        configure?(&configuration)
    }

    public func _visit(_ visitor: _MapContentVisitor) {
        visitor.locationOptions = LocationOptions(
            puckType: .puck2D(configuration),
            puckBearing: bearing ?? .heading,
            puckBearingEnabled: bearing != nil)
    }
}

/// Shows 3D user location puck.
@_spi(Experimental)
public struct PuckAnnotation3D: MapContent {
    private var configuration: Puck3DConfiguration
    private var bearing: PuckBearing?

    /// Creates puck.
    public init(model: Model, bearing: PuckBearing?, configure: ((inout Puck3DConfiguration) -> Void)? = nil) {
        self.configuration = Puck3DConfiguration(model: model)
        self.bearing = bearing
        configure?(&configuration)
    }

    public func _visit(_ visitor: _MapContentVisitor) {
        visitor.locationOptions = LocationOptions(
            puckType: .puck3D(configuration),
            puckBearing: bearing ?? .heading,
            puckBearingEnabled: bearing != nil)
    }
}
