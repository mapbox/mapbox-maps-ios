import Foundation
import UIKit
import MapboxMaps

//Download the style pack using offline manager.
//Display the progress in the UI that's hooked into the progress callback.
//Cancel the style pack downloading process.
//Log the current style pack status with getStylePack API.
//Option to customise the tile store path.
//Download the offline region using offline manager.
//Embed a mapview, and provide a button to download the current visible region.
//Display the progress in the UI that's hooked into the progress callback.
//Cancel the offline region downloading process.
//Log the current offline region status with getOfflineRegion API.
//Offline region for tests:
//
//Tokyo (zoom level 12, camera pointing at , )
//Should be reused for benchmark and examples.

@objc(OfflineManagerExample)
public class OfflineManagerExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    private var offlineManager: OfflineManager!
    private var stylePackProgressView: UIProgressView!
    private var tileRegionProgressView: UIProgressView!

    private let tokyoCoord = CLLocationCoordinate2D(latitude: 35.682027, longitude: 139.769305)
    private let tokyoZoom = 12
    private var tileStore: TileStore?

    private lazy var tileStorePath: String = {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            fatalError()
        }

        var cacheDirectoryURL: URL
        cacheDirectoryURL = try! FileManager.default.url(for: .cachesDirectory,
                                                         in: .userDomainMask,
                                                         appropriateFor: nil,
                                                         create: true)
        cacheDirectoryURL.appendPathComponent("tile-store")
        return cacheDirectoryURL.path
    }()

    private lazy var mapInitOptions: MapInitOptions = {

//        let tileStore = TileStore.getInstance()
//        tileStore.

        var resourceOptions = ResourceOptions(accessToken: CredentialsManager.default.accessToken,
                                              tileStorePath: tileStorePath)

        return MapInitOptions(resourceOptions: resourceOptions,
                              mapOptions: MapOptions(constrainMode: .heightOnly))
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions, styleURI: .light)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        stylePackProgressView = makeProgressView()
        tileRegionProgressView = makeProgressView()

        let stackView = UIStackView(arrangedSubviews: [stylePackProgressView, tileRegionProgressView])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 20.0

//        mapView.addSubview(stackView)
//
//        NSLayoutConstraint.activate([
//            stackView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -100.0),
//            stackView.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 20),
//            stackView.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -20)
//        ])

        mapView.on(.styleLoaded) { [weak self] _ in
            self?.setupExample()
        }
    }

    private func makeProgressView() -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progress                                  = 0.0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor                            = .white
        progressView.progressTintColor                         = .red
        return progressView
    }


    internal func setupExample() {
        offlineManager = OfflineManager(resourceOptions: mapInitOptions.resourceOptions)

        // 1. Create style package
        let stylePackLoadOptions = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                                        metadata: "Hello World" as NSString)

        offlineManager.loadStylePack(for: .streets,
                                     loadOptions: stylePackLoadOptions) { (result) in
            switch result {
            case let .success(stylePack):
                print("Style pack loading complete = \(stylePack)")

            case let .failure(error):
                print("Oh, \(error)")
            }
        }

        // 2. Create an offline region with tiles for Streets and Satellite styles.
        let stylePackOptions = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally)

        let streetsTilesetDescriptorOptions = TilesetDescriptorOptions(styleURI: .streets,
                                                                       minZoom: 17,
                                                                       maxZoom: 20,
                                                                       pixelRatio: 2,
                                                                       stylePackOptions: stylePackOptions)

        let streetsDescriptor = offlineManager.createTilesetDescriptor(for: streetsTilesetDescriptorOptions)

        // Satellite
        let satelliteTilesetDescriptorOptions = TilesetDescriptorOptions(styleURI: .satellite,
                                                                         minZoom: 0,
                                                                         maxZoom: 5,
                                                                         stylePackOptions: nil)
        let satelliteDescriptor = offlineManager.createTilesetDescriptor(for: satelliteTilesetDescriptorOptions)

        // 3 Load offline region
        tileStore = TileStore.getInstanceForPath(mapInitOptions.resourceOptions.tileStorePath!)

        let tileLoadOptions = TileLoadOptions(criticalPriority: false, acceptExpired: true, networkRestriction: .none)

        let offlineRegionLoadOptions = TileRegionLoadOptions(
            geometry: MBXGeometry(line: [
                CLLocationCoordinate2D(latitude: 51, longitude: 0),
                CLLocationCoordinate2D(latitude: 52, longitude: 1),
                CLLocationCoordinate2D(latitude: 51, longitude: 1),
                CLLocationCoordinate2D(latitude: 52, longitude: 0),
            ]),
            descriptors: [streetsDescriptor, satelliteDescriptor],
            metadata: nil,
            tileLoadOptions: tileLoadOptions,
            averageBytesPerSecond: nil)

        tileStore?.loadTileRegion(forId: "my_region5",
                                  loadOptions: offlineRegionLoadOptions) { (progress) in
            guard let progress = progress else {
                return
            }
            print("progress = \(progress)")
        } completion: { (result: Result<TileRegion, TileRegionError>) in
            switch result {
            case let .success(tileRegion2):
                print("tileRegion = \(tileRegion2)")

            case let .failure(error):
                print("tile download error = \(error)")
                return
            }

            DispatchQueue.main.async {
                self.mapView.cameraManager.setCamera(to: CameraOptions(center: CLLocationCoordinate2D(latitude: 51, longitude: 0)))
            }
        }
    }
}

extension TileRegionLoadProgress {
    public override var description: String {
        """
        <\(super.description)
            completedResourceCount = \(completedResourceCount)
            completedResourceSize = \(completedResourceSize)
            erroredResourceCount = \(erroredResourceCount)
            requiredResourceCount = \(requiredResourceCount)\
        >
        """
    }
}

extension TileRegion {
    public override var description: String {
        """
        <\(super.description)
            requiredResourceCount = \(requiredResourceCount)
            completedResourceCount = \(completedResourceCount)
        >
        """
    }
}

extension StylePack {
    public override var description: String {
        """
        <\(super.description)
            requiredResourceCount = \(requiredResourceCount)
            completedResourceCount = \(completedResourceCount)
        >
        """
    }
}
