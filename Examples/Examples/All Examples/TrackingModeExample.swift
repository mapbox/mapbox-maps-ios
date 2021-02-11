import UIKit
import MapboxMaps
import MapboxCoreMaps
import MapboxCommon

@objc(TrackingModeExample)

public class TrackingModeExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        self.view.addSubview(mapView)

        // Set the map's style
        mapView.style.styleURL = StyleURL.streets

        // Add user position icon to the map with location indicator layer
        mapView.update { (mapOptions) in
            mapOptions.location.showUserLocation = true
        }

        // Set initial camera settings
        let startingCoordinate = CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)
        mapView.cameraManager.setCamera(centerCoordinate: startingCoordinate,
                                                   zoom: 15.0)

        // Create class which conforms to LocationConsumer, update the camera's centerCoordinate when a locationUpdate is received
        class CameraLocationConsumer: LocationConsumer {
            var shouldTrackLocation: Bool

            // To access mapView
            let parent: TrackingModeExample

            func locationUpdate(newLocation: Location) {
                parent.mapView.cameraManager.setCamera(centerCoordinate: newLocation.coordinate, zoom: 15, animated: true, duration: 1.3)
            }

            init(shouldTrackLocation: Bool, parent: TrackingModeExample) {
                self.shouldTrackLocation = shouldTrackLocation
                self.parent = parent
            }
        }

        let cameraLocationConsumer = CameraLocationConsumer(shouldTrackLocation: true, parent: self)

        // Allows the delegate to receive information about map events.
        mapView.on(.mapLoadingFinished) { [weak self] _ in
            guard let self = self else { return }

            // Register the location consumer with the map
            self.mapView.locationManager.addLocationConsumer(newConsumer: cameraLocationConsumer)
            self.finish() // Needed for internal testing purposes.
        }
    }
}
