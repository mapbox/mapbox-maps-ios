import Foundation
import CoreLocation
@_spi(Experimental) import MapboxMaps

final class NavigationSimulator: LocationProvider {

    private let viewport: Viewport
    private var route: LineString

    private lazy var followPuckViewPortState = viewport.makeFollowPuckViewportState()
    private lazy var overviewViewportState = viewport.makeOverviewViewportState(
        options: OverviewViewportStateOptions(
            geometry: route,
            padding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)
        )
    )

    var locationProviderOptions = LocationOptions()
    var authorizationStatus: CLAuthorizationStatus = .authorizedAlways
    var accuracyAuthorization: CLAccuracyAuthorization = .fullAccuracy

    var heading: CLHeading?
    var headingOrientation: CLDeviceOrientation = .portrait

    private weak var delegate: LocationProviderDelegate?

    private var isStarted = false
    let routeLength: LocationDistance
    private(set) var distanceTravelled: LocationDistance = 0 {
        didSet {
            startUpdatingLocation()
        }
    }

    init(mapView: MapView, route: LineString) {
        self.viewport = mapView.viewport
        self.route = route
        routeLength = route.distance()!
    }

    func start() {
        guard !isStarted else { return }
        isStarted = true
        viewport.transition(to: followPuckViewPortState) { _ in

            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                // Move forward 20 meters.
                self.distanceTravelled += 20
            }
        }
    }

    // MARK: LocationProvider

    func setDelegate(_ delegate: LocationProviderDelegate) {
        self.delegate = delegate
    }

    func requestAlwaysAuthorization() {}
    func requestWhenInUseAuthorization() {}
    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {}

    func startUpdatingLocation() {
        guard let currentLocation = route.coordinateFromStart(distance: distanceTravelled) else {
            return
        }
        delegate?.locationProvider(
            self,
            didUpdateLocations: [CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)]
        )
    }
    func stopUpdatingLocation() {}

    func startUpdatingHeading() {}
    func stopUpdatingHeading() {}
    func dismissHeadingCalibrationDisplay() {}
}
