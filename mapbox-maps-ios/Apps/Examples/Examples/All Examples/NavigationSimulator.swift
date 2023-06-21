import Foundation
import CoreLocation
import MapboxMaps

final class NavigationSimulator: LocationProvider {

    private let viewport: Viewport
    private let route: LineString

    private lazy var followPuckViewPortState = viewport.makeFollowPuckViewportState(
        options: FollowPuckViewportStateOptions(bearing: .course)
    )

    private let locationConsumers = NSHashTable<AnyObject>.weakObjects()
    private var isStarted = false
    private let routeLength: LocationDistance
    private var routePointsToTravel: [LocationCoordinate2D]

    var latestLocation: Location? {
        return Location(location:
                            CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude),
                        accuracyAuthorization: .fullAccuracy
        )
    }
    
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

        startUpdatingLocation()
    }

    func progressFromStart(to location: Location) -> Double {
        route.distance(to: location.coordinate)! / routeLength
    }

    private func startUpdatingLocation() {
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

        for consumer in locationConsumers.allObjects {
            (consumer as? LocationConsumer)?.locationUpdate(newLocation: .init(location: location, accuracyAuthorization: .fullAccuracy))
        }
    }

    func add(consumer: LocationConsumer) {
        locationConsumers.add(consumer)
    }

    func remove(consumer: LocationConsumer) {
        locationConsumers.remove(consumer)
    }
}
