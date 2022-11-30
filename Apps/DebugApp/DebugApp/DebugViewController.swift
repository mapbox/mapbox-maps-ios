import UIKit
import MapboxMaps

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

final class DebugViewController: UIViewController {

    var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let initialPosition = CLLocationCoordinate2D(latitude: 38.88168, longitude: -76.92046)
        let cameraOptions = CameraOptions(center: initialPosition, zoom: 17)
        let initOptions = MapInitOptions(cameraOptions: cameraOptions)
        mapView.mapboxMap.setCamera(to: cameraOptions)
        view.insertSubview(mapView, at: 0)

        let lineStringCoordinates = [
            CLLocationCoordinate2D(latitude: 38.881425269736525, longitude: -76.92079259391846),
            CLLocationCoordinate2D(latitude: 38.88119141819894, longitude: -76.92103935714817),
            CLLocationCoordinate2D(latitude: 38.88096591777307, longitude: -76.92129684921323)
        ]

        LineString
        let lineString = LineString.init(lineStringCoordinates)

        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            self.drawLineString(lineString)
        }
    }

    private func drawLineString(_ lineString: LineString) {
        var geoJSONSource = GeoJSONSource()
        geoJSONSource.data = .geometry(Geometry(lineString))

        let geoJSONDataSourceIdentifier = "geoJSON-data-source"

        var lineLayer = LineLayer(id: "ride-path")

        lineLayer.source = geoJSONDataSourceIdentifier
        lineLayer.lineColor = .constant(StyleColor(.red))
        lineLayer.lineWidth = .constant(5.0)
        lineLayer.lineCap = .constant(.round)
        lineLayer.lineJoin = .constant(.round)

        DispatchQueue.main.async {
            try! self.mapView.mapboxMap.style.addLayer(lineLayer)
            try! self.mapView.mapboxMap.style.addSource(geoJSONSource, id: geoJSONDataSourceIdentifier)
//            let cameraOptions = CameraOptions(zoom: 17)
//            mapView.mapboxMap.camera(for: [], camera: cameraOptions, rect: <#T##CGRect#>)
//            self.fitCamera(to: lineString.coordinates)
        }
    }
}
