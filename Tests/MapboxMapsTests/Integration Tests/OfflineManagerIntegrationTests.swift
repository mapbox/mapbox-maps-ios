import XCTest
@testable import MapboxMaps

final class OfflineManagerIntegrationTestCase: IntegrationTestCase {

    var tileStorePathURL: URL!
    var tileStore: TileStore!
    var resourceOptions: ResourceOptions!
    var offlineManager: OfflineManager!
    var tileRegionId = ""

    let tokyoCoord = CLLocationCoordinate2D(latitude: 35.682027, longitude: 139.769305)
    var tileRegionLoadOptions: TileRegionLoadOptions!

    override func setUpWithError() throws {
        try super.setUpWithError()
        try setupTileStoreAndOfflineManager()
    }

    func setupTileStoreAndOfflineManager() throws {
        accessToken = try mapboxAccessToken()

        tileRegionId = "tile-region-\(name)"

        // TileStore
        tileStorePathURL = try temporaryCacheDirectory()

        // Cache the created tile store
        tileStore = TileStore.shared(for: tileStorePathURL)
        tileStore.setOptionForKey(TileStoreOptions.mapboxAccessToken, value: accessToken!)

        resourceOptions = ResourceOptions(accessToken: accessToken,
                                          dataPathURL: tileStorePathURL,
                                          tileStore: tileStore)

        offlineManager = OfflineManager(resourceOptions: resourceOptions)

        // Setup TileRegionLoadOptions
        let outdoorsOptions = TilesetDescriptorOptions(styleURI: .outdoors,
                                                       zoomRange: 0...16)

        let outdoorsDescriptor = offlineManager.createTilesetDescriptor(for: outdoorsOptions)

        /// Load the tile region
        tileRegionLoadOptions = TileRegionLoadOptions(geometry: .point(Point(tokyoCoord)),
                                                      descriptors: [outdoorsDescriptor],
                                                      metadata: ["tag": "my-outdoors-tile-region"],
                                                      acceptExpired: true,
                                                      averageBytesPerSecond: nil)!
    }

    override func tearDownWithError() throws {
        tileRegionLoadOptions = nil
        offlineManager = nil
        tileStore = nil
        clearResourceOptions()
        try super.tearDownWithError()
    }

