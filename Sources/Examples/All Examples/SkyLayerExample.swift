import UIKit
import MapboxMaps

final class SkyLayerExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var skyLayer: SkyLayer!
    private var segmentedControl = UISegmentedControl()
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the initial camera and style URI by creating a `MapInitOptions` object.
        let center = CLLocationCoordinate2D(latitude: 35.67283, longitude: 127.60597)
        let cameraOptions = CameraOptions(center: center, zoom: 12.5, pitch: 83)
        var styleURI: StyleURI?
        if let url = URL(string: "mapbox://styles/mapbox-map-design/ckhqrf2tz0dt119ny6azh975y") {
            styleURI = StyleURI(url: url)
        }
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: styleURI ?? .satelliteStreets)

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        // Add a `UISegmentedControl` that toggles the sky layer type between `gradient` and `atmosphere`.
        addSegmentedControl()

        // Add a custom `SkyLayer` once the map's style is finished loading.
        mapView.mapboxMap.onStyleLoaded.observeNext { _ in
            self.addSkyLayer()

            // Add a terrain layer.
            self.addTerrainLayer()

            self.finish()
        }.store(in: &cancelables)
    }

    func addSkyLayer() {
        // Initialize a sky layer with a sky type of `gradient`, which applies a gradient effect to the sky.
        // Read more about sky layer types on the Mapbox blog: https://www.mapbox.com/blog/sky-api-atmospheric-scattering-algorithm-for-3d-maps
        skyLayer = SkyLayer(id: "sky-layer")
        skyLayer.skyType = .constant(.gradient)

        // Define the position of the sun.
        // The azimuthal angle indicates the sun's position relative to 0 degrees north. When the map's bearing
        // is `0` and the azimuthal angle is `0`, the sun will appear horizontally centered.
        let azimuthalAngle: Double = 0

        // Indicates the sun's position relative to the horizon. A value of `90` places the sun's center at the
        // horizon line. Lower values place the sun below the horizon line, while higher values place the sun's
        // center further above the horizon line.
        let polarAngle: Double = 90
        skyLayer.skyAtmosphereSun = .constant([azimuthalAngle, polarAngle])

        // The intensity or brightness of the sun.
        skyLayer.skyAtmosphereSunIntensity = .constant(10)

        // Set the sky's color to light blue with a light pink halo effect.
        skyLayer.skyAtmosphereColor = .constant(StyleColor(.skyBlue))
        skyLayer.skyAtmosphereHaloColor = .constant(StyleColor(.lightPink))

        do {
            try mapView.mapboxMap.addLayer(skyLayer)
        } catch {
            print("Failed to add sky layer to the map's style.")
        }
    }

    // Update the sky type when the `UISegmentedControl` value is changed.
    @objc func updateSkyLayer() {
        var skyType: Value<SkyType>
        if segmentedControl.selectedSegmentIndex == 0 {
            skyType = .constant(.gradient)
        } else {
            skyType = .constant(.atmosphere)
        }

        // Update the sky layer based on the updated segmented control value.
        do {
            try mapView.mapboxMap.updateLayer(withId: skyLayer.id, type: SkyLayer.self) { layer in
                layer.skyType = skyType
            }
        } catch {
            print("Failed to update the sky type for layer with id \(skyLayer.id).")
        }
    }

    func addTerrainLayer() {
        // Add a `RasterDEMSource`. This will be used to create and add a terrain layer.
        var demSource = RasterDemSource(id: "mapbox-dem")
        demSource.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
        demSource.tileSize = 514
        demSource.maxzoom = 14.0
        try! mapView.mapboxMap.addSource(demSource)

        var terrain = Terrain(sourceId: demSource.id)
        terrain.exaggeration = .constant(1.5)

        do {
            try mapView.mapboxMap.setTerrain(terrain)
        } catch {
            print("Failed to add a terrain layer to the map's style.")
        }
    }

    func addSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["Gradient", "Atmosphere"])
        segmentedControl.backgroundColor = .lightGray
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(updateSkyLayer), for: .valueChanged)
        view.insertSubview(segmentedControl, aboveSubview: mapView)

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            segmentedControl.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -80),
            segmentedControl.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
        ])
    }
}

// An extension to store sky color values.
extension UIColor {
    static var skyBlue: UIColor {
        return UIColor(red: 0.53, green: 0.81, blue: 0.92, alpha: 1.00)
    }

    static var lightPink: UIColor {
        return UIColor(red: 1.00, green: 0.82, blue: 0.88, alpha: 1.00)
    }
}
