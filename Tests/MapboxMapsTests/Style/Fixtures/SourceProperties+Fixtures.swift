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

extension GeoJSONSourceData {
    static func testSourceValue() -> GeoJSONSourceData {
        let point = Point(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        return .feature(.init(geometry: .point(point)))
    }
}
