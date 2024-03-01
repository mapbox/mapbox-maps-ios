/// Substate of ``PuckRenderingData`` which contains only data needed for ``FollowPuckViewportState`` rendering.
/// Allows to use ``Signal.skipRepeats()`` and avoid unnecessary recalculations.
struct PuckRendererState<Configuration: Equatable>: Equatable {
    var coordinate: CLLocationCoordinate2D
    var horizontalAccuracy: CLLocationAccuracy?
    var accuracyAuthorization: CLAccuracyAuthorization
    var bearing: CLLocationDirection?
    var heading: Heading?
    var configuration: Configuration
    var bearingEnabled: Bool
    var bearingType: PuckBearing
}

extension PuckRendererState {
    init(
        data: PuckRenderingData,
        bearingEnabled: Bool,
        bearingType: PuckBearing,
        configuration: Configuration
    ) {
        self.coordinate = data.location.coordinate
        self.horizontalAccuracy = data.location.horizontalAccuracy
        self.accuracyAuthorization = data.location.accuracyAuthorization
        self.bearing = data.location.bearing
        self.heading = data.heading
        self.configuration = configuration
        self.bearingEnabled = bearingEnabled
        self.bearingType = bearingType
    }
}
