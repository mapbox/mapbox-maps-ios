import Foundation
import UIKit
import MapboxMaps

@available(*, deprecated)
@objc(OfflineRegionManagerExample)
public class OfflineRegionManagerExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    private var offlineManager: OfflineRegionManager!
    private var observer = OfflineRegionExampleObserver()
    private var progressView: UIProgressView!

    private let tag   = "Offline"
    private let zoom  = 16.0
    private let coord = CLLocationCoordinate2D(latitude: 57.818901, longitude: 20.071357)

    override public func viewDidLoad() {
        super.viewDidLoad()

        print("This example uses a deprecated API, and will be removed in a future release.")
        let options = MapInitOptions(styleURI: .light)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progress                                  = 0.0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor                            = .white
        progressView.progressTintColor                         = .red

        mapView.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -100.0),
            progressView.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20),
            progressView.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -20)
        ])

        mapView.mapboxMap.onNext(.styleLoaded) { _ in
            self.setupExample()
        }
    }

    internal func setupExample() {
        let uriString = mapView.mapboxMap.style.uri!.rawValue
        let offlineRegionDef = OfflineRegionGeometryDefinition(
            styleURL: uriString,
            geometry: .point(Point(coord)),
            minZoom: zoom - 2,
            maxZoom: zoom + 2,
            pixelRatio: Float(UIScreen.main.scale),
            glyphsRasterizationMode: .noGlyphsRasterizedLocally)

        // Please note - this is using a deprecated API, and will be removed in a future release.
        offlineManager = OfflineRegionManager(resourceOptions: resourceOptions())

        offlineManager.createOfflineRegion(for: offlineRegionDef) { [weak self] result in
            switch result {
            case let .failure(error):
                print("Error creating offline region: \(error)")

            case let .success(region):
                self?.startDownload(for: region)
            }
        }
    }

    func startDownload(for region: OfflineRegion) {
        observer.offlineRegion = region
        observer.statusChanged = { [weak self] (status: OfflineRegionStatus) in
            region.getStatus { result in
                switch result.map(\.downloadState) {
                case .success(let downloadState): print("\(downloadState.rawValue)")
                case .failure: break
                }
            }
            print("Downloaded \(status.completedResourceCount)/\(status.requiredResourceCount) resources; \(status.completedResourceSize) bytes downloaded.")

            self?.progressView.progress = Float(status.completedResourceCount)/Float(status.requiredResourceCount)
            if status.downloadState == .inactive {
                print("Download complete.")

                // The line below is used for internal testing purposes only.
                self?.finish()
            }
        }

        region.setOfflineRegionObserverFor(observer)
        region.setOfflineRegionDownloadStateFor(.active)
    }
}

/// Delegate for OfflineRegion
@available(*, deprecated)
public class OfflineRegionExampleObserver: OfflineRegionObserver {

    weak var offlineRegion: OfflineRegion?
    var statusChanged: ((OfflineRegionStatus) -> Void)?

    public func statusChanged(for status: OfflineRegionStatus) {
        statusChanged?(status)
    }

    public func responseError(forError error: ResponseError) {
        print("Offline region download failed: \(error.reason), \(error.message)")
        offlineRegion?.setOfflineRegionDownloadStateFor(.inactive)
    }

    public func mapboxTileCountLimitExceeded(forLimit limit: UInt64) {
        print("Mapbox tile count max (\(limit)) has been exceeded!")
    }

}
