import UIKit
import MapboxMaps
import Turf
import Foundation

@objc(SnapshotterRuntimeStylingExample)
public class SnapshotterRuntimeStylingExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var snapshotter: Snapshotter!
    internal var snapshotView: UIImageView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Create a vertical stack view to hold both the map view and the snapshot.
        let stackView = UIStackView(frame: view.safeAreaLayoutGuide.layoutFrame)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 12.0

        let testRect = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height / 2)
        mapView = MapView(with: testRect, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.style.styleURL = .dark
        mapView.cameraManager.setCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 37.858, longitude: 138.472),
                                                  zoom: 3.5)

        // Add the `MapViewController`'s view to the stack view as a
        // child view controller.
        stackView.addArrangedSubview(mapView)

        // Add the image view to the stack view, which will eventually contain the snapshot.
        snapshotView = UIImageView(frame: CGRect.zero)
        stackView.addArrangedSubview(snapshotView)

        // Add the stack view to the root view.
        view.addSubview(stackView)

        // Add button to take snapshot
        let buttonText = "Take Snapshot"
        let button = UIButton(frame: CGRect(x: mapView.bounds.width / 2 - 60, y: mapView.bounds.height - 50, width: 150, height: 40))
        button.layer.cornerRadius = 15
        button.backgroundColor = UIColor.blue
        button.addTarget(self, action: #selector(startSnapshot), for: .touchUpInside)
        button.setTitle(buttonText, for: .normal)
        view.addSubview(button)
    }

    // Parse geoJSON file to return FeatureCollection
    internal func decodeGeoJSON(from fileName: String) throws -> FeatureCollection? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "geojson") else {
            preconditionFailure("file '\(fileName)' not found")
        }
        let filePath = URL(fileURLWithPath: path)
        var featureCollection: FeatureCollection?
        do {
            let data = try Data(contentsOf: filePath)
            featureCollection = try GeoJSON.parse(FeatureCollection.self, from: data)
        } catch {
            print("Error parsing data: \(error)")
        }
        return featureCollection
    }

    internal func addGeoJSONShape() {
        // Try to decode GeoJSON from file bundled with application
        guard let featurecollection = try? decodeGeoJSON(from: "JapanGeoJSON") else { return }
        let geoJSONSourceIdentifier = "geoJSON-data-source"

        // Create a GeoJSON Source
        var geoJSONSource = GeoJSONSource()
        geoJSONSource.data = .featureCollection(featurecollection)

        // Create a line layer
        var lineLayer = LineLayer(id: "line-layer")
        lineLayer.filter = Exp(.eq) {
            "$type"
            "LineString"
        }

        // Set the source
        lineLayer.source = geoJSONSourceIdentifier

        // Style the line
        lineLayer.paint?.lineColor = .constant(ColorRepresentable(color: UIColor.blue))
        lineLayer.paint?.lineWidth = .constant(4)
        lineLayer.layout?.lineCap = .round
        lineLayer.layout?.lineJoin = .round

        // Add the geoJSON source and then the layer to the snappshot
        snapshotter.style.addSource(source: geoJSONSource, identifier: geoJSONSourceIdentifier)
        snapshotter.style.addLayer(layer: lineLayer, layerPosition: nil)
    }

    @objc public func startSnapshot() {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: self.snapshotView.center.x - 30, y: self.snapshotView.center.y - 30, width: 60, height: 60))
        view.addSubview(indicator)
        indicator.startAnimating()

        // Configure the snapshotter object with its default access,
        // size, map style, and camera.
        let options = MapSnapshotOptions(size: CGSize(width: view.bounds.size.width,
                                                      height: view.bounds.height / 2),
                                         resourceOptions: resourceOptions())
        self.snapshotter = Snapshotter(options: options)
        self.snapshotter.style.styleURL = mapView.style.styleURL
        self.snapshotter.camera = mapView.cameraView.camera

        // Wait for the snapshotter's style to finish loading before decoding and adding the geoJSON
        self.snapshotter.on(.styleLoadingFinished) { _ in
            self.addGeoJSONShape()
        }

        snapshotter.start(overlayHandler: nil) { ( result ) in
            switch result {
            case .success(let image):
                self.snapshotView.image = image
                indicator.stopAnimating()
            case .failure(let error):
                print("Error generating snapshot: \(error)")
            }
            // The below line is used for internal testing purposes only.
            self.finish()
        }
    }
}
