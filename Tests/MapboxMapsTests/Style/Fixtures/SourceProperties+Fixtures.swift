import Foundation
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
            return lhsFeature == rhsFeature
        default:
            return false
        }
    }

    static func testSourceValue() -> GeoJSONSourceData {
        let point = Point(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        return .feature(.init(point))
    }
}
