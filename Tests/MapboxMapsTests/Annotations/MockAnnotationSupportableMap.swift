import UIKit
import Turf
@testable import MapboxMaps

//swiftlint:disable explicit_acl explicit_top_level_acl
final class MockAnnotationSupportableMap: UIView, AnnotationSupportableMap {

    func visibleFeatures(in rect: CGRect,
                         styleLayers: Set<String>?,
                         filter: Expression?,
                         completion: @escaping (Result<[Feature], BaseMapView.QueryRenderedFeaturesError>) -> Void) {

        let coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let feature = Feature(Point.init(coord))
        completion(.success([feature]))
    }

    struct OnParameters {
        var eventType: MapEvents.EventKind
        var handler: (MapboxCoreMaps.Event) -> Void
    }
    let onStub = Stub<OnParameters, Void>()
    func on(_ eventType: MapEvents.EventKind, handler: @escaping (MapboxCoreMaps.Event) -> Void) {
        return onStub.call(with: OnParameters(eventType: eventType, handler: handler))
    }
}
