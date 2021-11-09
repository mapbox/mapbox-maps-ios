import XCTest
@testable import MapboxMaps

// swiftlint:disable force_cast
internal class OfflineManagerIntegrationTestCase: IntegrationTestCase {

    var label: UILabel!
    var tileStorePathURL: URL!
    var tileStore: TileStore!
    var resourceOptions: ResourceOptions!
    var offlineManager: OfflineManager!
    var tileRegionId = ""

    weak var weakTileStore: TileStore?
    weak var weakOfflineManager: OfflineManager?

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
        weakTileStore = tileStore

        resourceOptions = ResourceOptions(accessToken: accessToken,
                                          dataPathURL: tileStorePathURL,
                                          tileStore: tileStore)

        offlineManager = OfflineManager(resourceOptions: resourceOptions)
        weakOfflineManager = offlineManager

        // Setup TileRegionLoadOptions
        let outdoorsOptions = TilesetDescriptorOptions(styleURI: .outdoors,
                                                       zoomRange: 0...16)

        let outdoorsDescriptor = offlineManager.createTilesetDescriptor(for: outdoorsOptions)

        /// Load the tile region
        tileRegionLoadOptions = TileRegionLoadOptions(geometry: .point(Point(self.tokyoCoord)),
                                                      descriptors: [outdoorsDescriptor],
                                                      metadata: ["tag": "my-outdoors-tile-region"],
                                                      acceptExpired: true,
                                                      averageBytesPerSecond: nil)!
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        label?.removeFromSuperview()
        label = nil

        tileRegionLoadOptions = nil
        offlineManager = nil
        tileStore = nil

        clearResourceOptions()

