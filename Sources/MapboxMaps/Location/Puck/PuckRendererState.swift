/// Substate of ``PuckRenderingData`` which contains only data needed for ``FollowPuckViewportState`` rendering.
/// Allows to use ``Signal.skipRepeats()`` and avoid unnecessary recalculations.
struct PuckRendererState: Equatable {
    var coordinate: CLLocationCoordinate2D
    var horizontalAccuracy: CLLocationAccuracy?
    var accuracyAuthorization: CLAccuracyAuthorization
    var bearing: CLLocationDirection?
    var heading: Heading?
    var locationOptions: LocationOptions
}

extension PuckRendererState {
    init(locationChange: LocationChange, locationOptions: LocationOptions) {
        self.coordinate = locationChange.location.coordinate
        self.horizontalAccuracy = locationChange.location.horizontalAccuracy
        self.accuracyAuthorization = locationChange.location.accuracyAuthorization
        self.bearing = locationChange.location.bearing
        self.heading = locationChange.heading
        self.locationOptions = locationOptions
    }
}
