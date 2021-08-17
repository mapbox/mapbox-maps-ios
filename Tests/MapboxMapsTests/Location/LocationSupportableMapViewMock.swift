import MapboxCoreMaps
import UIKit
@testable import MapboxMaps

class LocationSupportableMapViewMock: UIView, LocationSupportableMapView {

    public func point(for coordinate: CLLocationCoordinate2D) -> CGPoint {
        return .zero
    }

    func metersPerPointAtLatitude(latitude: CLLocationDegrees) -> CLLocationDistance {
        return CLLocationDistance()
    }
}
