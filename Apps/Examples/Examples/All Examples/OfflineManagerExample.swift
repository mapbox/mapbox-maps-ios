import Foundation
import UIKit
import MapboxMaps

/// Example that shows how to use OfflineManager and TileStore to
/// download regions for offline use.
///
/// By default, users may download up to 250MB of data for offline
/// use without incurring additional charges. This limit is subject
/// to change during the beta.
@objc(OfflineManagerExample)
public class OfflineManagerExample: UIViewController, ExampleProtocol {
    // This example uses a Storyboard to setup the following views
    @IBOutlet var mapViewContainer: UIView!
    @IBOutlet var logView: UITextView!
    @IBOutlet var button: UIButton!
    @IBOutlet var stylePackProgressView: UIProgressView!
    @IBOutlet var tileRegionProgressView: UIProgressView!
    @IBOutlet var progressContainer: UIView!

    private var mapView: MapView?
    private var logger: OfflineManagerLogWriter!

    // Default MapInitOptions. If you use a custom path for a TileStore, you would
    // need to create a custom MapInitOptions to reference that TileStore.
    private lazy var mapInitOptions: MapInitOptions = {
        MapInitOptions(cameraOptions: CameraOptions(center: tokyoCoord, zoom: tokyoZoom),
                       styleURI: .outdoors)
    }()

    private lazy var offlineManager: OfflineManager = {
        return OfflineManager(resourceOptions: mapInitOptions.resourceOptions)
    }()

    // Regions and style pack downloads
    private var downloads: [Cancelable] = []

    private let tokyoCoord = CLLocationCoordinate2D(latitude: 35.682027, longitude: 139.769305)
    private let tokyoZoom: CGFloat = 12
    private let tileRegionId = "myTileRegion"

    private enum State {
        case unknown
        case initial
        case downloading
        case downloaded
        case mapViewDisplayed
        case finished
    }

    deinit {
        OfflineSwitch.shared.isMapboxStackConnected = true
        removeTileRegionAndStylePack()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Initialize a logger that writes into the text view
        self.logger = OfflineManagerLogWriter(textView: logView)

        state = .initial
    }

    // MARK: - Actions

    internal func downloadTileRegions() {
        precondition(downloads.isEmpty)

        let dispatchGroup = DispatchGroup()
        var downloadError = false

        // - - - - - - - -

        // 1. Create style package with loadStylePack() call.
        let stylePackLoadOptions = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                                        metadata: ["tag": "my-outdoors-style-pack"])!

        dispatchGroup.enter()
        let stylePackDownload = offlineManager.loadStylePack(for: .outdoors, loadOptions: stylePackLoadOptions) { [weak self] progress in
            // These closures do not get called from the main thread. In this case
            // we're updating the UI, so it's important to dispatch to the main
            // queue.
            DispatchQueue.main.async {
                guard let progress = progress,
                      let stylePackProgressView = self?.stylePackProgressView else {
                    return
                }

                self?.logger?.log(message: "StylePack = \(progress)", category: "Example")
                stylePackProgressView.progress = Float(progress.completedResourceCount) / Float(progress.requiredResourceCount)
            }

        } completion: { [weak self] result in
            DispatchQueue.main.async {
                defer {
                    dispatchGroup.leave()
                }

                switch result {
                case let .success(stylePack):
                    self?.logger?.log(message: "StylePack = \(stylePack)", category: "Example")

                case let .failure(error):
                    self?.logger?.log(message: "stylePack download Error = \(error)", category: "Example", color: .red)
                    downloadError = true
                }
            }
        }

        // - - - - - - - -

        // 2. Create an offline region with tiles for the outdoors style
        let outdoorsOptions = TilesetDescriptorOptions(styleURI: .outdoors,
                                                       zoomRange: 0...16)

        let outdoorsDescriptor = offlineManager.createTilesetDescriptor(for: outdoorsOptions)

        // Load the tile region
        let tileRegionLoadOptions = TileRegionLoadOptions(
            geometry: MBXGeometry(coordinate: tokyoCoord),
            descriptors: [outdoorsDescriptor],
            metadata: ["tag": "my-outdoors-tile-region"],
            acceptExpired: true)!

