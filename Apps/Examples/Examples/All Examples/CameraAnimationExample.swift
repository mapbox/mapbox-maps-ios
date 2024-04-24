import UIKit
import MapboxMaps

final class CameraAnimationExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 42.88, longitude: -78.870000), zoom: 6)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { _ in

            // Center the map camera over New York City.
            let centerCoordinate = CLLocationCoordinate2D(
                latitude: 40.7128, longitude: -74.0060)

            let newCamera = CameraOptions(center: centerCoordinate,
                                          zoom: 7.0,
                                          bearing: 180.0,
                                          pitch: 15.0)

            self.mapView.camera.ease(to: newCamera, duration: 5.0) { [weak self] (_) in
                // The below line is used for internal testing purposes only.
                self?.finish()
            }
        }.store(in: &cancelables)

        mapView.camera
            .onCameraAnimatorStarted
            .observe { animator in
                print("Animator started: \(animator.owner)")
            }
            .store(in: &cancelables)

        mapView.camera
            .onCameraAnimatorFinished
            .owned(by: .compass)
            .observe { animator in
                print("Animator finished: \(animator.owner)")
            }
            .store(in: &cancelables)
    }
}
