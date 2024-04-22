import UIKit
@_spi(Experimental) import MapboxMaps

@objc(ModelLayerExample)
final class ModelLayerExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(
            center: mid(Constants.duckCoordinates.coordinates, Constants.mapboxHelsinki.coordinates),
            zoom: 16,
            pitch: 45
        )
        let options = MapInitOptions(cameraOptions: cameraOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.ornaments.options.scaleBar.visibility = .visible

        /// Create a Feature to hold the coordinates of the duck and car.
        /// Both Features will be added to a GeoJSONSource below as a feature collection
        var duckFeature = Feature(geometry: Constants.duckCoordinates)
        duckFeature.properties = [Constants.modelIdKey: .string(Constants.duckModelId)]
        var carFeature = Feature(geometry: Constants.mapboxHelsinki)
        carFeature.properties = [Constants.modelIdKey: .string(Constants.carModelId)]

        if #available(iOS 13, *) {
            mapView.mapboxMap.setMapStyleContent {
                /// Add Models for both the duck and car using an id and a URL to the resource
                Model(id: Constants.duckModelId, uri: Constants.duck)
                Model(id: Constants.carModelId, uri: Constants.car)

                /// Add a GeoJSONSource to the map and add the two features with geometry information
                GeoJSONSource(id: Constants.sourceId)
                    .data(.featureCollection(FeatureCollection(features: [duckFeature, carFeature])))

                /// Add a Model visualization layer which displays the two models stored in the GeoJSONSource according to the set properties
                ModelLayer(id: "model-layer-id", source: Constants.sourceId)
                    .modelId(Exp(.get) { Constants.modelIdKey })
                    .modelType(.common3d)
                    .modelScale(x: 40, y: 40, z: 40)
                    .modelTranslation(x: 0, y: 0, z: 0)
                    .modelRotation(x: 0, y: 0, z: 90)
                    .modelOpacity(0.7)
            }
        }

        view.addSubview(mapView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }
}

extension ModelLayerExample {
    private enum Constants {
        static let mapboxHelsinki = Point(CLLocationCoordinate2D(latitude: 60.17195694011002, longitude: 24.945389069265598))
        static let duckCoordinates = Point(CLLocationCoordinate2D(latitude: mapboxHelsinki.coordinates.latitude + 0.002, longitude: mapboxHelsinki.coordinates.longitude - 0.002))
        static let modelIdKey = "model-id-key"
        static let sourceId = "source-id"
        static let duckModelId = "model-id-duck"
        static let carModelId = "model-id-car"
        static let duck = URL.init(string: "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Embedded/Duck.gltf")
        static let car = Bundle.main.url(forResource: "sportcar", withExtension: "glb")!
    }
}
