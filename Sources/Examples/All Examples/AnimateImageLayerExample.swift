import MapboxMaps
import UIKit

final class AnimateImageLayerExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private let sourceId = "radar-source"
    private var timer: Timer?
    private var imageNumber = 0
    private var cancelables = Set<AnyCancelable>()

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
        try? mapView.mapboxMap.setCameraBounds(with: CameraBoundsOptions(maxZoom: 5.99, minZoom: 4))

        view.addSubview(mapView)

        mapView.mapboxMap.onMapLoaded.observeNext { _ in
            self.addImageLayer()

            // The following line is just for testing purposes.
            self.finish()
        }.store(in: &cancelables)
    }

    func addImageLayer() {
        // Create an `ImageSource`. This will manage the image displayed in the `RasterLayer` as well
        // as the location of that image on the map.
        var imageSource = ImageSource(id: sourceId)

        // Set the `coordinates` property to an array of longitude, latitude pairs.
        imageSource.coordinates = [
            [-80.425, 46.437],
            [-71.516, 46.437],
            [-71.516, 37.936],
            [-80.425, 37.936]
        ]

        // Get the file path for the first radar image, then set the `url` for the `ImageSource` to that path.
        let path = Bundle.main.url(forResource: "radar0", withExtension: "gif")
        imageSource.url = path?.absoluteString

        // Create a `RasterLayer` that will display the images from the `ImageSource`
        var imageLayer = RasterLayer(id: "radar-layer", source: sourceId)

        // Set `rasterFadeDuration` to `0`. This prevents visible transitions when the image is updated.
        imageLayer.rasterFadeDuration = .constant(0)

        do {
            try mapView.mapboxMap.addSource(imageSource)
            try mapView.mapboxMap.addLayer(imageLayer)

        } catch {
            print("Failed to add the source or layer to style. Error: \(error)")
        }

        // Add a tap gesture handler that will allow the animation to be stopped and started.
        mapView.mapboxMap.addInteraction(TapInteraction {[weak self] _ in
            self?.manageTimer()
            return false
        })

        manageTimer()
    }

    func manageTimer() {
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
                let path = Bundle.main.url(forResource: "radar\(self.imageNumber)", withExtension: "gif")
                let image = UIImage(contentsOfFile: path!.relativePath)

                do {
                    // Update the image used by the `ImageSource`.
                    try self.mapView.mapboxMap.updateImageSource(withId: self.sourceId, image: image!)
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
