import Foundation
import MapboxMaps
import Combine

final class OnDemandLocationProvider {
    @Published
    var coordinate: CLLocationCoordinate2D?

    var locations: Signal<[Location]> {
        return $coordinate
            .compactMap { $0 }
            .map { coordinate in
                [Location(coordinate: coordinate, timestamp: Date())]
            }.eraseToSignal()
    }
}
