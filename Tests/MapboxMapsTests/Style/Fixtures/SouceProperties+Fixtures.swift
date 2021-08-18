import Foundation
import Turf
import CoreLocation
@testable import MapboxMaps

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
        case (let .feature(lhsFeature), let .feature(rhsFeature)):
            // TODO: Fix temporary conformance to equatable for Turf features in tests
            return lhsFeature.geometry.type == rhsFeature.geometry.type
        default:
            return false
        }
    }

    static func testSourceValue() -> GeoJSONSourceData {
        let point = Point(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        return .feature(.init(point))
    }
}
