import UIKit

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsLocation
#endif

internal class LocationConsumerMock: LocationConsumer {
    var shouldTrackLocation: Bool

    func locationUpdate(newLocation: Location) {
        print("location updated")
    }

    init(shouldTrackLocation: Bool) {
        self.shouldTrackLocation = shouldTrackLocation
    }
}
