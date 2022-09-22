// Use pitch and distance-from-center expressions in the filter
// field of a symbol layer to remove large size POI labels in the far
// distance at high pitch, freeing up that screen real-estate for smaller road and street labels.

import Foundation
import MapboxMaps

@objc(PitchAndDistanceExample)
final class PitchAndDistanceExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapInitOptions = MapInitOptions(
            cameraOptions: CameraOptions(
                center: CLLocationCoordinate2D(
                    latitude: 38.888,
                    longitude: -77.01866),
                zoom: 15,
                pitch: 75),
            styleURI: StyleURI.streets)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.ornaments.options.scaleBar.visibility = .visible

        view.addSubview(mapView)
        // Wait for the map to load its style before setting the filter.
        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            self.setPitchDistanceFilter()

            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }

    // Add an additional condition to the current filter
    // to filter based on ["pitch"] and ["distance-from-center"]
    func updateFilter(currentFilter: Expression) -> Expression {
        let updatedFilter = Exp(.all) {
            currentFilter
            Exp(.switchCase) {
                // Always show the symbol when pitch <= 60
                Exp(.lte) {
                    Exp(.pitch)
                    60
                }
                true
                // When pitch > 60, show the symbol only
                // when it is close to the camera ( distance <= 2 )
                Exp(.lte) {
                    Exp(.distanceFromCenter)
                    2
                }
                true
                // Hide in the remaining case, far and high pitch
                false
            }
        }
        return updatedFilter
    }

    func setPitchDistanceFilter() {
        let poiLayers = ["poi-label", "transit-label"]

        for layerID in poiLayers {
            do {
                try mapView.mapboxMap.style.updateLayer(withId: layerID, type: SymbolLayer.self, update: { (layer: inout SymbolLayer) in
                    layer.filter = layer.filter.map(updateFilter(currentFilter: ))
                })
            } catch {
                print("Updating the layer '\(layerID)' failed: \(error.localizedDescription)")
            }
        }
    }
}
