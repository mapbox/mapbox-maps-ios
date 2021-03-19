import UIKit

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsLocation
#endif

internal class LocationConsumerMock: LocationConsumer {
    func locationUpdate(newLocation: Location) {
        print("location updated")
    }
}
