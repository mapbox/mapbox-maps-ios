import XCTest
@testable import MapboxMaps

// swiftlint:disable force_cast empty_enum_arguments

internal class OfflineManagerIntegrationTestCase: MapViewIntegrationTestCase {

    // MARK: Reusable test properties

    /// Offline manager properties
    private lazy var resourceOptions = ResourceOptions(accessToken: accessToken)
    private lazy var offlineManager = OfflineManager(resourceOptions: resourceOptions)
    private let tileRegionId = "myTileRegion"

    /// Tokyo coordinates
    private let tokyoCoord = CLLocationCoordinate2D(latitude: 35.682027, longitude: 139.769305)

    /// Tile Region Options
    internal var tileRegionLoadOptions: TileRegionLoadOptions?

    override func setUp() {
        super.setUp()

        /// Create an offline region with tiles using the "outdoors" style
        let stylePackOptions = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                                    metadata: ["tag": "my-outdoors-style-pack"])!

        _ = offlineManager.loadStylePack(for: .outdoors, loadOptions: stylePackOptions) { _ in } completion: { _ in }

        let outdoorsOptions = TilesetDescriptorOptions(styleURI: .outdoors,
                                                       zoomRange: 0...16,
                                                       stylePackOptions: stylePackOptions)

        let outdoorsDescriptor = offlineManager.createTilesetDescriptor(for: outdoorsOptions)

        /// Load the tile region
        let tileLoadOptions = TileLoadOptions(criticalPriority: false,
                                              acceptExpired: true,
                                              networkRestriction: .none)

        tileRegionLoadOptions = TileRegionLoadOptions(geometry: MBXGeometry(coordinate: self.tokyoCoord),
                                                      descriptors: [outdoorsDescriptor],
                                                      metadata: ["tag": "my-outdoors-tile-region"],
                                                      tileLoadOptions: tileLoadOptions,
                                                      averageBytesPerSecond: nil)!
    }

    override func tearDown() {
        super.tearDown()
        tileRegionLoadOptions = nil
    }

    // MARK: Test Cases

    internal func testProgressAndCompletionBlocksBaseCase() {
        /// Expectations to be fulfilled
        let downloadInProgress = XCTestExpectation(description: "Downloading offline tiles in progress")
        downloadInProgress.assertForOverFulfill = false
        let completionBlockReached = XCTestExpectation(description: "Checks that completion block closure has been reached")

        /// Perform the download
        TileStore.getInstance().loadTileRegion(forId: tileRegionId,
                                               loadOptions: tileRegionLoadOptions!) { _ in
            DispatchQueue.main.async {
                downloadInProgress.fulfill()
            }
        } completion: { result in
            switch result {
            case .success(let region):
                if region.requiredResourceCount == region.completedResourceCount {
                    completionBlockReached.fulfill()
                } else {
                    XCTFail("Not all items were loaded")
                }
            case .failure(let error):
                XCTFail("Download failed with error: \(error)")
            }
        }

        let expectations = [downloadInProgress, completionBlockReached]
        wait(for: expectations, timeout: 5.0)
    }

    internal func testProgressCanBeCancelled() {

        /// Expectations to be fulfilled
        let downloadWasCancelled = XCTestExpectation(description: "Checks a cancel function was reached and that the download was canceled")

        /// Perform the download
        let download = TileStore.getInstance().loadTileRegion(forId: tileRegionId,
                                                              loadOptions: tileRegionLoadOptions!) { _ in }
        completion: { result in
            switch result {
            case .success(_):
                XCTFail("Result reached success block, therefore download was not canceled")
            case .failure(let error):
                if error.localizedDescription == "Load was canceled" {
                    downloadWasCancelled.fulfill()
                } else {
                    XCTFail("Download was not canceled")
                }
            }
        }

        download.cancel()

        let expectations = [downloadWasCancelled]
        wait(for: expectations, timeout: 5.0)
    }

    internal func testOfflineRegionCanBeDeleted() {

        /// Expectations to be fulfilled
        let downloadWasDeleted = XCTestExpectation(description: "Downloaded offline tiles were deleted")

        /// Perform the download
        TileStore.getInstance().loadTileRegion(forId: tileRegionId,
                                               loadOptions: tileRegionLoadOptions!) { _ in } completion: { _ in }

        /// Waiting for the load tile to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            TileStore.getInstance().removeTileRegion(forId: self.tileRegionId)

            TileStore.getInstance().allTileRegions(completion: { result in
                switch result {
                case .success(let tileRegions):
                    if tileRegions.count == 0 {
                        downloadWasDeleted.fulfill()
                    }
                case .failure(let error):
                    XCTFail("Error getting tile regions with error: \(error)")
                }
            })
        }

        let expectations = [downloadWasDeleted]
        wait(for: expectations, timeout: 5.0)
    }

    internal func testMapCanBeLoadedWithoutNetworkConnectivity() {
        /// Expectations to be fulfilled
        let mapDidLoad = XCTestExpectation(description: "Map was loaded")

        /// Perform the download
        TileStore.getInstance().loadTileRegion(forId: tileRegionId,
                                               loadOptions: tileRegionLoadOptions!) { _ in } completion: { _ in }

        NetworkConnectivity.getInstance().setMapboxStackConnectedForConnected(false)

        self.mapView!.on(.resourceRequest) { event in
            let eventElements = event.data as! [String: Any]

            for element in eventElements {
                if element.key == "data-source" && element.value as! String == "database" {
                    mapDidLoad.fulfill()
                }
            }
        }

        let expectations = [mapDidLoad]
        wait(for: expectations, timeout: 5.0)

        NetworkConnectivity.getInstance().setMapboxStackConnectedForConnected(true)
    }
}
