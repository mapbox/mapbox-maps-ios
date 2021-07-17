import XCTest
@testable import MapboxMaps

// swiftlint:disable force_cast type_body_length file_length
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
        tileStore.setOptionForKey(TileStoreOptions.mapboxAccessToken, value: accessToken as Any)
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
        tileRegionLoadOptions = TileRegionLoadOptions(geometry: Geometry(coordinate: self.tokyoCoord),
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

    internal func testProgressAndCompletionBlocksBaseCase() throws {

        /// Expectations to be fulfilled
        let downloadInProgress = expectation(description: "Downloading offline tiles in progress")
        downloadInProgress.assertForOverFulfill = false
        let completionBlockReached = expectation(description: "Checks that completion block closure has been reached")

        let closureDeallocation = expectation(description: "Closure deallocated")

        /// Perform the download
        tileStore.loadTileRegion(forId: tileRegionId,
                                 loadOptions: tileRegionLoadOptions!) { _ in
            DispatchQueue.main.async {
                print(".", terminator: "")
                downloadInProgress.fulfill()
            }
        } completion: { result in

            DispatchQueue.main.async {
                let observer = DeallocationObserver(closureDeallocation.fulfill)
                dump(observer)

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

        let expectations = [downloadInProgress, completionBlockReached, closureDeallocation]
        wait(for: expectations, timeout: 120.0)
    }

    internal func testProgressCanBeCancelled() throws {
        /// Expectations to be fulfilled
        let downloadWasCancelled = expectation(description: "Checks a cancel function was reached and that the download was canceled")
        let closureDeallocation = expectation(description: "Closure deallocated")

        /// Perform the download
        let download = tileStore.loadTileRegion(forId: tileRegionId,
                                                loadOptions: tileRegionLoadOptions!) { _ in }
            completion: { result in
                DispatchQueue.main.async {
                    let observer = DeallocationObserver(closureDeallocation.fulfill)
                    dump(observer)

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

        let expectations = [downloadWasCancelled, closureDeallocation]
        wait(for: expectations, timeout: 10.0)
    }

    internal func testOfflineRegionCanBeDeleted() throws {
        /// Expectations to be fulfilled
        let tileRegionDownloaded = expectation(description: "Downloaded offline tiles")

        let loadTileRegionClosureDeallocation = expectation(description: "Closure deallocated")

        /// Perform the download
        tileStore.loadTileRegion(forId: tileRegionId,
                                 loadOptions: tileRegionLoadOptions!) { _ in }
            completion: { result in
                DispatchQueue.main.async {
                    let observer = DeallocationObserver(loadTileRegionClosureDeallocation.fulfill)
                    dump(observer)

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

        wait(for: [tileRegionDownloaded, loadTileRegionClosureDeallocation], timeout: 120.0)

        // Now delete
        let downloadWasDeleted = XCTestExpectation(description: "Downloaded offline tiles were deleted")
        let allTileRegionsClosureDeallocation = expectation(description: "Closure deallocated")

        tileStore.removeTileRegion(forId: self.tileRegionId)

        tileStore.allTileRegions { result in
            DispatchQueue.main.async {
                let observer = DeallocationObserver(allTileRegionsClosureDeallocation.fulfill)
                dump(observer)

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

        wait(for: [downloadWasDeleted, allTileRegionsClosureDeallocation], timeout: 120.0)
    }

    internal func testMapCanBeLoadedWithoutNetworkConnectivity() throws {
        weak var weakMapView: MapView?

        try autoreleasepool {
            try guardForMetalDevice()

            guard let rootView = rootViewController?.view else {
                throw XCTSkip("No valid UIWindow or root view controller")
            }

            var abortTest = false

            XCTContext.runActivity(named: "Load TileRegion & StylePack") { _ in
                // 1. Load TileRegion from network
                let tileRegionLoaded = XCTestExpectation(description: "Tile region has loaded")
                let tileRegionLoadedClosureDeallocation = expectation(description: "tileRegionLoaded Closure deallocated")

                /// Perform the download
                tileStore.loadTileRegion(forId: tileRegionId,
                                         loadOptions: tileRegionLoadOptions!) { _ in }
                    completion: { result in
                        DispatchQueue.main.async {
                            let observer = DeallocationObserver(tileRegionLoadedClosureDeallocation.fulfill)
                            dump(observer)

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
                let stylePackLoadedClosureDeallocation = expectation(description: "stylePackLoaded Closure deallocated")

                let stylePackOptions = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                                            metadata: ["tag": "my-outdoors-style-pack"])!

                offlineManager.loadStylePack(for: .outdoors,
                                             loadOptions: stylePackOptions) { result in
                    DispatchQueue.main.async {
                        let observer = DeallocationObserver(stylePackLoadedClosureDeallocation.fulfill)
                        dump(observer)

                        print("StylePack completed: \(result)")
                        switch result {
                        case let .failure(error):
                            XCTFail("stylePackLoaded error: \(error)")
                        case .success:
                            stylePackLoaded.fulfill()
                        }
                    }
                }

                let result = XCTWaiter().wait(for: [stylePackLoaded,
                                                    stylePackLoadedClosureDeallocation,
                                                    tileRegionLoaded,
                                                    tileRegionLoadedClosureDeallocation],
                                              timeout: 120.0)
                switch result {
                case .completed:
                    break
                case .timedOut:
                    // TODO: check if this is a failure
                    print("Timed out.")
                    fallthrough
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
        let functionName = name

        let expect = expectation(description: "Completion called")
        let closureDeallocation = expectation(description: "Closure deallocated")

        tileStore.loadTileRegion(forId: tileRegionId,
                                 loadOptions: tileRegionLoadOptions!) { _ in
            DispatchQueue.main.async {
                let observer = DeallocationObserver(closureDeallocation.fulfill)
                dump(observer)

                print("\(functionName): Completion block called")
                expect.fulfill()
            }
        }

        tileRegionLoadOptions = nil
        tileStore = nil
        offlineManager = nil

        wait(for: [expect, closureDeallocation], timeout: 30.0)

        clearResourceOptions()

        XCTAssertNil(weakTileStore)
        XCTAssertNil(weakOfflineManager)
    }

    func testTileStoreDelayedRelease() throws {
        let functionName = name

        let expect = expectation(description: "Completion called")
        let closureDeallocation = expectation(description: "Closure deallocated")

        tileStore.loadTileRegion(forId: tileRegionId,
                                 loadOptions: tileRegionLoadOptions!) { _ in
            DispatchQueue.main.async {
                print("\(functionName): Completion block called")
                let observer = DeallocationObserver(closureDeallocation.fulfill)
                dump(observer)
                expect.fulfill()
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

        wait(for: [expect], timeout: 60.0)
        wait(for: [closureDeallocation], timeout: 5.0)

        clearResourceOptions()

        XCTAssertNil(weakTileStore)
        XCTAssertNil(weakOfflineManager)
    }

    func testTileStoreDelayedReleaseWithCapture() throws {
        let functionName = name

        let expect = expectation(description: "Completion called")
        let closureDeallocation = expectation(description: "Closure deallocated")

        do {
            let tileStore2 = tileStore
            tileStore.loadTileRegion(forId: tileRegionId,
                                     loadOptions: tileRegionLoadOptions!) { _ in
                DispatchQueue.main.async {
                    dump(tileStore2)

                    print("\(functionName): Completion block called")
                    let observer = DeallocationObserver(closureDeallocation.fulfill)
                    dump(observer)
                    expect.fulfill()
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

            wait(for: [expect, closureDeallocation], timeout: 120.0)

            clearResourceOptions()
        }

        XCTAssertNil(weakTileStore)
        XCTAssertNil(weakOfflineManager)
    }

    func testTileStoreDelayedReleaseWithCaptureButReleasingOfflineManager() throws {

        let functionName = name
        let expect = expectation(description: "Completion called")
        let closureDeallocation = expectation(description: "Closure deallocated")
        var closure: ((Result<TileRegion, Error>) -> Void)?

        do {
            let tileStore2 = tileStore
            closure = { _ in
                DispatchQueue.main.async {
                    dump(tileStore2)

                    let observer = DeallocationObserver(closureDeallocation.fulfill)
                    dump(observer)
                    print("\(functionName): Completion block called")

                    expect.fulfill()
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

        wait(for: [expect, closureDeallocation], timeout: 60.0)

        clearResourceOptions()

        // This fails because the completion block is holding the tilestore
        // and is not called, so does not get released afterwards.

        // Since this test is failing, the tilestore needs to be cleaned up
        // manually.
        closure = nil
        XCTAssertNil(weakTileStore)
    }
}
