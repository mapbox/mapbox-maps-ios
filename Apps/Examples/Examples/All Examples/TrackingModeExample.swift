import UIKit
import MapboxMaps

@objc(TrackingModeExample)

public class TrackingModeExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var cameraLocationConsumer: CameraLocationConsumer!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Set initial camera settings
        let options = MapInitOptions(cameraOptions: CameraOptions(zoom: 15.0))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        cameraLocationConsumer = CameraLocationConsumer(mapView: mapView)

        // Add user position icon to the map with location indicator layer
        mapView.location.options.puckType = .puck2D()

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            // Register the location consumer with the map
            // Note that the location manager holds weak references to consumers, which should be retained
            self.mapView.location.addLocationConsumer(newConsumer: self.cameraLocationConsumer)

            self.finish() // Needed for internal testing purposes.
        }
    }
}

// Create class which conforms to LocationConsumer, update the camera's centerCoordinate when a locationUpdate is received
public class CameraLocationConsumer: LocationConsumer {
    weak var mapView: MapView?

    init(mapView: MapView) {
        self.mapView = mapView
    }

    public func locationUpdate(newLocation: Location) {
        mapView?.camera.ease(
            to: CameraOptions(center: newLocation.coordinate, zoom: 15),
            duration: 1.3)
    }
}
