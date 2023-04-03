import MapboxMaps
import UIKit

private extension String {
    static let blueMarker = "blue-marker"
}

// This examples shows how to animate camera to a long-tapped coordinate.
public class LongTapAnimationExample: UIViewController, ExampleProtocol {
    internal var mapView: MapView!
    private var pointAnnotationManager: PointAnnotationManager!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Center the map over the United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.368279,
                                                      longitude: -97.646484)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 2.4))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            self.setupExample()

            // The following line is just for testing purposes.
            self.finish()
        }
        pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
    }

    func setupExample() {
        try! mapView.mapboxMap.style.addImage(UIImage(named: "blue_marker_view")!, id: .blueMarker)
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        mapView.addGestureRecognizer(tapGesture)
    }

    @objc public func longPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            longPressBegan(at: sender.location(in: mapView))
        default:
            break
        }
    }

    private func longPressBegan(at location: CGPoint) {
        haptic()
        let coordinate = mapView.mapboxMap.coordinate(for: location)

        var annotation = PointAnnotation(point: Point(coordinate))
        annotation.iconImage = .blueMarker
        pointAnnotationManager.annotations.append(annotation)

        let camera = CameraOptions(center: coordinate)
        mapView.camera.ease(to: camera, duration: 0.5)
    }

    private func haptic() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackGenerator.impactOccurred()
    }
}
