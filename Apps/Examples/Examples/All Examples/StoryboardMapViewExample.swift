import UIKit
import MapboxMaps

@objc(StoryboardMapViewExample)

public class StoryboardMapViewExample: UIViewController, MapInitOptionsProvider, ExampleProtocol {

    public func mapInitOptions() -> MapInitOptions {
        let resourceOptions = ResourceOptions(accessToken: ResourceOptionsManager.default.resourceOptions.accessToken)
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 40.728, longitude: -74.0060), zoom: 10)

        //return a custom MapInitOptions
       return MapInitOptions(
            resourceOptions: resourceOptions,
            cameraOptions: cameraOptions,
            styleURI: .light)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

}
