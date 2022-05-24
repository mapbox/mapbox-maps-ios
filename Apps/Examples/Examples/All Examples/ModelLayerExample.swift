import UIKit
@_spi(Experimental) import MapboxMaps

@objc(ModelLayerExample)
final class ModelLayerExample: UIViewController, ExampleProtocol {
    private enum Constants {
        static let helsinki = Point(CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384))
        static let mapboxHelsinki = Point(CLLocationCoordinate2D(latitude: 60.17195694011002, longitude: 24.945389069265598))
        static let modelIdKey = "model-id-key"
        static let sourceId = "source-id"
        static let duckModelId = "model-id-duck"
        static let carModelId = "model-id-car"
        static let duck = "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Embedded/Duck.gltf"
        static let car = Bundle.main.url(forResource: "sportcar", withExtension: "glb")!.absoluteString
    }
    private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(
            center: mid(Constants.helsinki.coordinates, Constants.mapboxHelsinki.coordinates),
            zoom: 14,
            pitch: 45
        )
        let options = MapInitOptions(cameraOptions: cameraOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.ornaments.options.scaleBar.visibility = .visible

        view.addSubview(mapView)

        mapView.mapboxMap.loadStyleURI(.light) { [weak self] _ in
            self?.setupExample()
        }
    }

    private func setupExample() {
        let style = mapView.mapboxMap.style

        try! style.addModel(withId: Constants.duckModelId, modelURI: Constants.duck)
        try! style.addModel(withId: Constants.carModelId, modelURI: Constants.car)

        var source = GeoJSONSource()
        var duckFeature = Feature(geometry: Constants.helsinki)
        duckFeature.properties = [Constants.modelIdKey: .string(Constants.duckModelId)]
        var carFeature = Feature(geometry: Constants.mapboxHelsinki)
        carFeature.properties = [Constants.modelIdKey: .string(Constants.carModelId)]

        source.data = .featureCollection(FeatureCollection(features: [duckFeature, carFeature]))

        try! style.addSource(source, id: Constants.sourceId)

        var layer = ModelLayer(id: "model-layer-id")
        layer.source = Constants.sourceId
        layer.modelId = .expression(Exp(.get) { Constants.modelIdKey })
        layer.modelType = .constant(.common3d)
        layer.modelScale = .constant([100, 100, 100])
        layer.modelTranslation = .constant([0, 0, 0])
        layer.modelRotation = .constant([0, 0, 90])
        layer.modelOpacity = .constant(0.7)
        
        try! style.addLayer(layer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }
}
