import Foundation
import UIKit
import MapboxMaps

@objc(OfflineManagerExample)
public class OfflineManagerExample: UIViewController, ExampleProtocol {
    // This example uses a Storyboard to setup the following views
    @IBOutlet var mapViewContainer: UIView!
    @IBOutlet var logView: UITextView!
    @IBOutlet var button: UIButton!
    @IBOutlet var progressView: UIProgressView!

    private var mapView: MapView?
    private var offlineManager: OfflineManager?
    private var logger: OfflineManagerLogWriter?
    private var download: Cancelable?
    private var tileRegion: TileRegion?

    private let tokyoCoord = CLLocationCoordinate2D(latitude: 35.682027, longitude: 139.769305)
    private let tokyoZoom: CGFloat = 12
    private lazy var tokyoCoords: [CLLocationCoordinate2D] = {[
        CLLocationCoordinate2D(latitude: tokyoCoord.latitude - 0.1, longitude: tokyoCoord.longitude - 0.1),
        CLLocationCoordinate2D(latitude: tokyoCoord.latitude - 0.1, longitude: tokyoCoord.longitude + 0.1),
        CLLocationCoordinate2D(latitude: tokyoCoord.latitude + 0.1, longitude: tokyoCoord.longitude + 0.1),
        CLLocationCoordinate2D(latitude: tokyoCoord.latitude + 0.1, longitude: tokyoCoord.longitude - 0.1),
        CLLocationCoordinate2D(latitude: tokyoCoord.latitude - 0.1, longitude: tokyoCoord.longitude - 0.1),
    ]}()

    // Default MapInitOptions. If you use a custom path for a TileStore, you would
    // need to create a custom MapInitOptions to reference that TileStore.
    private var mapInitOptions = MapInitOptions()

    deinit {
        // Clean up after the example. Typically, you'll have custom business
        // logic to decide when to evict tile regions and style packs
        if let tileRegion = tileRegion {
            TileStore.getInstance().removeTileRegion(forId: tileRegion.id)
        }

        if let offlineManager = offlineManager {
            offlineManager.removeStylePack(for: .outdoors)
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Initialize a logger that writes into the text view
        let logger = OfflineManagerLogWriter(for: ["Example", "maps"], textView: logView)
        LogConfiguration.getInstance().registerLogWriterBackend(forLogWriter: logger)
        self.logger = logger

        setupViews()
    }

    func setupViews() {
        logView.text = ""
        logView.textContainerInset.bottom = view.safeAreaInsets.bottom
        logView.scrollIndicatorInsets.bottom = view.safeAreaInsets.bottom

        progressView.progress = 0.0
    }

    internal func downloadTileRegion() {
        precondition(download == nil)
        button.setTitle("Cancel Download", for: .normal)

        let offlineManager = OfflineManager(resourceOptions: mapInitOptions.resourceOptions)

        // Create an offline region with tiles using the "outdoors" style
        let stylePackOptions = StylePackLoadOptions(glyphsRasterizationMode: .allGlyphsRasterizedLocally,
                                                    metadata: ["tag": "my-outdoors-style-pack"])

        let outdoorsOptions = TilesetDescriptorOptions(styleURI: .outdoors,
                                                       zoomRange: 0...16,
                                                       stylePackOptions: stylePackOptions)

        let outdoorsDescriptor = offlineManager.createTilesetDescriptor(for: outdoorsOptions)

        // Load the tile region
        let tileLoadOptions = TileLoadOptions(criticalPriority: false,
                                              acceptExpired: true,
                                              networkRestriction: .none)

        let tileRegionLoadOptions = TileRegionLoadOptions(
            geometry: MBXGeometry(line: tokyoCoords),
            descriptors: [outdoorsDescriptor],
            metadata: ["tag": "my-outdoors-tile-region"],
            tileLoadOptions: tileLoadOptions,
            averageBytesPerSecond: nil)!

        // Use the the default TileStore to load this region. You can create
        // custom TileStores are are unique for a particular file path, i.e.
        // there is only ever one TileStore per unique path.
        download = TileStore.getInstance().loadTileRegion(forId: "myTileRegion",
                                                          loadOptions: tileRegionLoadOptions) { [weak self] (progress) in
            guard let progress = progress else {
                return
            }

            // These closures do not get called from the main thread. In this case
            // we're updating the UI, so it's important to dispatch to the main
            // queue.
            DispatchQueue.main.async {
                Log.info(forMessage: "\(progress)", category: "Example")

                // Update the progress bar
                let fractionComplete = Float(progress.completedResourceCount) / Float(progress.requiredResourceCount)
                self?.progressView.progress = fractionComplete
            }
        } completion: { [weak self] (result: Result<TileRegion, TileRegionError>) in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }

                self.download = nil

                switch result {
                case let .success(tileRegion):
                    Log.info(forMessage: "tileRegion = \(tileRegion)", category: "Example")
                    self.enableShowMapView()
                    self.tileRegion = tileRegion

                case let .failure(error):
                    Log.error(forMessage: "tileRegion download Error = \(error)", category: "Example")
                    self.button.setTitle("Start Download", for: .normal)
                }
            }
        }