        XCTAssertNil(weakOfflineManager)
        XCTAssertNil(weakTileStore)
    }

    private func clearResourceOptions() {
        defer {
            resourceOptions = nil
        }

        guard resourceOptions != nil else {
            return
        }

        let expectation = self.expectation(description: "Clear data")
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

        let completionBlockDeallocated = expectation(description: "Completion block deallocated")

        autoreleasepool {
            let completionBlockDeallocatedObserver = DeallocationObserver(completionBlockDeallocated.fulfill)

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
                    dump(completionBlockDeallocatedObserver)
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
        }

        let expectations = [progressBlockInvoked, completionBlockInvoked, completionBlockDeallocated]
        wait(for: expectations, timeout: 120.0)
    }

    func testProgressCanBeCancelled() throws {
        /// Expectations to be fulfilled
        let completionBlockInvoked = expectation(description: "Checks a cancel function was reached and that the download was canceled")
        let completionBlockDeallocated = expectation(description: "Completion block deallocated")

        autoreleasepool {
            let completionBlockDeallocatedObserver = DeallocationObserver(completionBlockDeallocated.fulfill)

            /// Perform the download
            let download = tileStore.loadTileRegion(
                forId: tileRegionId,
                loadOptions: tileRegionLoadOptions!,
                progress: { _ in },
                completion: { result in
                    dump(completionBlockDeallocatedObserver)

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
        }

        let expectations = [completionBlockInvoked, completionBlockDeallocated]
        wait(for: expectations, timeout: 10.0)
    }

    func testOfflineRegionCanBeDeleted() throws {
        /// Expectations to be fulfilled
        let loadTileRegionCompletionBlockInovked = expectation(description: "Downloaded offline tiles")

        let loadTileRegionCompletionBlockDeallocated = expectation(description: "loadTileRegion completion block deallocated")

        autoreleasepool {
            let loadTileRegionClosureDeallocatedObserver = DeallocationObserver(loadTileRegionCompletionBlockDeallocated.fulfill)

            /// Perform the download
            tileStore.loadTileRegion(
                forId: tileRegionId,
                loadOptions: tileRegionLoadOptions!,
                progress: { _ in },
                completion: { result in
                    dump(loadTileRegionClosureDeallocatedObserver)

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
        }

        wait(for: [loadTileRegionCompletionBlockInovked, loadTileRegionCompletionBlockDeallocated], timeout: 120.0)

        // Now delete
        let allTileRegionsCompletionBlockInvoked = expectation(description: "Downloaded offline tiles were deleted")
        let allTileRegionsCompletionBlockDeallocated = expectation(description: "allTileRegions completion block deallocated")

        tileStore.removeTileRegion(forId: self.tileRegionId)

        autoreleasepool {
            let allTileRegionsCompletionBlockDeallocatedObserver = DeallocationObserver(allTileRegionsCompletionBlockDeallocated.fulfill)
            tileStore.allTileRegions { result in
                dump(allTileRegionsCompletionBlockDeallocatedObserver)
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
        }

        wait(for: [allTileRegionsCompletionBlockInvoked, allTileRegionsCompletionBlockDeallocated], timeout: 120.0)
    }

    func testMapCanBeLoadedWithoutNetworkConnectivity() throws {
        weak var weakMapView: MapView?

        try autoreleasepool {
            try guardForMetalDevice()

            guard let rootView = rootViewController?.view else {
                throw XCTSkip("No valid UIWindow or root view controller")
            }

            var abortTest = false

            XCTContext.runActivity(named: "Load TileRegion & StylePack") { _ in
                // 1. Load TileRegion from network
                let loadTileRegionCompletionBlockInvoked = expectation(description: "loadTileRegion completion block invoked")
                let loadTileRegionCompletionBlockDeallocated = expectation(description: "loadTileRegion completion block deallocated")
                autoreleasepool {
                    let loadTileRegionCompletionBlockDeallocatedObserver = DeallocationObserver(loadTileRegionCompletionBlockDeallocated.fulfill)

                    /// Perform the download
                    tileStore.loadTileRegion(
                        forId: tileRegionId,
                        loadOptions: tileRegionLoadOptions!,
                        progress: { _ in },
                        completion: { result in
                            dump(loadTileRegionCompletionBlockDeallocatedObserver)
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
                }

                // - - - - - - - -
                // 2. stylepack

                let loadStylePackCompletionBlockInvoked = expectation(description: "loadStylePack completion block invoked")
                let loadStylePackCompletionBlockDeallocated = expectation(description: "loadStylePack completion block deallocated")

                let stylePackOptions = StylePackLoadOptions(
                    glyphsRasterizationMode: .ideographsRasterizedLocally,
                    metadata: ["tag": "my-outdoors-style-pack"])!

                autoreleasepool {
                    let loadStylePackCompletionBlockDeallocatedObserver = DeallocationObserver(loadStylePackCompletionBlockDeallocated.fulfill)

                    offlineManager.loadStylePack(
                        for: .outdoors,
                        loadOptions: stylePackOptions,
                        completion: { result in
                            dump(loadStylePackCompletionBlockDeallocatedObserver)
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
                }

                let result = XCTWaiter().wait(
                    for: [
                        loadStylePackCompletionBlockInvoked,
                        loadStylePackCompletionBlockDeallocated,
                        loadTileRegionCompletionBlockInvoked,
                        loadTileRegionCompletionBlockDeallocated
                    ],
                    timeout: 120.0)

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
                label = UILabel()
                label.text = name
                label.sizeToFit()
                label.frame.origin = CGPoint(x: 0, y: 60)
                mapView.addSubview(label)

                weakMapView = mapView

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
                    print("Map was loaded")
                    mapWasLoaded.fulfill()
                }

                let expectations = [mapIsUsingDatabase, mapWasLoaded]
                wait(for: expectations, timeout: 5.0, enforceOrder: true)

                OfflineSwitch.shared.isMapboxStackConnected = true
                mapView.removeFromSuperview()
            }
        }

        XCTAssertNil(weakMapView)
    }

    // Release tests

    func testTileStoreImmediateRelease() throws {
        let loadTileRegionCompletionBlockInvoked = expectation(description: "Completion called")
        let loadTileRegionCompletionBlockDeallocated = expectation(description: "Closure deallocated")

        autoreleasepool {
            let loadTileRegionCompletionBlockDeallocatedObserver = DeallocationObserver(loadTileRegionCompletionBlockDeallocated.fulfill)

            tileStore.loadTileRegion(forId: tileRegionId,
                                     loadOptions: tileRegionLoadOptions!) { _ in
                dump(loadTileRegionCompletionBlockDeallocatedObserver)
                DispatchQueue.main.async {
                    loadTileRegionCompletionBlockInvoked.fulfill()
                }
            }
        }

        tileRegionLoadOptions = nil
        tileStore = nil
        offlineManager = nil

        wait(for: [loadTileRegionCompletionBlockInvoked, loadTileRegionCompletionBlockDeallocated], timeout: 30.0)

        clearResourceOptions()

        XCTAssertNil(weakTileStore)
        XCTAssertNil(weakOfflineManager)
    }

    func testTileStoreDelayedRelease() throws {
        let loadTileRegionCompletionBlockInvoked = expectation(description: "Completion called")
        let loadTileRegionCompletionBlockDeallocated = expectation(description: "Closure deallocated")

        autoreleasepool {
            let loadTileRegionCompletionBlockDeallocatedObserver = DeallocationObserver(loadTileRegionCompletionBlockDeallocated.fulfill)

            tileStore.loadTileRegion(forId: tileRegionId,
                                     loadOptions: tileRegionLoadOptions!) { _ in
                dump(loadTileRegionCompletionBlockDeallocatedObserver)
                DispatchQueue.main.async {
                    loadTileRegionCompletionBlockInvoked.fulfill()
                }
            }
        }

        tileRegionLoadOptions = nil

        // Wait a short time, so download starts
        let expect2 = expectation(description: "Wait")
        _ = XCTWaiter.wait(for: [expect2], timeout: 0.25)

        // Now release. loadTileRegion should retain tileStore, so completion
        // block should continue
        tileStore = nil
        offlineManager = nil

        wait(for: [loadTileRegionCompletionBlockInvoked], timeout: 60.0)
        wait(for: [loadTileRegionCompletionBlockDeallocated], timeout: 5.0)

        clearResourceOptions()

        XCTAssertNil(weakTileStore)
        XCTAssertNil(weakOfflineManager)
    }

    func testTileStoreDelayedReleaseWithCapture() throws {
        let loadTileRegionCompletionBlockInvoked = expectation(description: "Completion called")
        let loadTileRegionCompletionBlockDeallocated = expectation(description: "Closure deallocated")

        do {
            let tileStore2 = tileStore
            autoreleasepool {
                let loadTileRegionCompletionBlockDeallocatedObserver = DeallocationObserver(loadTileRegionCompletionBlockDeallocated.fulfill)
                tileStore.loadTileRegion(forId: tileRegionId,
                                         loadOptions: tileRegionLoadOptions!) { _ in
                    dump(loadTileRegionCompletionBlockDeallocatedObserver)
                    DispatchQueue.main.async {
                        dump(tileStore2)
                        loadTileRegionCompletionBlockInvoked.fulfill()
                    }
                }
            }

            tileRegionLoadOptions = nil

            // Wait a short time, so download starts
            let expect2 = expectation(description: "Wait")
            _ = XCTWaiter.wait(for: [expect2], timeout: 0.25)

            // Now release. loadTileRegion should retain tileStore, so completion
            // block should continue
            tileStore = nil
            offlineManager = nil

            wait(for: [loadTileRegionCompletionBlockInvoked, loadTileRegionCompletionBlockDeallocated], timeout: 120.0)

            clearResourceOptions()
        }

        XCTAssertNil(weakTileStore)
        XCTAssertNil(weakOfflineManager)
    }

    func testTileStoreDelayedReleaseWithCaptureButReleasingOfflineManager() throws {
        let loadTileRegionCompletionBlockInvoked = expectation(description: "Completion called")
        let loadTileRegionCompletionBlockDeallocated = expectation(description: "Closure deallocated")
        var closure: ((Result<TileRegion, Error>) -> Void)?

        autoreleasepool {
            let tileStore2 = tileStore
            closure = { _ in
                let loadTileRegionCompletionBlockDeallocated = DeallocationObserver(loadTileRegionCompletionBlockDeallocated.fulfill)
                dump(loadTileRegionCompletionBlockDeallocated)
                DispatchQueue.main.async {
                    dump(tileStore2)
                    loadTileRegionCompletionBlockInvoked.fulfill()
                }
            }

            tileStore.loadTileRegion(forId: tileRegionId,
                                     loadOptions: tileRegionLoadOptions!) { result in
                closure?(result)
            }
        }

        // Release
        tileRegionLoadOptions = nil
        tileStore = nil

        offlineManager = nil
        XCTAssertNil(weakOfflineManager)

        // Wait a short time
        let expect2 = expectation(description: "Wait")
        _ = XCTWaiter.wait(for: [expect2], timeout: 0.25)

        wait(for: [loadTileRegionCompletionBlockInvoked, loadTileRegionCompletionBlockDeallocated], timeout: 60.0)

        clearResourceOptions()

        // This fails because the completion block is holding the tilestore
        // and is not called, so does not get released afterwards.

        // Since this test is failing, the tilestore needs to be cleaned up
        // manually.
        closure = nil
        XCTAssertNil(weakTileStore)
    }
}
