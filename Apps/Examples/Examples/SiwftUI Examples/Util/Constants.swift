import CoreLocation
import MapboxMapsSwiftUI

extension CLLocationCoordinate2D {
    static let helsinki = CLLocationCoordinate2D(latitude: 60.167488, longitude: 24.942747)
    static let berlin = CLLocationCoordinate2D(latitude: 52.5170365, longitude: 13.3888599)
    static let london = CLLocationCoordinate2D(latitude: 51.5073219, longitude: -0.1276474)
    static let newYork = CLLocationCoordinate2D(latitude: 40.7306, longitude: -73.9866)
    static let zero = CLLocationCoordinate2D(latitude: 0, longitude: 0)
}


extension CameraBoundsOptions {
    static let world = CameraBoundsOptions(bounds: .world)
    static let iceland = CameraBoundsOptions(
        bounds: CoordinateBounds(
            southwest: CLLocationCoordinate2D(latitude: 63.33, longitude: -25.52),
            northeast: CLLocationCoordinate2D(latitude: 66.61, longitude: -13.47)))
}

extension StyleURI {
    static let customStyle = StyleURI(rawValue: "mapbox://styles/examples/cke97f49z5rlg19l310b7uu7j")!
}
