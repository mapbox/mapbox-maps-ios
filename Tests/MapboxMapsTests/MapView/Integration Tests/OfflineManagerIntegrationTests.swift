import XCTest
@testable import MapboxMaps

// swiftlint:disable force_cast
internal class OfflineManagerIntegrationTestCase: IntegrationTestCase {

    var tileStorePathURL: URL!
    var tileStore: TileStore!
    var resourceOptions: ResourceOptions!
    var offlineManager: OfflineManager!
    var tileRegionId = ""

    let tokyoCoord = CLLocationCoordinate2D(latitude: 35.682027, longitude: 139.769305)
    var tileRegionLoadOptions: TileRegionLoadOptions!

    override func setUpWithError() throws {
        try super.setUpWithError()
        accessToken = try mapboxAccessToken()

        tileRegionId = "tile-region-\(name)"

        // TileStore
        tileStorePathURL = try TileStore.fileURLForDirectory(for: name.fileSystemSafeString())
        tileStore = TileStore.shared(for: tileStorePathURL.path)

        // OfflineManager
        // Setting the TileStore here has the side effect of setting its access
        // token
        resourceOptions = ResourceOptions(accessToken: accessToken,
                                          tileStore: tileStore)

        offlineManager = OfflineManager(resourceOptions: resourceOptions)

        // Setup TileRegionLoadOptions
        let outdoorsOptions = TilesetDescriptorOptions(styleURI: .outdoors,
                                                       zoomRange: 0...16)

        let outdoorsDescriptor = offlineManager.createTilesetDescriptor(for: outdoorsOptions)

        /// Load the tile region
        tileRegionLoadOptions = TileRegionLoadOptions(geometry: Geometry(coordinate: self.tokyoCoord),
                                                      descriptors: [outdoorsDescriptor],
                                                      metadata: ["tag": "my-outdoors-tile-region"],
                                                      acceptExpired: true,
                                                      averageBytesPerSecond: nil)!

    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        tileStore = nil
        tileRegionLoadOptions = nil
        resourceOptions = nil
        offlineManager = nil

        // Wait before removing directory
        let expectation = self.expectation(description: "Wait...")
        _ = XCTWaiter.wait(for: [expectation], timeout: 1.0)

        if let tileStorePathURL = tileStorePathURL {
            try TileStore.removeDirectory(at: tileStorePathURL)
        }
    }

    // MARK: Test Cases

