import UIKit
import MapboxMaps
import Turf

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

public class DebugViewController: UIViewController {

    internal var mapView: MapView!
    internal var runningAnimator: CameraAnimator?

    var resourceOptions: ResourceOptions {
        guard let accessToken = AccountManager.shared.accessToken else {
            fatalError("Access token not set")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        return resourceOptions
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions)
        mapView.update { (mapOptions) in
            mapOptions.location.puckType = .puck2D()
        }

        view.addSubview(mapView)

        /**
         The closure is called when style data has been loaded. This is called
         multiple times. Use the event data to determine what kind of style data
         has been loaded.
         
         When the type is `style` this event most closely matches
         `-[MGLMapViewDelegate mapView:didFinishLoadingStyle:]` in SDK versions
         prior to v10.
         */
        mapView.on(.styleDataLoaded) { (event) in
            guard let data = event.data as? [String: Any],
                  let type = data["type"] else {
                return
            }

            print("The map has finished loading style data of type = \(type)")
        }

        /**
         The closure is called during the initialization of the map view and
         after any `styleDataLoaded` events; it is called when the requested
         style has been fully loaded, including the style, specified sprite and
         source metadata.

         This event is the last opportunity to modify the layout or appearance
         of the current style before the map view is displayed to the user.
         Adding a layer at this time to the map may result in the layer being
         presented BEFORE the rest of the map has finished rendering.

         Changes to sources or layers of the current style do not cause this
         event to be emitted.
         */
        mapView.on(.styleLoaded) { (event) in
            print("The map has finished loading style ... Event = \(event)")
        }

        /**
         The closure is called whenever the map finishes loading and the map has
         rendered all visible tiles, either after the initial load OR after a
         style change has forced a reload.

         This is an ideal time to add any runtime styling or annotations to the
         map and ensures that these layers would only be shown after the map has
         been fully rendered.
         */
        mapView.on(.mapLoaded) { (event) in
            print("The map has finished loading... Event = \(event)")
            
            
            
            self.runTest()
        }

        /**
         The closure is called whenever the map has failed to load. This could
         be because of a variety of reasons, including a network connection
         failure or a failure to fetch the style from the server.

         You can use the associated error message to notify the user that map
         data is unavailable.
         */
        mapView.on(.mapLoadingError) { (event) in
            guard let data = event.data as? [String: Any],
                  let type = data["type"],
                  let message = data["message"] else {
                return
            }

            print("The map failed to load.. \(type) = \(message)")
        }
    }
    
    static var counter = 0
    
    func runTest() {
        let bearings: [(Double, Double)] = [
            (330.7222595214844, 344.0169982910156),
            (332.0651550292969, 357.12646484375),
            (334.2096252441406, 359.3537292480469),
            (336.25244140625, -0.0),
            (337.7581481933594, 347.4563903808594),
            (339.7362365722656, 355.0942077636719),
            (339.7362365722656, -0.0),
            (339.7362365722656, 358.5126037597656),
            (339.7362365722656, -0.0),
            (339.7362365722656, 359.1885986328125),
            (339.7362365722656, 359.3114929199219),
            (339.7362365722656, 359.5973205566406),
            (339.2138671875, 359.5579833984375),
            (336.46484375, 358.6362609863281),
            (335.15325927734375, -0.0),
            (332.86944580078125, 359.4662170410156)
        ]
        
        let initialCenter = CLLocationCoordinate2D(latitude: 39.01305735102963, longitude: -77.01570412528032)
        let co1 = CameraOptions(center: initialCenter, zoom: 16, bearing: bearings[Self.counter].0, pitch: 30)
        self.mapView.cameraManager.setCamera(to: co1)
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] (timer) in
            let co = CameraOptions(center: initialCenter, zoom: 16, bearing: bearings[Self.counter].0, pitch: 30)
            if Self.counter == bearings.count - 1 {
                Self.counter = 0
            } else {
                Self.counter += 1
            }
            
            self?.mapView.cameraManager.setCamera(to: co, animated: true, duration: 1)
            print("newbearing = \(co.bearing!), currentMapBearing = \(self!.mapView.bearing)")
        }
    }
}
