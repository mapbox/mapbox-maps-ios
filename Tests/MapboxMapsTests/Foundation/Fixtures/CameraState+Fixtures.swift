import MapboxMaps
import UIKit

extension CameraState {
    static func testConstantValue() -> Self {
        return CameraState(
            center: .init(latitude: 10, longitude: 10),
            padding: .init(top: 40, left: 29, bottom: 98, right: 83),
            zoom: 71,
            bearing: 93,
            pitch: 45)

    }

    static var zero: CameraState {
        CameraState(
        center: CLLocationCoordinate2D(
            latitude: 0,
            longitude: 0),
        padding: UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0),
        zoom: 0,
        bearing: 0,
        pitch: 0)
    }
}
