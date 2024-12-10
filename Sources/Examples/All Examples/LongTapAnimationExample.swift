import MapboxMaps
import UIKit

// This examples shows how to animate camera to a long-tapped coordinate.
final class LongTapAnimationExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var pointAnnotationManager: PointAnnotationManager!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Center the map over the United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.368279,
                                                      longitude: -97.646484)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 2.4))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            try? self?.mapView.mapboxMap.addImage(UIImage(named: "intermediate-pin")!, id: .blueMarker)

            // The following line is just for testing purposes.
            self?.finish()
        }.store(in: &cancelables)

        mapView.gestures.onMapLongPress.observe { [weak self] context in
            self?.handleLongPress(at: context.point)
        }.store(in: &cancelables)

        pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
    }

    private func handleLongPress(at location: CGPoint) {
        haptic()
        let coordinate = mapView.mapboxMap.coordinate(for: location)

        var annotation = PointAnnotation(point: Point(coordinate))
        annotation.iconImage = .blueMarker
        annotation.iconOffset = [0, 12]
        pointAnnotationManager.annotations.append(annotation)

        let camera = CameraOptions(center: coordinate)
        mapView.camera.ease(to: camera, duration: 0.5)
    }

    private func haptic() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackGenerator.impactOccurred()
    }
}

private extension String {
    static let blueMarker = "blue-marker"
}
