import UIKit
import MapboxMaps
import CoreLocation

final class ViewAnnotationWithPointAnnotationExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var pointAnnotationManager: PointAnnotationManager!
    private var cancelables = Set<AnyCancelable>()
    private var annotation: ViewAnnotation?

    private let image = UIImage(named: "intermediate-pin")!
    private lazy var markerHeight: CGFloat = image.size.height

    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.7128, longitude: -75.0060)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 7))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        pointAnnotationManager = mapView.annotations.makePointAnnotationManager()

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let self = self else { return }

            try? self.mapView.mapboxMap.addImage(self.image, id: Constants.blueIconId)
            self.addPointAndViewAnnotation(at: self.mapView.mapboxMap.coordinate(for: self.mapView.center))

            // The below line is used for internal testing purposes only.
            self.finish()
        }.store(in: &cancelables)

        mapView.mapboxMap.addInteraction(TapInteraction { [weak self] context in
            if let self, self.annotation == nil {
                self.addViewAnnotation(at: context.coordinate)
            }
            return false
        })

        mapView.mapboxMap.styleURI = .streets
    }

    // MARK: - Annotation management

    private func addPointAndViewAnnotation(at coordinate: CLLocationCoordinate2D) {
        addPointAnnotation(at: coordinate)
        addViewAnnotation(at: coordinate)
    }

    private func addPointAnnotation(at coordinate: CLLocationCoordinate2D) {
        var pointAnnotation = PointAnnotation(id: Constants.markerId, coordinate: coordinate)
        pointAnnotation.iconImage = Constants.blueIconId
        pointAnnotation.iconAnchor = .bottom
        pointAnnotation.iconOffset = [0, 12]

        pointAnnotationManager.annotations.append(pointAnnotation)
    }

    // Add a view annotation at a specified location and optionally bind it to an ID of a marker
    private func addViewAnnotation(at coordinate: CLLocationCoordinate2D) {
        let annotationView = AnnotationView(frame: CGRect(x: 0, y: 0, width: 128, height: 64))
        annotationView.title = String(format: "lat=%.2f\nlon=%.2f", coordinate.latitude, coordinate.longitude)
        let annotation = ViewAnnotation(
            annotatedFeature: .layerFeature(layerId: pointAnnotationManager.layerId, featureId: Constants.markerId),
            view: annotationView)
        annotation.variableAnchors = [ViewAnnotationAnchorConfig(anchor: .bottom, offsetY: markerHeight - 12)]
        annotationView.onClose = { [weak self, weak annotation] in
            annotation?.remove()
            self?.annotation = nil
        }
        annotationView.onSelect = { [weak annotation] _ in
            annotation?.setNeedsUpdateSize()
        }
        self.annotation = annotation

        mapView.viewAnnotations.add(annotation)
    }
}

extension ViewAnnotationWithPointAnnotationExample {
    private enum Constants {
        static let blueIconId = "blue"
        static let markerId = UUID().uuidString
    }
}
