import UIKit
import MapboxMaps
import Turf
/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */
public class DebugViewController: UIViewController {
    var isLocationShown: Bool = true
    internal var mapView: MapView!
    var resourceOptions: ResourceOptions {
        guard let accessToken = AccountManager.shared.accessToken else {
            fatalError("Access token not set")
        }
        let resourceOptions = ResourceOptions(accessToken: accessToken)
        return resourceOptions
    }
    var button : UIButton!
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.mapView = MapView(with: view.bounds, resourceOptions: resourceOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
        self.mapView.on(.styleLoadingFinished) { [weak self] _ in
            guard let self = self else { return }
            self.setupExample()
        }
    }
    internal func setupExample() {
        mapView.locationManager.locationProvider.requestWhenInUseAuthorization()
        self.mapView.update { (mapOptions) in
            mapOptions.location.showUserLocation = true
        }
        let coordinate = CLLocationCoordinate2D(latitude: 39.085006, longitude: -77.150925)
        self.mapView.cameraManager.setCamera(centerCoordinate: coordinate,
                                             zoom: 7,
                                             pitch: 80)
        addButton()
    }
    private func addButton() {
        // Set up layer postion change button
        button = UIButton(type: .system)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9882352941, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(toggleVisibility), for: .touchUpInside)
        self.view.addSubview(button)
        // Set button location
        let horizontalConstraint = button.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                                                                  constant: -24)
        let verticalConstraint = button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 200)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 40)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    @objc func toggleVisibility() {
        
//        if mapView.locationManager.showUserLocation == true { // Not hit after initial run
        if isLocationShown {
            mapView.update { (mapOptions) in
                mapOptions.location.showUserLocation = false
                mapView.locationManager.locationProvider.stopUpdatingLocation()
            }
            button.backgroundColor = .purple
        } else {
            mapView.locationManager.locationProvider.startUpdatingLocation()
            mapView.update { (mapOptions) in
                mapOptions.location.showUserLocation = true
                mapView.locationManager.locationProvider.startUpdatingLocation()
            }
            button.backgroundColor = .white
        }
        isLocationShown = !isLocationShown
    }
}

