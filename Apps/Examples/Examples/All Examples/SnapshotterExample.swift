import UIKit
import MapboxMaps

@objc(SnapshotterExample)

public class SnapshotterExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    public var snapshotter: Snapshotter!
    public var snapshotView: UIImageView!
    private var snapshotting = false

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Create a vertical stack view to hold both the map view and the snapshot.
        let stackView = UIStackView(frame: view.safeAreaLayoutGuide.layoutFrame)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 12.0

        let testRect = CGRect(x: 0, y: 0, width: view.bounds.width/2, height: view.bounds.height / 2)

        let mapInitOptions = MapInitOptions(cameraOptions: CameraOptions(center: CLLocationCoordinate2D(latitude: 50, longitude: 138.482),
                                                                         zoom: 3.5),
                                            styleURI: .dark)

        mapView = MapView(frame: testRect, mapInitOptions: mapInitOptions)
        // Add the `MapViewController`'s view to the stack view as a
        // child view controller.
        stackView.addArrangedSubview(mapView)

        // Add the image view to the stack view, which will eventually contain the snapshot.
        let stackViewBounds = CGRect(x: 0,
                                     y: 0,
                                     width: view.bounds.size.width,
                                     height: view.bounds.height / 2)
        snapshotView = UIImageView(frame: stackViewBounds)
        stackView.addArrangedSubview(snapshotView)

        NSLayoutConstraint.activate([
            mapView.widthAnchor.constraint(equalToConstant: view.bounds.size.width),
            snapshotView.widthAnchor.constraint(equalToConstant: stackViewBounds.width)
        ])

        // Add the stack view to the root view.
        view.addSubview(stackView)

        // Configure the snapshotter object with its default access
        // token, size, map style, and camera.
        let options = MapSnapshotOptions(
            size: stackViewBounds.size,
            pixelRatio: UIScreen.main.scale,
            resourceOptions: mapInitOptions.resourceOptions)

        snapshotter = Snapshotter(options: options)
        snapshotter.style.uri = .light

        // Set the camera of the snapshotter

        mapView.mapboxMap.onEvery(.mapIdle) { [weak self] _ in
            guard let self = self, !self.snapshotting else {
                return
            }

            let snapshotterCameraOptions = CameraOptions(cameraState: self.mapView.cameraState)
            self.snapshotter.setCamera(to: snapshotterCameraOptions)
            self.startSnapshot()
        }
    }

    public func startSnapshot() {
        snapshotting = true
        snapshotter.start(overlayHandler: nil) { ( result ) in
            switch result {
            case .success(let image):
                self.snapshotView.image = image
            case .failure(let error):
                print("Error generating snapshot: \(error)")
            }
            self.snapshotting = false
            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }
}
