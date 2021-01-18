import XCTest
import MapboxCoreMaps

#if canImport(Mapbox)
@testable import Mapbox
#else
@testable import MapboxMapsAnnotations
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class MapboxMapsAnnotationsTests: XCTestCase {
}
