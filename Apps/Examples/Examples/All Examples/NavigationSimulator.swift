import Foundation
import CoreLocation
import MapboxMaps

final class NavigationSimulator {
    private let viewport: ViewportManager
    private let route: LineString

    private lazy var followPuckViewPortState = viewport.makeFollowPuckViewportState(
        options: FollowPuckViewportStateOptions(bearing: .course)
    )

    private let locationObservers = NSHashTable<AnyObject>.weakObjects()
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

    init(viewport: ViewportManager, route: LineString) {
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
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                guard let self else {
                    return timer.invalidate()
                }

                if !routePointsToTravel.isEmpty {
                    let nextPoint = self.routePointsToTravel.removeFirst()
                    currentLocation = nextPoint
                } else {
                    // Journey completed.
                    timer.invalidate()
                }
            }
        }

        startUpdatingLocation()
    }

    func progressFromStart(to location: Location) -> Double {
        route.distance(to: location.coordinate)! / routeLength
    }

    private func startUpdatingLocation() {
        let location = Location(
            coordinate: currentLocation,
            timestamp: Date(),
            altitude: 0,
            horizontalAccuracy: kCLLocationAccuracyBestForNavigation,
            verticalAccuracy: kCLLocationAccuracyBestForNavigation,
            speed: 0,
            // Turf calculates bearing in decimal degrees within -180 to 180,
            // while Apple's course requires value in decimal degrees from 0 - 359.9
            bearing: direction < 0 ? 360 + direction : direction,
            floor: nil,
            extra: nil)

        for consumer in locationObservers.allObjects {
            (consumer as? LocationObserver)?.onLocationUpdateReceived(for: [location])
        }
    }
}

extension NavigationSimulator: LocationProvider {
    func addLocationObserver(for observer: LocationObserver) {
        locationObservers.add(observer)
    }

    func removeLocationObserver(for observer: LocationObserver) {
        locationObservers.remove(observer)
    }

    func getLastObservedLocation() -> Location? {
        Location(coordinate: currentLocation)
    }
}
