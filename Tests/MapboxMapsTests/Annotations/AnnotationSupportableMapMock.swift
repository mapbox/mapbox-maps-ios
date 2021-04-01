import UIKit
import CoreLocation
import Turf
import MapboxCoreMaps

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsAnnotations
@testable import MapboxMapsFoundation
import MapboxMapsStyle
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class AnnotationSupportableMapMock: UIView, AnnotationSupportableMap {

    func visibleFeatures(in rect: CGRect,
                         styleLayers: Set<String>?,
                         filter: Expression?,
                         completion: @escaping (Result<[Feature], BaseMapView.QueryRenderedFeaturesError>) -> Void) {

        let coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let feature = Feature(Point.init(coord))
        completion(.success([feature]))
    }
    
    func on(_ eventType: MapEvents.EventKind, handler: @escaping (Event) -> Void) {
    }
}
