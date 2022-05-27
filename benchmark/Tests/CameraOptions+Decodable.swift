import Foundation
import MapboxMaps

extension CameraOptions: Decodable {
    enum CodingKeys: CodingKey {
        case center
        case padding
        case zoom
        case anchor
        case bearing
        case pitch
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let center = try container.decodeIfPresent(CLLocationCoordinate2D.self, forKey: .center)
        let padding = try container.decodeIfPresent(UIEdgeInsets.self, forKey: .padding)
        let zoom = try container.decodeIfPresent(CGFloat.self, forKey: .zoom)
        let anchor = try container.decodeIfPresent(CGPoint.self, forKey: .anchor)
        let bearing = try container.decodeIfPresent(CLLocationDirection.self, forKey: .bearing)
        let pitch = try container.decodeIfPresent(CGFloat.self, forKey: .pitch)

        self.init(center: center, padding: padding, anchor: anchor, zoom: zoom, bearing: bearing, pitch: pitch)
    }
}

extension CLLocationCoordinate2D: Decodable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(Double.self)
        let latitude = try container.decode(Double.self)

        self.init(latitude: latitude, longitude: longitude)
    }
}