        // Use the the default TileStore to load this region. You can create
        // custom TileStores are are unique for a particular file path, i.e.
        // there is only ever one TileStore per unique path.
        dispatchGroup.enter()
        let tileRegionDownload = TileStore.default.loadTileRegion(forId: tileRegionId,
                                                                  loadOptions: tileRegionLoadOptions) { [weak self] (progress) in
            // These closures do not get called from the main thread. In this case
            // we're updating the UI, so it's important to dispatch to the main
            // queue.
            DispatchQueue.main.async {
                guard let progress = progress,
                      let tileRegionProgressView = self?.tileRegionProgressView else {
                    return
                }

                self?.logger?.log(message: "\(progress)", category: "Example")

                // Update the progress bar
                tileRegionProgressView.progress = Float(progress.completedResourceCount) / Float(progress.requiredResourceCount)
            }
        } completion: { [weak self] result in
            DispatchQueue.main.async {
                defer {
                    dispatchGroup.leave()
                }

                switch result {
                case let .success(tileRegion):
                    self?.logger?.log(message: "tileRegion = \(tileRegion)", category: "Example")

                case let .failure(error):
                    self?.logger?.log(message: "tileRegion download Error = \(error)", category: "Example", color: .red)
                    downloadError = true
                }
            }
        }

        // Wait for both downloads before moving to the next state
        dispatchGroup.notify(queue: .main) {
            self.downloads = []
            self.state = downloadError ? .finished : .downloaded
        }

