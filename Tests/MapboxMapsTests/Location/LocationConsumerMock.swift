import UIKit
@testable import MapboxMaps

internal class LocationConsumerMock: LocationConsumer {
    func locationUpdate(newLocation: Location) {
        print("location updated")
    }
}
