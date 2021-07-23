import MapboxMaps
import Turf

@objc(LiveDataExample)
class LiveDataExample: UIViewController, ExampleProtocol {
    let url = URL(string: "https://wanderdrone.appspot.com/")!
    let sourceId = "drone-source"
    var mapView: MapView!
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
            droneTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.parseGeoJSON { result in
                    switch result {
                    case .success(let feature):
                        try! self.mapView.mapboxMap.style.updateGeoJSONSource(withId: self.sourceId, geoJSON: feature)
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            print("Failed to update the style. Error: \(error.localizedDescription)")
        }
    }

    func parseGeoJSON(completion: @escaping (Result<Turf.Feature, Error>) -> Void) {
        DispatchQueue.global().async { [url] in
            let result: Result<Turf.Feature, Error>
            do {
                let data = try Data(contentsOf: url)
                let feature = try JSONDecoder().decode(Turf.Feature.self, from: data)
                result = .success(feature)
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
