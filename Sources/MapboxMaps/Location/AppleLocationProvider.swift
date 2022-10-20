import Foundation
import CoreLocation

public final class AppleLocationProvider: NSObject {
    private var locationProvider: CLLocationManager
    private var privateLocationProviderOptions: LocationOptions {
        didSet {
            locationProvider.distanceFilter = privateLocationProviderOptions.distanceFilter
            locationProvider.desiredAccuracy = privateLocationProviderOptions.desiredAccuracy
            locationProvider.activityType = privateLocationProviderOptions.activityType
        }
    }
    private weak var delegate: LocationProviderDelegate?

    public var headingOrientation: CLDeviceOrientation {
        didSet { locationProvider.headingOrientation = headingOrientation }
    }

    public override init() {
        locationProvider = CLLocationManager()
        privateLocationProviderOptions = LocationOptions()
        headingOrientation = locationProvider.headingOrientation
        super.init()
        locationProvider.delegate = self
    }
}

extension AppleLocationProvider: LocationProvider {

    public var locationProviderOptions: LocationOptions {
        get { privateLocationProviderOptions }
        set { privateLocationProviderOptions = newValue }
    }

    public var authorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationProvider.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }

    public var accuracyAuthorization: CLAccuracyAuthorization {
        if #available(iOS 14.0, *) {
            return locationProvider.accuracyAuthorization
        } else {
            return .fullAccuracy
        }
    }

    public var heading: CLHeading? {
        return locationProvider.heading
    }

    public func setDelegate(_ delegate: LocationProviderDelegate) {
        self.delegate = delegate
    }

    public func requestAlwaysAuthorization() {
        locationProvider.requestAlwaysAuthorization()
    }

    public func requestWhenInUseAuthorization() {
        locationProvider.requestWhenInUseAuthorization()
    }

    @available(iOS 14.0, *)
    public func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {
        locationProvider.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
    }

    public func startUpdatingLocation() {
        locationProvider.startUpdatingLocation()
    }

    public func stopUpdatingLocation() {
        locationProvider.stopUpdatingLocation()
    }

    public func startUpdatingHeading() {
        locationProvider.startUpdatingHeading()
    }

    public func stopUpdatingHeading() {
        locationProvider.stopUpdatingHeading()
    }

    public func dismissHeadingCalibrationDisplay() {
        locationProvider.dismissHeadingCalibrationDisplay()
    }
}

extension AppleLocationProvider: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.locationProvider(self, didUpdateLocations: locations)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        delegate?.locationProvider(self, didUpdateHeading: heading)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationProvider(self, didFailWithError: error)
    }

    @available(iOS 14.0, *)
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        delegate?.locationProviderDidChangeAuthorization(self)
    }

    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        guard let calibratingDelegate = delegate as? CalibratingLocationProviderDelegate else {
            return false
        }

        return calibratingDelegate.locationProviderShouldDisplayHeadingCalibration(self)
    }
}
