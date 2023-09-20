import MapboxMaps
import UIKit

final class PolygonAnnotationExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 25.04579, longitude: -88.90136)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 5.0))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { _ in
            self.setupExample()

            // The below line is used for internal testing purposes only.
            self.finish()
        }.store(in: &cancelables)
    }

    // Wait for the map to load before adding an annotation.
    private func setupExample() {

        // Create the PolygonAnnotationManager
        // Annotation managers are kept alive by `AnnotationOrchestrator`
        // (`mapView.annotations`) until you explicitly destroy them
        // by calling `mapView.annotations.removeAnnotationManager(withId:)`
        let polygonAnnotationManager = mapView.annotations.makePolygonAnnotationManager()

        // Create the polygon annotation
        var polygonAnnotation = PolygonAnnotation(polygon: makePolygon())

        // Style the polygon annotation
        polygonAnnotation.fillColor = StyleColor(.red)
        polygonAnnotation.fillOpacity = 0.8

        // Enable the polygon annotation to be dragged
        polygonAnnotation.isDraggable = true

        polygonAnnotation.tapHandler = { _ in
            print("polygon is tapped")
            return true
        }

        // Add the polygon annotation to the manager
        polygonAnnotationManager.annotations = [polygonAnnotation]
    }

    private func makePolygon() -> Polygon {

        // Describe the polygon's geometry
        let outerRingCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]

        // This polygon has an intererior polygon which represents a hole in the shape.
        let innerRingCoords = [
            CLLocationCoordinate2DMake(25.085598897064752, -89.20898437499999),
            CLLocationCoordinate2DMake(25.085598897064752, -88.61572265625),
            CLLocationCoordinate2DMake(25.720735134412106, -88.61572265625),
            CLLocationCoordinate2DMake(25.720735134412106, -89.20898437499999),
            CLLocationCoordinate2DMake(25.085598897064752, -89.20898437499999)
        ]

        /// Create the Polygon with the outer ring and inner ring
        let outerRing = Ring(coordinates: outerRingCoords)
        let innerRing = Ring(coordinates: innerRingCoords)

        return Polygon(outerRing: outerRing, innerRings: [innerRing])
    }
}
