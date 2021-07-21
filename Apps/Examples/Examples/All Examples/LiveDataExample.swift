import MapboxMaps
import Turf

@objc(LiveDataExample)

class LiveDataExample: UIViewController, ExampleProtocol {
    var mapView: MapView!
    let sourceId = "drone-source"
    var droneTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapInitOptions = MapInitOptions(cameraOptions: CameraOptions(zoom: 0))
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        view.addSubview(mapView)

        // Add the live data layer once the map has finished loading.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addStyleLayer()
        }
    }

    func addStyleLayer() {
        // Set the data for the `GeoJSONSource`. This URL simulates paths
        // for drones.
        guard let url = URL(string: "https://wanderdrone.appspot.com/") else { return }
        var source = GeoJSONSource()
        source.data = .url(url)

        var rocketLayer = SymbolLayer(id: "rocket-layer")
        rocketLayer.source = sourceId
        // Mapbox Streets contains an image named `rocket-15`. Use that image
        // to represent the drone location.
        rocketLayer.iconImage = .constant(.name("rocket-15"))

        do {
            try mapView.mapboxMap.style.addSource(source, id: sourceId)
            try mapView.mapboxMap.style.addLayer(rocketLayer)
            // Create a `Timer` that updates the `GeoJSONSource`.
            droneTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                self.parseGeoJSON { result in
                    switch result {
                    case .success(let feature):
                       try! self.mapView.mapboxMap.style.updateGeoJSONSource(withId: self.sourceId, geoJSON: feature)
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }
            })
        } catch {
            print("Failed to update the style. Error: \(error.localizedDescription)")
        }
    }

    func parseGeoJSON(completion: @escaping(Result<Turf.Feature, Error>)->()) {
        let url = URL(string: "https://wanderdrone.appspot.com/")!

        DispatchQueue.global().async {
            let result: Result<Turf.Feature, Error>
            do {
                // Parse the geoJSON from the URL. An example response:
                // {"geometry": {"type": "Point", "coordinates": [-50.26804118917149, 38.76944015557226]}, "type": "Feature", "properties": {}}
                let data = try Data(contentsOf: url)

                if let geoJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let geometry = geoJSON["geometry"] as? [String: Any],
                   let coordinates = geometry["coordinates"] as? Array<Double> {
                    let location = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])

                    // Create a `Turf.Point` and `Turf.Feature` from the geoJSON data.
                    let point = Point(location)
                    let feature = Feature.init(geometry: Turf.Geometry.point(point))
                    result = .success(feature)
                } else {
                    let error = TypeConversionError.invalidObject
                    result = .failure(error)
                }
            } catch {
                result = .failure(error)
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        droneTimer?.invalidate()
        droneTimer = nil
    }
}
