import Foundation
import CoreLocation
import MapboxMaps

final class NavigationSimulator: LocationProvider {

    private let viewport: Viewport
    private let route: LineString

    private lazy var followPuckViewPortState = viewport.makeFollowPuckViewportState(
        options: FollowPuckViewportStateOptions(bearing: .course)
    )

    var locationProviderOptions = LocationOptions()
    var authorizationStatus: CLAuthorizationStatus = .authorizedAlways
    var accuracyAuthorization: CLAccuracyAuthorization = .fullAccuracy

    var heading: CLHeading?
    var headingOrientation: CLDeviceOrientation = .portrait

    private weak var delegate: LocationProviderDelegate?

    private var isStarted = false
    private let routeLength: LocationDistance
    private var routePointsToTravel: [LocationCoordinate2D]

    private var direction: LocationDirection
    private var currentLocation: LocationCoordinate2D {
        didSet {
            direction = oldValue.direction(to: currentLocation)
            startUpdatingLocation()
        }
    }

    init(viewport: Viewport, route: LineString) {
        self.viewport = viewport
        self.route = route
        routeLength = route.distance()!
        routePointsToTravel = route.coordinates

        currentLocation = routePointsToTravel.removeFirst()
        direction = currentLocation.direction(to: routePointsToTravel[0])
    }

    func start() {
        guard !isStarted else { return }
        isStarted = true

        viewport.transition(to: followPuckViewPortState) { _ in
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if !self.routePointsToTravel.isEmpty {
                    let nextPoint = self.routePointsToTravel.removeFirst()
                    self.currentLocation = nextPoint
                } else {
                    // Journey completed.
                    timer.invalidate()
                }
            }
        }
    }

    func progressFromStart(to location: Location) -> Double {
        route.distance(to: location.coordinate)! / routeLength
    }

    // MARK: LocationProvider

    func setDelegate(_ delegate: LocationProviderDelegate) {
        self.delegate = delegate
    }

    func requestAlwaysAuthorization() {}
    func requestWhenInUseAuthorization() {}
    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {}

    func startUpdatingLocation() {
        let location = CLLocation(
            coordinate: currentLocation,
            altitude: 0,
            horizontalAccuracy: kCLLocationAccuracyBestForNavigation,
            verticalAccuracy: kCLLocationAccuracyBestForNavigation,
            // Turf calculates bearing in decimal degrees within -180 to 180,
            // while Apple's course requires value in decimal degrees from 0 - 359.9
            course: direction < 0 ? 360 + direction : direction,
            speed: 0,
            timestamp: Date()
        )
        delegate?.locationProvider(
            self,
            didUpdateLocations: [location]
        )
    }
    func stopUpdatingLocation() {}

    func startUpdatingHeading() {}
    func stopUpdatingHeading() {}
    func dismissHeadingCalibrationDisplay() {}
}
