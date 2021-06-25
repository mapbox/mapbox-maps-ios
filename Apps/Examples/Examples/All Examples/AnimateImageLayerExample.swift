import MapboxMaps

@objc(AnimateImageLayerExample)
class AnimateImageLayerExample: UIViewController, ExampleProtocol {
    var mapView: MapView!
    var sourceId = "radar-source"
    var timer: Timer?
    var imageNumber = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let center = CLLocationCoordinate2D(latitude: 41.874, longitude: -75.789)
        let cameraOptions = CameraOptions(center: center, zoom: 5)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .dark)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        // Hide the `scaleBar` at all zoom levels.
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

        // Create an `ImageSource`. This will manage the image displayed in the `RasterLayer` as well
        // as the location of that image on the map.
        var imageSource = ImageSource()

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

        // Set `rasterFadeDuration` to `0`. This prevents visible transitions when the image is updated.
        imageLayer.rasterFadeDuration = .constant(0)

        do {
            try style.addSource(imageSource, id: sourceId)
            try style.addLayer(imageLayer)

            // Add a tap gesture recognizer that will allow the animation to be stopped and started.
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(manageTimer))
            mapView.addGestureRecognizer(tapGestureRecognizer)
        } catch {
            print("Failed to add the source or layer to style. Error: \(error)")
        }
        manageTimer()
    }

    @objc func manageTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }

                // There are five radar images, number 0-4. Increment the count. When that would
                // result in an `imageNumber` value greater than 4, reset `imageNumber` to `0`.
                if self.imageNumber < 4 {
                    self.imageNumber += 1
                } else {
                    self.imageNumber = 0
                }
                // Create a `UIImage` from the file at the specified path.
                let path = Bundle.main.path(forResource: "radar\(self.imageNumber)", ofType: "gif")
                let image = UIImage(contentsOfFile: path!)

                do {
                    // Update the image used by the `ImageSource`.
                    try self.mapView.mapboxMap.style.updateImageSource(withId: self.sourceId, image: image!)
                } catch {
                    print("Failed to update style image. Error: \(error)")
                }
            }
        } else {
            timer?.invalidate()
            timer = nil
        }
    }

    deinit {
        timer?.invalidate()
    }
}
