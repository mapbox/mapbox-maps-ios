import UIKit
import os
@_spi(Experimental) import MapboxMaps

final class CustomRasterSourceExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables: Set<AnyCancelable> = []
    private var requiredTiles: [CanonicalTileID] = []

    private enum ID {
        static let customRasterSource = "custom-raster-source"
        static let rasterLayer = "customRaster"
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
        let rasterSourceClient = CustomRasterSourceClient.fromCustomRasterSourceTileStatusChangedCallback { [weak self] (tileID, status) in
            os_log(.info, "Tile status changed: tileId={%@}, status=%@", tileID.log, status.log)
            guard let self else { return }

            switch status {
            case .required:
                if !self.requiredTiles.contains(where: { $0 == tileID }) {
                    self.requiredTiles.append(tileID)
                }
                self.refreshTiles()
            case .notNeeded, .optional:
                if let index = self.requiredTiles.firstIndex(of: tileID) {
                    self.requiredTiles.remove(at: index)
                }
                try! self.mapView.mapboxMap.setCustomRasterSourceTileData(
                    forSourceId: ID.customRasterSource,
                    tiles: [CustomRasterSourceTileData(tileId: tileID, image: nil)])
            default: break
            }
        }
        let rasterSourceOptions = CustomRasterSourceOptions(clientCallback: rasterSourceClient, minZoom: 0, maxZoom: 0, tileSize: 256)
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
            refreshTiles()
        } catch {
            print("[Example/CustomRasterSourceExample] Error:\(error)")
        }
    }

    private func refreshTiles() {
        let rasterImage = nextImage()
        let tiles = requiredTiles
            .map { CustomRasterSourceTileData(tileId: $0, image: rasterImage) }
        try! mapView.mapboxMap.setCustomRasterSourceTileData(forSourceId: ID.customRasterSource, tiles: tiles)
    }

    // MARK: Raster Images

    private var currentImageIndex = 0
    private let rasterImages: [UIImage] = [
        UIImage(named: "RasterSource/wind_0")!,
        UIImage(named: "RasterSource/wind_1")!,
        UIImage(named: "RasterSource/wind_2")!,
        UIImage(named: "RasterSource/wind_3")!,
    ]

    private func nextImage() -> UIImage {
        var currentImageIndex = self.currentImageIndex + 1
        if currentImageIndex >= self.rasterImages.endIndex {
            currentImageIndex = 0
        }
        return rasterImages[currentImageIndex]
    }
}
