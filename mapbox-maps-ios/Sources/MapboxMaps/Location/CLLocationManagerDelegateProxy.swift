import Foundation
import CoreLocation

internal protocol CLLocationManagerDelegateProxyDelegate: AnyObject {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool
}

internal final class CLLocationManagerDelegateProxy: NSObject, CLLocationManagerDelegate {
    internal weak var delegate: CLLocationManagerDelegateProxyDelegate?

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.locationManager(manager, didUpdateLocations: locations)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        delegate?.locationManager(manager, didUpdateHeading: newHeading)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationManager(manager, didFailWithError: error)
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        delegate?.locationManagerDidChangeAuthorization(manager)
    }

    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        delegate?.locationManagerShouldDisplayHeadingCalibration(manager) ?? false
    }
}
