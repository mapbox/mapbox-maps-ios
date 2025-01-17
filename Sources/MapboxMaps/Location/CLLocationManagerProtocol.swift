import Foundation
import CoreLocation

internal protocol CLLocationManagerProtocol: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var accuracyAuthorization: CLAccuracyAuthorization { get }
    var delegate: CLLocationManagerDelegate? { get set }
    var distanceFilter: CLLocationDistance { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    var activityType: CLActivityType { get set }
    func requestWhenInUseAuthorization()
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

extension CLLocationManager: CLLocationManagerProtocol {}
