import UIKit

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
import MapboxMapsFoundation
@testable import MapboxMapsOrnaments
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
// Mock class that flags true when `OrnamentSupportableView` protocol methods have been called on it
class OrnamentSupportableMapViewMock: MapView {

}
