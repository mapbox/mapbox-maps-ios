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
    var style: Style!

    func subscribeRenderFrameHandler(_ handler: @escaping (MapboxCoreMaps.Event) -> Void) {
        print("Pass through implementation")
    }

    func subscribeStyleChangeHandler(_ handler: @escaping (MapboxCoreMaps.Event) -> Void) {
        print("Pass through implementation")
    }

    func screenCoordinate(for locationCoordinate: CLLocationCoordinate2D) -> ScreenCoordinate {
        return ScreenCoordinate(x: 0.0, y: 0.0)
    }

    func metersPerPointAtLatitude(latitude: CLLocationDegrees) -> CLLocationDistance {
        return CLLocationDistance()
    }
}
