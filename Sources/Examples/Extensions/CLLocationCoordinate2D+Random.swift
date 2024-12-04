import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    static var random: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: .random(in: -90...90), longitude: .random(in: -180...180))
    }
}
