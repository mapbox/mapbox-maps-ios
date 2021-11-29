import UIKit
@_spi(Experimental) import MapboxMaps

@objc(SnapshotterExample)

public class SnapshotterExample: UIViewController, ExampleProtocol {
    internal var mapView: MapView!
    public var snapshotter: Snapshotter!
    public var snapshotView: UIImageView!
    private var snapshotting = false
    static private let poiLabelId = "poi-label"

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Create a vertical stack view to hold both the map view and the snapshot.
        let stackView = UIStackView(frame: view.safeAreaLayoutGuide.layoutFrame)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 12.0

        let mapViewRect = CGRect(x: 0, y: 0, width: view.bounds.width/2, height: view.bounds.height / 2)

        let mapInitOptions = MapInitOptions(
            mapOptions: MapOptions(),
            cameraOptions: CameraOptions(
                center: CLLocationCoordinate2D(
                    latitude: 59.3464707,
                    longitude: 18.0600796),
                zoom: 19),
            styleURI: StyleURI.streets)

        mapView = MapView(frame: mapViewRect, mapInitOptions: mapInitOptions)
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
            snapshotView.widthAnchor.constraint(equalToConstant: stackViewBounds.width),
            snapshotView.heightAnchor.constraint(equalToConstant: stackViewBounds.height)
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
        snapshotter.style.uri = StyleURI.streets
        mapView.mapboxMap.loadStyleURI(StyleURI.streets) { result in
            guard case .success = result else {
                print("Failed loading style")
                return
            }

            // Updating style based on feature state
            do {
                try self.mapView.mapboxMap.style.updateLayer(
                    withId: Self.poiLabelId,
                    type: SymbolLayer.self) { (layer: inout SymbolLayer) in
                    layer.iconOpacity = .expression(
                        Exp(.switchCase) {
                            Exp(.boolean) {
                                Exp(.featureState) { "selected" }
                                false
                            }
                            0
                            1
                        }
                    )
//                    layer.textOpacity = .expression(
//                        Exp(.switchCase) {
//                            Exp(.boolean) {
//                                Exp(.featureState) { "selected" }
//                                false
//                            }
//                            0
//                            1
//                        }
//                    )
                }
            } catch {
                print("Error updating layer: \(error)")
            }

            if let layer = try? self.mapView.mapboxMap.style.layer(withId: Self.poiLabelId) as? SymbolLayer,
               let iconSourceName = layer.source,
               let iconSourceLayerId = layer.sourceLayer
            {
                print("Updating feature state")

                let featureIdentifier = 30705936810
                // Setting the feature state without this short delay will make it stop working. It appears that the updating of the style of another layer in the same style voids this setting of featureState
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                   self.mapView.mapboxMap.setFeatureState(
                    sourceId: iconSourceName,
                    sourceLayerId: iconSourceLayerId,
                    featureId: "\(Int(featureIdentifier))",
                    state: ["selected": true])
                }
            }
        }
        
        mapView.mapboxMap.onEvery(.mapIdle) { [weak self] _ in
            guard let image = try? self?.mapView.snapshot() else {
                return
            }
            self?.snapshotView.image = image
        }
        
//        mapView.mapboxMap.onEvery(.mapIdle) { [weak self] _ in
//            // Allow the previous snapshot to complete before starting a new one.
//            guard let self = self, !self.snapshotting else {
//                return
//            }
//
//            let snapshotterCameraOptions = CameraOptions(cameraState: self.mapView.cameraState)
//            self.snapshotter.setCamera(to: snapshotterCameraOptions)
//            self.startSnapshot()
//        }
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