    internal func testProgressAndCompletionBlocksBaseCase() throws {

        /// Expectations to be fulfilled
        let downloadInProgress = XCTestExpectation(description: "Downloading offline tiles in progress")
        downloadInProgress.assertForOverFulfill = false
        let completionBlockReached = XCTestExpectation(description: "Checks that completion block closure has been reached")

        /// Perform the download
        tileStore.loadTileRegion(forId: tileRegionId,
                                 loadOptions: tileRegionLoadOptions!) { _ in
            DispatchQueue.main.async {
                print(".", terminator: "")
                downloadInProgress.fulfill()
            }
        } completion: { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(region):
                    if region.requiredResourceCount == region.completedResourceCount {
                        print("✔︎")
                        completionBlockReached.fulfill()
                    } else {
                        print("𐄂")
                        XCTFail("Not all items were loaded")
                    }
                case let .failure(error):
                    print("𐄂")
                    XCTFail("Download failed with error: \(error)")
                }
            }
        }

        let expectations = [downloadInProgress, completionBlockReached]
        wait(for: expectations, timeout: 30.0)
    }

    internal func testProgressCanBeCancelled() throws {
        /// Expectations to be fulfilled
        let downloadWasCancelled = XCTestExpectation(description: "Checks a cancel function was reached and that the download was canceled")

        /// Perform the download
        let download = tileStore.loadTileRegion(forId: tileRegionId,
                                                loadOptions: tileRegionLoadOptions!) { _ in }
            completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        XCTFail("Result reached success block, therefore download was not canceled")
                    case let .failure(error):
                        if case TileRegionError.canceled = error {
                            downloadWasCancelled.fulfill()
                        } else {
                            XCTFail("Download was not canceled")
                        }
                    }
                }
            }

        DispatchQueue.main.async {
            download.cancel()
        }

        let expectations = [downloadWasCancelled]
        wait(for: expectations, timeout: 10.0)
    }

    internal func testOfflineRegionCanBeDeleted() throws {
        /// Expectations to be fulfilled
        let tileRegionDownloaded = XCTestExpectation(description: "Downloaded offline tiles")

        /// Perform the download
        tileStore.loadTileRegion(forId: tileRegionId,
                                 loadOptions: tileRegionLoadOptions!) { _ in }
            completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let region):
                        if region.requiredResourceCount == region.completedResourceCount {
                            tileRegionDownloaded.fulfill()
                        } else {
                            XCTFail("Not all items were loaded")
                        }

                    case .failure(let error):
                        print("𐄂")
                        XCTFail("Download failed with error: \(error)")
                    }
                }
            }

        wait(for: [tileRegionDownloaded], timeout: 30.0)

        // Now delete
        let downloadWasDeleted = XCTestExpectation(description: "Downloaded offline tiles were deleted")

        tileStore.removeTileRegion(forId: self.tileRegionId)

        tileStore.allTileRegions { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tileRegions):
                    if tileRegions.count == 0 {
                        downloadWasDeleted.fulfill()
                    } else {
                        XCTFail("Tile regions still remain.")
                    }
                case .failure(let error):
                    XCTFail("Error getting tile regions with error: \(error)")
                }
            }
        }

        wait(for: [downloadWasDeleted], timeout: 5.0)
    }

    internal func testMapCanBeLoadedWithoutNetworkConnectivity() throws {

        guard let rootView = rootViewController?.view else {
            throw XCTSkip("No valid UIWindow or root view controller")
        }

        guard MTLCreateSystemDefaultDevice() != nil else {
            throw XCTSkip("No valid Metal device (OS version or VM?)")
        }

        // 1. Load TileRegion from network
        let tileRegionLoaded = XCTestExpectation(description: "Tile region has loaded")

        /// Perform the download
        tileStore.loadTileRegion(forId: tileRegionId,
                                 loadOptions: tileRegionLoadOptions!) { _ in }
            completion: { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(region):
                    if region.requiredResourceCount == region.completedResourceCount {
                        print("✔︎")
                        tileRegionLoaded.fulfill()
                    } else {
                        print("𐄂")
                        XCTFail("Not all items were loaded")
                    }
                case let .failure(error):
                    print("𐄂")
                    XCTFail("Download failed with error: \(error)")
                }
            }
        }

        // - - - - - - - -
        // 2. stylepack

        let stylePackLoaded = expectation(description: "StylePack was loaded")
        let stylePackOptions = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                                    metadata: ["tag": "my-outdoors-style-pack"])!

        offlineManager.loadStylePack(for: .outdoors,
                                     loadOptions: stylePackOptions) { result in
            DispatchQueue.main.async {
                print("StylePack completed: \(result)")
                switch result {
                case let .failure(error):
                    XCTFail("stylePackLoaded error: \(error)")
                case .success:
                    stylePackLoaded.fulfill()
                }
            }
        }

        wait(for: [stylePackLoaded, tileRegionLoaded], timeout: 30.0)

        // - - - - - - - -
        // 3. Disable load-from-network, and try launch map at this location

        OfflineSwitch.shared.isMapboxStackConnected = false

        let cameraOptions = CameraOptions(center: tokyoCoord, zoom: 16)
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions,
                                            cameraOptions: cameraOptions,
                                            styleURI: .outdoors)
        let mapView = MapView(frame: rootView.bounds, mapInitOptions: mapInitOptions)
        rootView.addSubview(mapView)

        /// Expectations to be fulfilled
        let mapIsUsingDatabase = XCTestExpectation(description: "Map is using database for resources")
        mapIsUsingDatabase.assertForOverFulfill = false

        let mapWasLoaded = XCTestExpectation(description: "Map was loaded")

        mapView.mapboxMap.onEvery(.resourceRequest) { event in
            let eventElements = event.data as! [String: Any]
            let source = eventElements["data-source"] as! String
            if source == "network" {
                XCTFail("Loading is occurring from the network")
            } else {
                mapIsUsingDatabase.fulfill()
            }
        }

        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            mapWasLoaded.fulfill()
        }

        let expectations = [mapIsUsingDatabase, mapWasLoaded]
        wait(for: expectations, timeout: 5.0, enforceOrder: true)

        OfflineSwitch.shared.isMapboxStackConnected = true
    }
}
