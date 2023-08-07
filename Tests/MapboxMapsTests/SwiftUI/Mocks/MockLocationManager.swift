@testable import MapboxMaps
import CoreLocation

final class MockLocationManager: LocationManaging {
    @Stubbed var options = LocationOptions()
}
