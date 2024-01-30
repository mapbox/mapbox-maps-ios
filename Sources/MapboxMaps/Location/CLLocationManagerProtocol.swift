import Foundation
import CoreLocation

internal protocol CLLocationManagerProtocol: AnyObject {
    var compatibleAuthorizationStatus: CLAuthorizationStatus { get }
    var compatibleAccuracyAuthorization: CLAccuracyAuthorization { get }
    var delegate: CLLocationManagerDelegate? { get set }
    var distanceFilter: CLLocationDistance { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    var activityType: CLActivityType { get set }
    func requestWhenInUseAuthorization()
    @available(iOS 14.0, *)
    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String)
    func startUpdatingLocation()
    func stopUpdatingLocation()

#if !(swift(>=5.9) && os(visionOS))
    var heading: CLHeading? { get }
    func startUpdatingHeading()
    func stopUpdatingHeading()
    var headingOrientation: CLDeviceOrientation { get set }
#endif
}

extension CLLocationManager: CLLocationManagerProtocol {
    var compatibleAuthorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }

    }

    var compatibleAccuracyAuthorization: CLAccuracyAuthorization {
        if #available(iOS 14.0, *) {
            return accuracyAuthorization
        } else {
            return .fullAccuracy
        }
    }
}
