import UIKit
import MapboxMaps

public class StoryboardMapViewExample: UIViewController, MapInitOptionsProvider, ExampleProtocol {

    public func mapInitOptions() -> MapInitOptions {
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 40.728, longitude: -74.0060), zoom: 10)

        //return a custom MapInitOptions
       return MapInitOptions(
            cameraOptions: cameraOptions,
            styleURI: .light)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

}
