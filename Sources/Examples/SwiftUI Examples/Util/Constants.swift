import CoreLocation
import MapboxMaps

extension CLLocationCoordinate2D {
    static let apple = CLLocationCoordinate2D(latitude: 37.3326, longitude: -122.0304)
    static let zero = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    static let helsinki = CLLocationCoordinate2D(latitude: 60.167488, longitude: 24.942747)
    static let berlin = CLLocationCoordinate2D(latitude: 52.5170365, longitude: 13.3888599)
    static let london = CLLocationCoordinate2D(latitude: 51.5073219, longitude: -0.1276474)
    static let newYork = CLLocationCoordinate2D(latitude: 40.7306, longitude: -73.9866)
    static let dc = CLLocationCoordinate2D(latitude: 38.889215, longitude: -77.039354)
    static let saigon = CLLocationCoordinate2D(latitude: 10.823099, longitude: 106.629662)
    static let hanoi = CLLocationCoordinate2D(latitude: 21.027763, longitude: 105.834160)
    static let tokyo = CLLocationCoordinate2D(latitude: 35.689487, longitude: 139.691711)
    static let bangkok = CLLocationCoordinate2D(latitude: 13.756331, longitude: 100.501762)
    static let jakarta = CLLocationCoordinate2D(latitude: -6.175110, longitude: 106.865036)
    static let kyiv = CLLocationCoordinate2D(latitude: 50.541, longitude: 30.498)
    static let tunis = CLLocationCoordinate2D(latitude: 36.806, longitude: 10.1815)
    static let barcelona = CLLocationCoordinate2D(latitude: 41.3874, longitude: 2.168)
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
