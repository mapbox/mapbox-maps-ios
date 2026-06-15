import XCTest
@testable import MapboxMaps

final class OfflineManagerIntegrationTestCase: IntegrationTestCase {

    var tileStorePathURL: URL!
    var tileStore: TileStore!
    var offlineManager: OfflineManager!
    var tileRegionId = ""

    let tokyoCoord = CLLocationCoordinate2D(latitude: 35.682027, longitude: 139.769305)
    var tileRegionLoadOptions: TileRegionLoadOptions!

    override func setUpWithError() throws {
        try super.setUpWithError()
        try setupTileStoreAndOfflineManager()
    }

    func setupTileStoreAndOfflineManager() throws {
        tileRegionId = "tile-region-\(name)"

        tileStore = TileStore.default
        let ss = SettingsServiceFactory.getInstance(storageType: SettingsServiceStorageType.nonPersistent)
        let pathResult = ss.getForKey("com.mapbox.common.tilestore.location")
        tileStorePathURL = pathResult.isValue() ? (pathResult.value as? String).flatMap({ URL(fileURLWithPath: $0) }) : nil

        MapboxMapsOptions.dataPath = tileStorePathURL
        MapboxMapsOptions.tileStore = tileStore

        offlineManager = OfflineManager()

        // Setup TileRegionLoadOptions
        let outdoorsOptions = TilesetDescriptorOptions(styleURI: .outdoors,
                                                       zoomRange: 0...16, tilesets: nil)

        let outdoorsDescriptor = offlineManager.createTilesetDescriptor(for: outdoorsOptions)

        /// Load the tile region
        tileRegionLoadOptions = TileRegionLoadOptions(geometry: .point(Point(tokyoCoord)),
                                                      descriptors: [outdoorsDescriptor],
                                                      metadata: ["tag": "my-outdoors-tile-region"],
                                                      acceptExpired: true,
                                                      averageBytesPerSecond: nil)!
    }

    override func tearDownWithError() throws {
        // Remove tile region before releasing the tile store to prevent
        // stale regions from leaking into subsequent tests.
        if let tileStore = tileStore, !tileRegionId.isEmpty {
            let removeExpectation = expectation(description: "Remove tile region")
            tileStore.removeTileRegion(forId: tileRegionId)
            // Force eviction of tile data, then restore default quota
            tileStore.setOptionForKey(TileStoreOptions.diskQuota, value: 0)
            tileStore.allTileRegions { _ in
                removeExpectation.fulfill()
            }
            wait(for: [removeExpectation], timeout: 10.0)
            tileStore.setOptionForKey(TileStoreOptions.diskQuota, value: NSNull())
        }

        tileRegionLoadOptions = nil
        offlineManager = nil
        tileStore = nil

        let clearDataExpectation = expectation(description: "Clear map data")
        MapboxMapsOptions.clearData { _ in
            clearDataExpectation.fulfill()
        }
        wait(for: [clearDataExpectation], timeout: 10.0)

        tileStorePathURL = nil

        try super.tearDownWithError()
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

    private func disableOfflineCompositing() {
        let ss = SettingsServiceFactory.getInstance(storageType: SettingsServiceStorageType.nonPersistent)
        let setResult = ss.set(key: "com.mapbox.maps.experimental.offline_vt_compositing", value: false)
        switch setResult {
        case .success:
            print("Turned off vt compositing")
        case .failure(let error):
            XCTFail("Error turning off vt compositing: \(String(describing: error.errorDescription))")
        }
    }

    func testMapCanBeLoadediWithoutNetworkConnectivity() throws {
        // When asked for higher-level zoom tiles, and no tile with this specific zoom present in tile store,
        // offline compositing overscales lower-zoom tiles and request higher-level tiles from the network,
        // which leads to a test failure.
        // In some future we won't have composite sources in styles which use compositing.
        // So here we will mimick this future behavior for now.
        disableOfflineCompositing()

        try guardForMetalDevice()

        let rootView = try XCTUnwrap(rootViewController?.view)

        var abortTest = false

        XCTContext.runActivity(named: "Load TileRegion & StylePack") { _ in
            // 1. Load TileRegion from network
            let loadTileRegionCompletionBlockInvoked = expectation(description: "loadTileRegion completion block invoked")

            /// Perform the download
            let tileRegionCancelable = tileStore.loadTileRegion(
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

            let stylePackCancelable = offlineManager.loadStylePack(
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

            let waiter = XCTWaiter()
            let expectations: Set<XCTestExpectation> = [loadStylePackCompletionBlockInvoked,
                                loadTileRegionCompletionBlockInvoked]
            let result = waiter.wait(for: Array(expectations), timeout: 200)
            switch result {
            case .completed:
                break
            default:
                tileRegionCancelable.cancel()
                stylePackCancelable.cancel()

                let unfullfilledExpectations = expectations.subtracting(Set(waiter.fulfilledExpectations))
                XCTFail("Expectation failed with \(result), unfullfilled expectations: \(unfullfilledExpectations). Aborting test.")
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
            let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .outdoors)
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

            let cancelable = mapView.mapboxMap.onResourceRequest.observe { event in
                if event.source == .network {
                    XCTFail("Loading is occurring from the network")
                } else {
                    mapIsUsingDatabase.fulfill()
                }
            }

            mapView.mapboxMap.onMapLoaded.observeNext { _ in
                print("Map was loaded")
                mapWasLoaded.fulfill()
            }.store(in: &cancelables)

            let expectations = [mapIsUsingDatabase, mapWasLoaded]
            wait(for: expectations, timeout: 5.0, enforceOrder: true)

            cancelable.cancel()

            OfflineSwitch.shared.isMapboxStackConnected = true
            mapView.removeFromSuperview()
        }
    }
}
