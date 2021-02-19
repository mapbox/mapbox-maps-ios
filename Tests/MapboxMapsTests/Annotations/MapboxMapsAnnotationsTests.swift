import XCTest
import MapboxCoreMaps

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsAnnotations
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class MapboxMapsAnnotationsTests: XCTestCase {
}