        self.offlineManager = offlineManager
    }

    internal func cancelDownload() {
        download?.cancel()
        download = nil
        tileRegion = nil

        button.isEnabled = true
        button.setTitle("Start Download", for: .normal)
        progressView.progress = 0
    }

    internal func enableShowMapView() {
        button.isEnabled = true
        button.setTitle("Show MapView", for: .normal)
        progressView.isHidden = true
        Log.info(forMessage: "Tile region has been downloaded. Try disabling the network and showing the map view.", category: "Example")
    }

    internal func showMapView() {
        button.setTitle("Show Metadata", for: .normal)

        let mapView = MapView(frame: mapViewContainer.bounds, mapInitOptions: mapInitOptions, styleURI: .outdoors)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapViewContainer.addSubview(mapView)

        // Jump to center of our bounds
        mapView.cameraManager.setCamera(to: CameraOptions(center: tokyoCoord,
                                                          zoom: tokyoZoom))

        self.mapView = mapView

        // Add a line annotation that shows the bounds that were passed to the tile
        // region API.
        mapView.on(.styleLoaded) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.mapView?.annotationManager.addAnnotation(LineAnnotation(coordinates: self.tokyoCoords))
        }
    }

    private func fetchAndDisplayMetadata() {
        guard let tileRegion = tileRegion else {
            preconditionFailure()
        }

        // Fetch the meta-data for the region. This should match the metadata
        // passed to TileRegionLoadOptions
        TileStore.getInstance().tileRegionMetadata(forId: tileRegion.id) { (result) in
            DispatchQueue.main.async {
                switch result {
                case let .success(metadata):
                    Log.info(forMessage: "Metadata = \(metadata)", category: "Example")
                case let .failure(error):
                    Log.error(forMessage: "Metadata error = \(error)", category: "Example")
                }
            }
        }
    }

    @IBAction func didTapButton(_ button: UIButton) {
        switch (download, tileRegion, mapView) {
        case (.none, .none, .none):
            downloadTileRegion()

        case (.some, _, .none):
            cancelDownload()

        case (.none, .some, .none):
            showMapView()

        case (_, _, .some):
            fetchAndDisplayMetadata()
        }
    }
}

// MARK: - Convenience classes and extensions

/// Convenience logger to write logs to the text view
public final class OfflineManagerLogWriter: LogWriterBackend {
    weak var textView: UITextView?
    var previousBackend: LogWriterBackend
    var log: NSMutableAttributedString
    let categories: [String?]

    deinit {
        // Restore normality
        LogConfiguration.getInstance().registerLogWriterBackend(forLogWriter: previousBackend)
    }

    internal init(for categories: [String], textView: UITextView) {
        self.previousBackend = LogConfiguration.getInstance().getLogWriterBackend()
        self.log = NSMutableAttributedString()
        self.categories = categories as [String?]
        self.textView = textView
    }

    public func writeLog(for level: LoggingLevel, message: String, category: String?) {
        print("[\(level.rawValue): \(category ?? "")] \(message)")

        guard categories.contains(category) else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let textView = self?.textView,
                  let log = self?.log else {
                return
            }

            let message = NSMutableAttributedString(string: "\(message)\n", attributes: [NSAttributedString.Key.foregroundColor: level.color])
            log.append(message)

            textView.attributedText =  log

            let range = NSRange(location: log.length, length: 0)
            textView.scrollRangeToVisible(range)
        }
    }
}

extension TileRegionLoadProgress {
    public override var description: String {
        """
        TileRegionLoadProgress: \(completedResourceCount) / \(requiredResourceCount)
        """
    }
}

extension TileRegion {
    public override var description: String {
        """
        TileRegion \(id): \(requiredResourceCount) / \(completedResourceCount)
        """
    }
}

extension StylePack {
    public override var description: String {
        """
        StylePack \(styleURI): \(requiredResourceCount) / \(completedResourceCount)
        """
    }
}

public extension LoggingLevel {
    var color: UIColor {
        switch self {
        case .debug:
            return .purple
        case .warning:
            return .orange
        case .error:
            return .red
        default:
            return .black
        }
    }
}
