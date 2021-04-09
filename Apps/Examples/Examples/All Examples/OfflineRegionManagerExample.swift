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
        mapView = MapView(frame: view.bounds, styleURI: .light)
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

        mapView.on(.styleLoaded) { [weak self] _ in
            self?.setupExample()
        }
    }

    internal func setupExample() {
        let offlineRegionDef = OfflineRegionGeometryDefinition(styleURL: mapView.style.uri.rawValue.absoluteURL.absoluteString,
                                                               geometry: MBXGeometry(coordinate: coord),
                                                               minZoom: zoom - 2,
                                                               maxZoom: zoom + 2,
                                                               pixelRatio: Float(UIScreen.main.scale),
                                                               glyphsRasterizationMode: .noGlyphsRasterizedLocally)

        // Please note - this is using a deprecated API, and will be removed in a future release.
        offlineManager = OfflineRegionManager(resourceOptions: ResourceOptions.default)
        offlineManager.createOfflineRegion(for: offlineRegionDef, callback: { [weak self] (expected: MBXExpected<AnyObject, AnyObject>?) in
            guard let expected = expected else {
                print("No offline region created. Unexpected result.")
                return
            }

            guard !expected.isError() else {
                print("Error creating offline region: \(String(describing: expected.error))")
                return
            }

            guard let region = expected.value as? OfflineRegion else {
                print("Unexpected value: \(type(of: expected.value))")
                return
            }

            self?.startDownload(for: region)
        })
    }

    func startDownload(for region: OfflineRegion) {
        observer.offlineRegion = region
        observer.statusChanged = { [weak self] (status: OfflineRegionStatus) in
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
