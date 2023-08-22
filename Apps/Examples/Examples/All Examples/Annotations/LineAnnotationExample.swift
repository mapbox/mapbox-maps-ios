import UIKit
import MapboxMaps

final class LineAnnotationExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), zoom: 2)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .streets)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in

            // Set up the example
            self?.setupExample()

            // The below line is used for internal testing purposes only.
            self?.finish()
        }.store(in: &cancelables)
    }

    private func setupExample() {

        var annotations = [PolylineAnnotation]()
        let coordinates = [
            CLLocationCoordinate2DMake(-2.178992, -4.375974),
            CLLocationCoordinate2DMake(-4.107888, -7.639772),
            CLLocationCoordinate2DMake(2.798737, -11.439207)
        ]
        var lineAnnotation = PolylineAnnotation(lineCoordinates: coordinates)
        lineAnnotation.lineColor = StyleColor(.red)
        lineAnnotation.lineWidth = 5.0
        annotations.append(lineAnnotation)

        // random add lines across the globe
        var randomCoordinates = [CLLocationCoordinate2D]()
        for _ in 0..<400 {
            randomCoordinates.append(.random)
        }

        for chunk in randomCoordinates.chunked(into: 8) {
            // Create the line annotation.
            var randomAnnotation = PolylineAnnotation(lineCoordinates: chunk)

            // Customize the style of the line annotation
            randomAnnotation.lineColor = StyleColor(red: .random(in: 0...255),
                                                    green: .random(in: 0...255),
                                                    blue: .random(in: 0...255),
                                                    alpha: 1)

            annotations.append(randomAnnotation)
        }

        // Create the PolylineAnnotationManager responsible for managing
        // this line annotations (and others if you so choose).
        // Annotation managers are kept alive by `AnnotationOrchestrator`
        // (`mapView.annotations`) until you explicitly destroy them
        // by calling `mapView.annotations.removeAnnotationManager(withId:)`
        let lineAnnnotationManager = mapView.annotations.makePolylineAnnotationManager(
            // position line annotations layer in a way that line annotations clipped at land borders
            layerPosition: .below("pitch-outline")
        )

        // Sync the annotation to the manager.
        lineAnnnotationManager.annotations = annotations
    }
}
