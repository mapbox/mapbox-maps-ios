import MapboxMaps

@objc(LiveDataExample)
final class LiveDataExample: UIViewController, ExampleProtocol {
    // Display the current location of the International Space Station (ISS)
    let url = URL(string: "https://api.wheretheiss.at/v1/satellites/25544")!
    let sourceId = "ISS-source"
    var mapView: MapView!
    var issTimer: Timer?

    struct Coordinates: Codable {
        let longitude: Double
        let latitude: Double
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up map and camera
        let centerCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let camera = CameraOptions(center: centerCoordinate, zoom: 1)
        let mapInitOptions = MapInitOptions(cameraOptions: camera, styleURI: .streets)

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        view.addSubview(mapView)

        // Add the live data layer once the map has finished loading.
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addStyleLayer()
        }
    }

    func addStyleLayer() {
        // Create an empty geoJSON source to hold location data once
        // this information is received from the URL
        var source = GeoJSONSource()
        source.data = .empty

        var issLayer = SymbolLayer(id: "iss-layer")
        issLayer.source = sourceId

        // Mapbox Streets contains an image named `rocket-15`. Use that image
        // to represent the location of the ISS.
        issLayer.iconImage = .constant(.name("rocket-15"))

        do {
            try mapView.mapboxMap.style.addSource(source, id: sourceId)
            try mapView.mapboxMap.style.addLayer(issLayer)

            // Create a `Timer` that updates the `GeoJSONSource`.
            issTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.parseJSON { result in

                    switch result {
                    case .success(let coordinates):
                        let locationCoordinates = LocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)

                        // Update geoJSON source to display new location of ISS
                        let point = Point(locationCoordinates)
                        let pointFeature = Feature(geometry: point)
                        try! self.mapView.mapboxMap.style.updateGeoJSONSource(withId: self.sourceId, geoJSON: .feature(pointFeature))

                        // Update camera to follow ISS
                        let issCamera = CameraOptions(center: locationCoordinates, zoom: 3)
                        self.mapView.camera.ease(to: issCamera, duration: 1)

                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            print("Failed to update the style layer. Error: \(error.localizedDescription)")
        }
    }

    // Make a request to the ISS URL, decode the JSON, and return the new coordinates
    func parseJSON(completion: @escaping (Result<Coordinates, Error>) -> Void) {
        DispatchQueue.global().async { [url] in
            let result: Result<Coordinates, Error>
            do {
                let data = try Data(contentsOf: url)
                let coordinates = try JSONDecoder().decode(Coordinates.self, from: data)
                result = .success(coordinates)
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
        issTimer?.invalidate()
        issTimer = nil
    }
}
