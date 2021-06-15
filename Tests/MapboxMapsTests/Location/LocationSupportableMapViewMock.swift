import MapboxCoreMaps
import UIKit

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsLocation
@testable import MapboxMapsStyle
#endif

#if canImport(MapboxMapsStyle)
@testable import MapboxMapsStyle
#endif

class LocationSupportableMapViewMock: UIView, LocationSupportableMapView {

    public func point(for coordinate: CLLocationCoordinate2D) -> CGPoint {
        return .zero
    }

    func metersPerPointAtLatitude(latitude: CLLocationDegrees) -> CLLocationDistance {
        return CLLocationDistance()
    }
}