        downloads = [stylePackDownload, tileRegionDownload]
        state = .downloading
    }

    internal func cancelDownloads() {
        // Canceling will trigger `.canceled` errors that will then change state
        downloads.forEach { $0.cancel() }
    }

    private func logDownloadResult<T, Error>(message: String, result: Result<[T], Error>) {
        switch result {
        case let .success(array):
            logger?.log(message: message, category: "Example")
            for element in array {
                logger?.log(message: "\t\(element)", category: "Example")
            }

        case let .failure(error):
            logger?.log(message: "\(message) \(error)", category: "Example", color: .red)
        }
    }

    private func showDownloadedRegions() {
        offlineManager.allStylePacks { result in
            self.logDownloadResult(message: "Style packs:", result: result)
        }

        TileStore.default.allTileRegions { result in
            self.logDownloadResult(message: "Tile regions:", result: result)
        }
        logger?.log(message: "\n", category: "Example")
    }

    // Remove downloaded region and style pack
    private func removeTileRegionAndStylePack(completion: (() -> Void)? = nil ) {
        // Clean up after the example. Typically, you'll have custom business
        // logic to decide when to evict tile regions and style packs

        // Remove the tile region with the tile region ID.
        // Note this will not remove the downloaded tile packs, instead, it will
        // just mark the tileset as not a part of a tile region. The tiles still
        // exists in a predictive cache in the TileStore.
        TileStore.default.removeTileRegion(forId: tileRegionId)

        // Set the disk quota to zero, so that tile regions are fully evicted
        // when removed. The TileStore is also used when `ResourceOptions.isLoadTilePacksFromNetwork`
        // is `true`, and also by the Navigation SDK.
        // This removes the tiles from the predictive cache.
        TileStore.default.setOptionForKey(TileStoreOptions.diskQuota, value: 0)

        // Remove the style pack with the style uri.
        // Note this will not remove the downloaded style pack, instead, it will
        // just mark the resources as not a part of the existing style pack. The
        // resources still exists in the ambient cache.
        offlineManager.removeStylePack(for: .outdoors)

        // Remove the existing style resources from ambient cache using cache manager.
        let cacheManager = CacheManager(options: mapInitOptions.resourceOptions)
        cacheManager.clearAmbientCache { _ in
            completion?()
        }
    }

    // MARK: - State changes

    @IBAction func didTapButton(_ button: UIButton) {
        switch state {
        case .unknown:
            state = .initial
        case .initial:
            downloadTileRegions()
        case .downloading:
            // Cancel
            cancelDownloads()
        case .downloaded:
            state = .mapViewDisplayed
        case .mapViewDisplayed:
            showDownloadedRegions()
            state = .finished
        case .finished:
            removeTileRegionAndStylePack { [weak self] in
                self?.showDownloadedRegions()
                self?.state = .initial
            }
        }
    }

    private var state: State = .unknown {
        didSet {
            logger?.log(message: "Changing state from \(oldValue) -> \(state)", category: "Example", color: .orange)

            switch (oldValue, state) {
            case (_, .initial):
                resetUI()
                logger?.log(message: "Enabling HTTP stack network connection", category: "Example", color: .orange)
                OfflineSwitch.shared.isMapboxStackConnected = true

            case (.initial, .downloading):
                // Can cancel
                button.setTitle("Cancel Downloads", for: .normal)

            case (.downloading, .downloaded):
                logger?.log(message: "Disabling HTTP stack network connection", category: "Example", color: .orange)
                OfflineSwitch.shared.isMapboxStackConnected = false
                enableShowMapView()

            case (.downloaded, .mapViewDisplayed):
                showMapView()

            case (.mapViewDisplayed, .finished),
                 (.downloading, .finished):
                button.setTitle("Reset", for: .normal)

            default:
                fatalError("Invalid transition from \(oldValue) to \(state)")
            }
        }
    }

    // MARK: - UI changes

    private func resetUI() {
        logger?.reset()
        logView.textContainerInset.bottom = view.safeAreaInsets.bottom
        logView.scrollIndicatorInsets.bottom = view.safeAreaInsets.bottom

        progressContainer.isHidden = false
        stylePackProgressView.progress = 0.0
        tileRegionProgressView.progress = 0.0

        button.setTitle("Start Downloads", for: .normal)

        mapView?.removeFromSuperview()
        mapView = nil
    }

    private func enableShowMapView() {
        button.setTitle("Show Map", for: .normal)
    }

    private func showMapView() {
        button.setTitle("Show Downloads", for: .normal)
        progressContainer.isHidden = true

        // It's important that the MapView use the same ResourceOptions as the
        // OfflineManager
        let mapView = MapView(frame: mapViewContainer.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapViewContainer.addSubview(mapView)

        // Add a point annotation that shows the point geometry that were passed
        // to the tile region API.
        mapView.mapboxMap.onNext(.styleLoaded) { [weak self] _ in
            guard
                let annotations = self?.mapView?.annotations,
                let coord = self?.tokyoCoord else {
                return
            }

            annotations.addAnnotation(PointAnnotation_Legacy(coordinate: coord))
        }

        self.mapView = mapView
    }
}

// MARK: - Convenience classes for tile and style classes

extension TileRegionLoadProgress {
    public override var description: String {
        "TileRegionLoadProgress: \(completedResourceCount) / \(requiredResourceCount)"
    }
}

extension StylePackLoadProgress {
    public override var description: String {
        "StylePackLoadProgress: \(completedResourceCount) / \(requiredResourceCount)"
    }
}

extension TileRegion {
    public override var description: String {
        "TileRegion \(id): \(completedResourceCount) / \(requiredResourceCount)"
    }
}

extension StylePack {
    public override var description: String {
        "StylePack \(styleURI): \(completedResourceCount) / \(requiredResourceCount)"
    }
}

/// Convenience logger to write logs to the text view
public final class OfflineManagerLogWriter {
    weak var textView: UITextView?
    var log: NSMutableAttributedString

    internal init(textView: UITextView) {
        self.log = NSMutableAttributedString()
        self.textView = textView
    }

    public func reset() {
        log = NSMutableAttributedString()
        textView?.attributedText = log
    }

    public func log(message: String, category: String?, color: UIColor = .black) {
        print("[\(category ?? "")] \(message)")

        DispatchQueue.main.async { [weak self] in
            guard let textView = self?.textView,
                  let log = self?.log else {
                return
            }

            let message = NSMutableAttributedString(string: "\(message)\n", attributes: [NSAttributedString.Key.foregroundColor: color])
            log.append(message)

            textView.attributedText = log
        }
    }
}
