import Foundation
import UIKit
import MapboxMaps

#if DEBUG

@available(*, deprecated)
final class OfflineRegionManagerExample: UIViewController, ExampleProtocol {

    private var mapView: MapView!
    private var progressView: UIProgressView!

    private var offlineManager: OfflineRegionManager!
    private var offlineRegion: OfflineRegion!

    private let center = CLLocationCoordinate2D(
        latitude: 60.17195694011002,
        longitude: 24.945389069265598)
    private let zoom: CGFloat = 16
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("This example uses a deprecated API, and will be removed in a future release.")

        let options = MapInitOptions(
            cameraOptions: CameraOptions(
                center: center,
                zoom: zoom),
            styleURI: .light)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progress = 0.0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .white
        progressView.progressTintColor = .red

        mapView.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.bottomAnchor.constraint(equalTo: mapView.ornaments.logoView.topAnchor, constant: -20.0),
            progressView.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20),
            progressView.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -20),
        ])

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            self?.setupExample()
        }.store(in: &cancelables)
    }

    private func setupExample() {
        let uriString = mapView.mapboxMap.styleURI!.rawValue
        let offlineRegionDef = OfflineRegionGeometryDefinition(
            styleURL: uriString,
            geometry: .point(Point(center)),
            minZoom: zoom - 2,
            maxZoom: zoom + 2,
            pixelRatio: Float(UIScreen.main.scale),
            glyphsRasterizationMode: .noGlyphsRasterizedLocally)

        // Please note: this uses a deprecated API and will be removed in the future.
        offlineManager = OfflineRegionManager()

        offlineManager.createOfflineRegion(for: offlineRegionDef) { [weak self] result in
            switch result {
            case let .failure(error):
                print("Error creating offline region: \(error)")

            case let .success(region):
                self?.startDownload(for: region)
            }
        }
    }

    private func startDownload(for region: OfflineRegion) {
        let observer = OfflineRegionExampleObserver { [weak self] (status) in
            guard let self = self else {
                return
            }

            self.progressView.progress = Float(status.completedResourceCount)/Float(status.requiredResourceCount)

            let sentences = [
                "Downloaded \(status.completedResourceCount)/\(status.requiredResourceCount) resources and \(status.completedResourceSize) bytes.",
                "Required resource count is \(status.requiredResourceCountIsPrecise ? "precise" : "a lower bound").",
                "Download state is \(status.downloadState == .active ? "active" : "inactive").",
            ]
            print(sentences.joined(separator: " "))

            if status.downloadState == .inactive {
                print("Download complete.")

                // A download that was completely successful should meet the following criteria:
                if status.requiredResourceCountIsPrecise, status.completedResourceCount == status.requiredResourceCount {
                    print("Success")
                } else {
                    print("Some resources failed to download. Resources that did download will be available offline.")
                }

                // The line below is used for internal testing purposes only.
                self.finish()
            }
        }

        // must keep a strong reference to the region or it will get
        // deallocated and the observer will not be notified.
        offlineRegion = region
        offlineRegion.setOfflineRegionObserverFor(observer)
        offlineRegion.setOfflineRegionDownloadStateFor(.active)
    }
}

/// Delegate for OfflineRegion
@available(*, deprecated)
final class OfflineRegionExampleObserver: OfflineRegionObserver {

    private let statusChanged: (OfflineRegionStatus) -> Void

    init(statusChanged: @escaping (OfflineRegionStatus) -> Void) {
        self.statusChanged = statusChanged
    }

    func statusChanged(for status: OfflineRegionStatus) {
        statusChanged(status)
    }

    func errorOccurred(forError error: OfflineRegionError) {
        // Some errors are considered recoverable and will be retried
        if error.isFatal {
            print("Offline resource download fatal error: The region cannot proceed downloading of any resources and it will be put to inactive state.")
        } else {
            print("Offline resource download error: \(error.type), \(error.message)")
        }
    }

    func mapboxTileCountLimitExceeded(forLimit limit: UInt64) {
        print("Mapbox tile count max (\(limit)) has been exceeded!")
    }
}

#endif