    private func clearResourceOptions() {
        defer {
            resourceOptions = nil
        }

        guard resourceOptions != nil else {
            return
        }

        let expectation = expectation(description: "Clear data")
        MapboxMap.clearData(for: resourceOptions) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    // MARK: Test Cases

    func testProgressAndCompletionBlocksBaseCase() throws {

        /// Expectations to be fulfilled
        let progressBlockInvoked = expectation(description: "Downloading offline tiles in progress")
        progressBlockInvoked.assertForOverFulfill = false
        let completionBlockInvoked = expectation(description: "Checks that completion block closure has been reached")

        /// Perform the download
        tileStore.loadTileRegion(
            forId: tileRegionId,
            loadOptions: tileRegionLoadOptions!,
            progress: { _ in
                DispatchQueue.main.async {
                    print(".", terminator: "")
                    progressBlockInvoked.fulfill()
                }
            },
            completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(region):
                        if region.requiredResourceCount == region.completedResourceCount {
                            print("✔︎")
                        } else {
                            XCTFail("Not all items were loaded")
                        }
                    case let .failure(error):
                        XCTFail("Download failed with error: \(error)")
                    }
                    completionBlockInvoked.fulfill()
                }
            })

        let expectations = [progressBlockInvoked, completionBlockInvoked]
        wait(for: expectations, timeout: 120.0)
    }

    func testProgressCanBeCancelled() throws {
        /// Expectations to be fulfilled
        let completionBlockInvoked = expectation(description: "Checks a cancel function was reached and that the download was canceled")

        /// Perform the download
        let download = tileStore.loadTileRegion(
            forId: tileRegionId,
            loadOptions: tileRegionLoadOptions!,
            progress: { _ in },
            completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        XCTFail("Result reached success block, therefore download was not canceled")
                    case let .failure(error):
                        if case TileRegionError.canceled = error {
                        } else {
                            XCTFail("Download was not canceled")
                        }
                    }
                    completionBlockInvoked.fulfill()
                }
            })

        DispatchQueue.main.async {
            download.cancel()
        }

        wait(for: [completionBlockInvoked], timeout: 10.0)
    }

    func testOfflineRegionCanBeDeleted() throws {
        /// Expectations to be fulfilled
        let loadTileRegionCompletionBlockInovked = expectation(description: "Downloaded offline tiles")

        /// Perform the download
        tileStore.loadTileRegion(
            forId: tileRegionId,
            loadOptions: tileRegionLoadOptions!,
            progress: { _ in },
            completion: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let region):
                        if region.requiredResourceCount != region.completedResourceCount {
                            XCTFail("Not all items were loaded")
                        }
                    case .failure(let error):
                        XCTFail("Download failed with error: \(error)")
                    }
                    loadTileRegionCompletionBlockInovked.fulfill()
                }
            })

        wait(for: [loadTileRegionCompletionBlockInovked], timeout: 120.0)

        // Now delete
        let allTileRegionsCompletionBlockInvoked = expectation(description: "Downloaded offline tiles were deleted")

        tileStore.removeTileRegion(forId: tileRegionId)

        tileStore.allTileRegions { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tileRegions):
                    if tileRegions.count != 0 {
                        XCTFail("Tile regions still remain.")
                    }
                case .failure(let error):
                    XCTFail("Error getting tile regions with error: \(error)")
                }
                allTileRegionsCompletionBlockInvoked.fulfill()
            }
        }

        wait(for: [allTileRegionsCompletionBlockInvoked], timeout: 120.0)
    }

    func testMapCanBeLoadedWithoutNetworkConnectivity() throws {
        try guardForMetalDevice()

        let rootView = try XCTUnwrap(rootViewController?.view)

        var abortTest = false

        XCTContext.runActivity(named: "Load TileRegion & StylePack") { _ in
            // 1. Load TileRegion from network
            let loadTileRegionCompletionBlockInvoked = expectation(description: "loadTileRegion completion block invoked")

            /// Perform the download
            tileStore.loadTileRegion(
                forId: tileRegionId,
                loadOptions: tileRegionLoadOptions!,
                progress: { _ in },
                completion: { result in
                    DispatchQueue.main.async {
                        switch result {
                        case let .success(region):
                            if region.requiredResourceCount == region.completedResourceCount {
                                print("✔︎")
                            } else {
                                XCTFail("Not all items were loaded")
                            }
                        case let .failure(error):
                            XCTFail("Download failed with error: \(error)")
                        }
                        loadTileRegionCompletionBlockInvoked.fulfill()
                    }
                })

            // - - - - - - - -
            // 2. stylepack

            let loadStylePackCompletionBlockInvoked = expectation(description: "loadStylePack completion block invoked")

            let stylePackOptions = StylePackLoadOptions(
                glyphsRasterizationMode: .ideographsRasterizedLocally,
                metadata: ["tag": "my-outdoors-style-pack"])!

            offlineManager.loadStylePack(
                for: .outdoors,
                   loadOptions: stylePackOptions,
                   completion: { result in
                       DispatchQueue.main.async {
                           print("StylePack completed: \(result)")
                           switch result {
                           case let .failure(error):
                               XCTFail("stylePackLoaded error: \(error)")
                           case .success:
                               break
                           }
                           loadStylePackCompletionBlockInvoked.fulfill()
                       }
                   })

            let result = XCTWaiter().wait(
                for: [loadStylePackCompletionBlockInvoked,
                      loadTileRegionCompletionBlockInvoked],
                timeout: 120)
            switch result {
            case .completed:
                break
            default:
                XCTFail("Expectation failed with \(result). Aborting test.")
                abortTest = true
            }
        }

        if abortTest {
            return
        }

        // - - - - - - - -
        // 3. Disable load-from-network, and try launch map at this location
        XCTContext.runActivity(named: "Disable load-from-network & Launch map") { _ in
            OfflineSwitch.shared.isMapboxStackConnected = false

            let cameraOptions = CameraOptions(center: tokyoCoord, zoom: 16)
            let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions,
                                                cameraOptions: cameraOptions,
                                                styleURI: .outdoors)
            let mapView = MapView(frame: rootView.bounds, mapInitOptions: mapInitOptions)
            rootView.addSubview(mapView)

            // Label
            let label = UILabel()
            label.text = name
            label.sizeToFit()
            label.frame.origin = CGPoint(x: 0, y: 60)
            mapView.addSubview(label)

            /// Expectations to be fulfilled
            let mapIsUsingDatabase = XCTestExpectation(description: "Map is using database for resources")
            mapIsUsingDatabase.assertForOverFulfill = false

            let mapWasLoaded = XCTestExpectation(description: "Map was loaded")

            let cancelable = mapView.mapboxMap.onEvery(event: .resourceRequest) { event in
                if event.payload.dataSource == .network {
                    XCTFail("Loading is occurring from the network")
                } else {
                    mapIsUsingDatabase.fulfill()
                }
            }

            mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
                print("Map was loaded")
                mapWasLoaded.fulfill()
            }

            let expectations = [mapIsUsingDatabase, mapWasLoaded]
            wait(for: expectations, timeout: 5.0, enforceOrder: true)

            cancelable.cancel()

            OfflineSwitch.shared.isMapboxStackConnected = true
            mapView.removeFromSuperview()
        }
    }
}
