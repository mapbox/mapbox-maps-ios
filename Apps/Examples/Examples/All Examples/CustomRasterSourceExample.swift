import UIKit
@_spi(Experimental) import MapboxMaps

final class CustomRasterSourceExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables: Set<AnyCancelable> = []
    private var timer: Timer?

    private enum ID {
        static let customRasterSource = "custom-raster-source"
        static let rasterLayer = "customRaster"
    }

    deinit {
        timer?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds, mapInitOptions: .init(cameraOptions: CameraOptions(center: .helsinki, zoom: 2)))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onStyleLoaded.observeNext { [weak self] _ in
            self?.setupExample()
            // The below line is used for internal testing purposes only.
            self?.finish()
        }
        .store(in: &cancelables)
    }

    private func setupExample() {
        let rasterSourceOptions = CustomRasterSourceOptions(
            fetchTileFunction: { [weak self] tileID in
                guard let self else { return }

                try! self.mapView.mapboxMap.setCustomRasterSourceTileData(
                    forSourceId: ID.customRasterSource,
                    tileId: tileID,
                    image: rasterImages[currentImageIndex])
            },
            cancelTileFunction: { _ in },
            minZoom: 0,
            maxZoom: 0,
            tileSize: 256 // Image for raster tile must be of same dimensions as tile size of the source.
        )
        let customRasterSource = CustomRasterSource(id: ID.customRasterSource, options: rasterSourceOptions)

        do {
            try mapView.mapboxMap.addSource(customRasterSource)

            var rasterLayer = RasterLayer(id: ID.rasterLayer, source: ID.customRasterSource)
            rasterLayer.rasterColorMix = .constant([1, 0, 0, 0])
            rasterLayer.rasterColor = .expression(
                Exp(.interpolate) {
                    Exp(.linear)
                    Exp(.lineProgress)
                    0
                    "rgba(0.0, 0.0, 0.0, 0.0)"
                    0.3
                    "rgba(7, 238, 251, 0.4)"
                    0.5
                    "rgba(0, 255, 42, 0.5)"
                    0.7
                    "rgba(255, 255, 0, 0.7)"
                    1
                    "rgba(255, 30, 0, 0.9)"
                }
            )
            try mapView.mapboxMap.addLayer(rasterLayer)
            scheduleNextRasterImage()
        } catch {
            print("[Example/CustomRasterSourceExample] Error:\(error)")
        }
    }

    // MARK: Raster Images

    private var currentImageIndex = 0
    private let rasterImages: [UIImage] = [
        UIImage(named: "RasterSource/wind_0")!,
        UIImage(named: "RasterSource/wind_1")!,
        UIImage(named: "RasterSource/wind_2")!,
        UIImage(named: "RasterSource/wind_3")!,
    ]

    private func scheduleNextRasterImage() {
        guard timer == nil else {
            timer?.invalidate()
            return timer = nil
        }

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }

            var currentImageIndex = self.currentImageIndex + 1
            if currentImageIndex >= self.rasterImages.endIndex {
                currentImageIndex = 0
            }
            self.currentImageIndex = currentImageIndex

            try! self.mapView.mapboxMap.invalidateCustomRasterSourceRegion(forSourceId: ID.customRasterSource, bounds: .world)
        }
    }
}
