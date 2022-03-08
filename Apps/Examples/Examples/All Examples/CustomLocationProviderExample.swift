import Foundation
import MapboxMaps

@objc(CustomLocationProviderExample)
final class CustomLocationProviderExample: UIViewController, ExampleProtocol {

    var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.7131854, longitude: -74.0165265)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 10))
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        // initialize the custom location provoder with the location of your choice
        let customLocationProvider = CustomLocationProvider(currentLocation: CLLocation(latitude: 40.7131854, longitude: -74.0165265))
        mapView.location.overrideLocationProvider(with: customLocationProvider)
        mapView.location.options.puckType = .puck2D()
    }
}

class CustomLocationProvider: LocationProvider {
    var locationProviderOptions = LocationOptions()

    let authorizationStatus = CLAuthorizationStatus.authorizedAlways

    let accuracyAuthorization = CLAccuracyAuthorization.fullAccuracy

    let heading: CLHeading? = nil

    var headingOrientation = CLDeviceOrientation.portrait

    private let currentLocation: CLLocation

    private weak var delegate: LocationProviderDelegate?

    init(currentLocation: CLLocation) {
        self.currentLocation = currentLocation
    }

    func setDelegate(_ delegate: LocationProviderDelegate) {
        self.delegate = delegate
    }

    func startUpdatingLocation() {
        delegate?.locationProvider(self, didUpdateLocations: [currentLocation])
    }

    func requestAlwaysAuthorization() {
        // not required for this example
    }

    func requestWhenInUseAuthorization() {
        // not required for this example
    }

    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {
        // not required for this example
    }

    func stopUpdatingLocation() {
        // not required for this example
    }

    func startUpdatingHeading() {
        // not required for this example
    }

    func stopUpdatingHeading() {
        // not required for this example
    }

    func dismissHeadingCalibrationDisplay() {
        // not required for this example
    }
}
