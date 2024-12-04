import MapboxMaps
import UIKit

final class LiveDataExample: UIViewController, ExampleProtocol {
    // Display the current location of the International Space Station (ISS)
    private let url = URL(string: "https://api.wheretheiss.at/v1/satellites/25544")!
    private var mapView: MapView!
    private var issTimer: Timer?
    private var cancelables = Set<AnyCancelable>()

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
        mapView.mapboxMap.onMapLoaded.observeNext { _ in
            self.addStyleLayer()

            // The following line is just for testing purposes.
            self.finish()
        }.store(in: &cancelables)
    }

    func addStyleLayer() {
        // Create an empty geoJSON source to hold location data once
        // this information is received from the URL
        let source = GeoJSONSource(id: "ISS-source")

        var issLayer = SymbolLayer(id: "iss-layer", source: source.id)

        // Mapbox Streets contains an image named `rocket`. Use that image
        // to represent the location of the ISS.
        issLayer.iconImage = .constant(.name("rocket"))

        do {
            try mapView.mapboxMap.addSource(source)
            try mapView.mapboxMap.addLayer(issLayer)

            // Create a `Timer` that updates the `GeoJSONSource`.
            issTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.parseJSON { [weak self] result in
                    guard let self = self else { return }

                    switch result {
                    case .success(let coordinates):
                        let locationCoordinates = LocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)

                        // Update geoJSON source to display new location of ISS
                        let point = Point(locationCoordinates)
                        let pointFeature = Feature(geometry: point)
                        self.mapView.mapboxMap.updateGeoJSONSource(withId: source.id, geoJSON: .feature(pointFeature))

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
