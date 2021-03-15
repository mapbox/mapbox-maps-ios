import UIKit
import MapboxMaps
import MapboxCoreMaps
import MapboxCommon

@objc(TrackingModeExample)

public class TrackingModeExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var cameraLocationConsumer: CameraLocationConsumer!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions(), styleURL: StyleURL.streets)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        cameraLocationConsumer = CameraLocationConsumer(shouldTrackLocation: true, mapView: mapView)

        // Add user position icon to the map with location indicator layer
        mapView.update { (mapOptions) in
            mapOptions.location.showUserLocation = true
        }

        // Set initial camera settings
        mapView.cameraManager.setCamera(zoom: 15.0)

        // Allows the delegate to receive information about map events.
        mapView.on(.mapLoadingFinished) { [weak self] _ in
            guard let self = self else { return }

            // Register the location consumer with the map
            // Note that the location manager holds weak references to consumers, which should be retained
            self.mapView.locationManager.addLocationConsumer(newConsumer: self.cameraLocationConsumer)

            self.finish() // Needed for internal testing purposes.
        }
    }
}

// Create class which conforms to LocationConsumer, update the camera's centerCoordinate when a locationUpdate is received
public class CameraLocationConsumer: LocationConsumer {
    public var shouldTrackLocation: Bool

    weak var mapView: MapView?

    init(shouldTrackLocation: Bool, mapView: MapView) {
        self.shouldTrackLocation = shouldTrackLocation
        self.mapView = mapView
    }

    public func locationUpdate(newLocation: Location) {
        mapView?.cameraManager.setCamera(centerCoordinate: newLocation.coordinate, zoom: 15, animated: true, duration: 1.3)
    }
}
