import XCTest
@testable import MapboxMaps

// swiftlint:disable force_cast type_body_length
internal class OfflineManagerIntegrationTestCase: IntegrationTestCase {

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
        tileStorePathURL = try TileStore.fileURLForDirectory(for: name.fileSystemSafeString())
        tileStore = TileStore.shared(for: tileStorePathURL.path)
        tileStore.setAccessToken(accessToken)
        weakTileStore = tileStore

        resourceOptions = ResourceOptions(accessToken: accessToken,
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

        tileRegionLoadOptions = nil
        resourceOptions = nil
        offlineManager = nil
        tileStore = nil

        // If tests time-out, we need to wait till the tile store operation(s)
        // have been called, otherwise any XCTFail that is called can cross-talk
        // with other running tests

        var iterations = 30
        while (weakTileStore != nil) && (iterations > 0) {
            print("Waiting for TileStore operations to complete...")
            let expect = expectation(description: "Waiting")
            _ = XCTWaiter.wait(for: [expect], timeout: 2.0)

            iterations -= 1
        }

        XCTAssertNil(weakOfflineManager)
        if iterations > 0 {
            XCTAssertNil(weakTileStore)
        } else if weakTileStore != nil {
            print("warning: TileStore not released!")
        }


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
        wait(for: expectations, timeout: 60.0)
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

        wait(for: [tileRegionDownloaded], timeout: 60.0)

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

        wait(for: [downloadWasDeleted], timeout: 10.0)
    }

    internal func testMapCanBeLoadedWithoutNetworkConnectivity() throws {
        weak var weakMapView: MapView?

        try autoreleasepool {
            try guardForMetalDevice()

            guard let rootView = rootViewController?.view else {
                throw XCTSkip("No valid UIWindow or root view controller")
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

            wait(for: [stylePackLoaded, tileRegionLoaded], timeout: 60.0)

            // - - - - - - - -
            // 3. Disable load-from-network, and try launch map at this location

            OfflineSwitch.shared.isMapboxStackConnected = false

            let cameraOptions = CameraOptions(center: tokyoCoord, zoom: 16)
            let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions,
                                                cameraOptions: cameraOptions,
                                                styleURI: .outdoors)
            let mapView = MapView(frame: rootView.bounds, mapInitOptions: mapInitOptions)
            rootView.addSubview(mapView)

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

        XCTAssertNil(weakMapView)
    }

    // Release tests

    func testTileStoreImmediateRelease() {
        let functionName = name

        let expect = expectation(description: "Completion called")
        tileStore.loadTileRegion(forId: tileRegionId,
                                 loadOptions: tileRegionLoadOptions!) { _ in
            print("\(functionName): Completion block called")
            expect.fulfill()
        }

        tileRegionLoadOptions = nil
        resourceOptions = nil
        tileStore = nil
        offlineManager = nil
        XCTAssertNil(weakTileStore)

        XCTExpectFailure("Completion block not called") {
            wait(for: [expect], timeout: 30.0)
        }
    }


    func testTileStoreDelayedRelease() {
        let functionName = name

        let expect = expectation(description: "Completion called")
        tileStore.loadTileRegion(forId: tileRegionId,
                                 loadOptions: tileRegionLoadOptions!) { _ in
            print("\(functionName): Completion block called")
            expect.fulfill()
        }

        tileRegionLoadOptions = nil
        resourceOptions = nil

        // Wait a short time
        let expect2 = expectation(description: "Wait")
        _ = XCTWaiter.wait(for: [expect2], timeout: 0.02)

        // Now release
        tileStore = nil
        offlineManager = nil
        XCTAssertNil(weakTileStore)

        wait(for: [expect], timeout: 30.0)
    }

    func testTileStoreDelayedReleaseWithCapture() {
        let functionName = name

        let expect = expectation(description: "Completion called")
        autoreleasepool {
            let tileStore2 = tileStore
            tileStore.loadTileRegion(forId: tileRegionId,
                                     loadOptions: tileRegionLoadOptions!) { _ in
                print("\(functionName): Completion block called")
                expect.fulfill()
                _ = tileStore2
            }
        }

        tileRegionLoadOptions = nil
        resourceOptions = nil

        // Wait a short time
        let expect2 = expectation(description: "Wait")
        _ = XCTWaiter.wait(for: [expect2], timeout: 0.25)

        // Now release
        tileStore = nil
        offlineManager = nil
        XCTAssertNotNil(weakTileStore)
        XCTAssertNil(weakOfflineManager)

        wait(for: [expect], timeout: 30.0)
        XCTAssertNil(weakTileStore)
    }

    func testTileStoreDelayedReleaseWithCaptureButReleasingOfflineManager() {
        let functionName = name
        let expect = expectation(description: "Completion called")
        do {
            let tileStore2 = tileStore
            tileStore.loadTileRegion(forId: tileRegionId,
                                     loadOptions: tileRegionLoadOptions!) { _ in
                print("\(functionName): Completion block called")
                expect.fulfill()
                _ = tileStore2
            }
        }

        // Release
        tileRegionLoadOptions = nil
        resourceOptions = nil
        tileStore = nil
        XCTAssertNotNil(weakTileStore)

        offlineManager = nil // <--- Completion block is NOT called
        XCTAssertNil(weakOfflineManager)

        // Wait a short time
        let expect2 = expectation(description: "Wait")
        _ = XCTWaiter.wait(for: [expect2], timeout: 0.25)

        XCTExpectFailure("Completion block not called") {
            wait(for: [expect], timeout: 30.0)

            // This fails because the completion block is holding the tilestore
            // and is not called, so does not get released afterwards.
            XCTAssertNil(weakTileStore)
        }
    }
}
