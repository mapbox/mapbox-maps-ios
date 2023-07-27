@_spi(Package) import MapboxMaps
@testable import MapboxMapsSwiftUI
import CoreLocation

final class MockLocationManager: LocationManaging {
    @Stubbed var options = LocationOptions()
}
