import Foundation
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
import Turf
#endif

internal extension Scheme {
    static func testSourceValue() -> Scheme {
        return .tms
    }
}

internal extension Encoding {
    static func testSourceValue() -> Encoding {
        return .mapbox
    }
}

extension GeoJSONSourceData: Equatable {
    public static func == (lhs: GeoJSONSourceData, rhs: GeoJSONSourceData) -> Bool {
        switch (lhs, rhs) {
        case (let .url(lhsURL), let .url(rhsURL)):
            return lhsURL == rhsURL
        default:
            return false
        }
    }

    static func testSourceValue() -> GeoJSONSourceData {
        return .url(URL(string: "some-url-string")!)
    }
}
