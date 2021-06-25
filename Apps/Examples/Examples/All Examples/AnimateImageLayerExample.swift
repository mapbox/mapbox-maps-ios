import MapboxMaps

@objc(AnimateImageLayerExample)
class AnimateImageLayerExample: UIViewController, ExampleProtocol {
    var mapView: MapView!
    var imageSource: ImageSource!
    var sourceId = "radar-source"

    override func viewDidLoad() {
        super.viewDidLoad()

        let center = CLLocationCoordinate2D(latitude: 41.874, longitude: -75.789)
        let cameraOptions = CameraOptions(center: center, zoom: 5)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .dark)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        mapView.ornaments.options.scaleBar.visibility = .hidden

        // This also updates the color of the info button to match the map's style.

        mapView.tintColor = .lightGray
        // Set the map's `CameraBoundsOptions` to limit the map's zoom level.
        mapView.camera.options.maxZoom = 5.99
        mapView.camera.options.minZoom = 4

        view.addSubview(mapView)

        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addImageLayer()
        }
    }
    
    func addImageLayer() {
        let style = mapView.mapboxMap.style

        imageSource = ImageSource()

        // Set the `coordinates` property to an array of longitude, latitude pairs.
        imageSource.coordinates = [
            [-80.425, 46.437],
            [-71.516, 46.437],
            [-71.516, 37.936],
            [-80.425, 37.936]
        ]

        // Get the file path for the first radar image, then set the `url` for the `ImageSource` to that path.
        let path = Bundle.main.path(forResource: "radar0", ofType: "gif")!
        imageSource.url = path

        // Create a `RasterLayer` that will display the images from the `ImageSource`
        var imageLayer = RasterLayer(id: "radar-layer")
        imageLayer.source = sourceId

        // Set `rasterFadeD
        imageLayer.rasterFadeDuration = .constant(0)

        do {
            try style.addSource(imageSource, id: sourceId)
            try style.addLayer(imageLayer)
        } catch {
            print("Failed to add the source or layer to style. Error: \(error)")
        }
        setUpTimer(forStyle: style)
    }

    func setUpTimer(forStyle style: Style) {
        var imageNumber = 0
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            guard let self = self else { return }

            // There are five radar images, number 0-4. Increment the count. When that would
            // result in an `imageNumber` value greater than 4, reset `imageNumber` to `0`.
            if imageNumber < 4 {
                imageNumber += 1
            } else {
                imageNumber = 0
            }
            // Create a `UIImage` from the file at the specified path.
            let path = Bundle.main.path(forResource: "radar\(imageNumber)", ofType: "gif")
            let image = UIImage(contentsOfFile: path!)

            // Update the image used by the `ImageSource`.
            do {
                try style.updateImageSource(withId: self.sourceId, image: image!)
            } catch {
                print("Failed to update style image. Error: \(error)")
            }
        }
    }
}
