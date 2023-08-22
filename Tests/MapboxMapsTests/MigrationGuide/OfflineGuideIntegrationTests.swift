import Foundation
@testable import MapboxMaps
import XCTest

// These tests are used for documentation purposes
// Code between //--> and //<-- is used in the offline guide. Please do not modify
// without consultation.

class OfflineGuideIntegrationTests: XCTestCase {
    let tokyoCoord = CLLocationCoordinate2D(latitude: 35.682027, longitude: 139.769305)

    var tileStorePathURL: URL!
    var tileStore: TileStore!

    override func setUpWithError() throws {
        try super.setUpWithError()

        tileStorePathURL = try temporaryCacheDirectory()
        tileStore = TileStore.shared(for: tileStorePathURL)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        tileStore = nil
    }

    // Test StylePackLoadOptions
    func testDefineAStylePackage() throws {
        //-->
        let options = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                           metadata: ["my-key": "my-value"],
                                           acceptExpired: false)
        //<--

        XCTAssertNotNil(options, "Invalid configuration. Metadata?")
    }

    // Test TileRegionLoadOptions
    func testDefineATileRegion() throws {
        //-->

        MapboxMapsOptions.dataPath = tileStorePathURL
        MapboxMapsOptions.tileStore = tileStore
        let offlineManager = OfflineManager()

        // 1. Create the tile set descriptor
        let options = TilesetDescriptorOptions(styleURI: .outdoors, zoomRange: 0...16, tilesets: nil)
        let tilesetDescriptor = offlineManager.createTilesetDescriptor(for: options)

        // 2. Create the TileRegionLoadOptions
        let tileRegionLoadOptions = TileRegionLoadOptions(
            geometry: .point(Point(self.tokyoCoord)),
            descriptors: [tilesetDescriptor],
            acceptExpired: true)

        //<--

        XCTAssertNotNil(tileRegionLoadOptions, "Invalid configuration. Metadata?")
    }

    func testStylePackMetadata() throws {
        //-->
        let metadata = ["my-key": "my-style-pack-value"]
        let options = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                           metadata: metadata)
        //<--

        XCTAssertNotNil(options, "Invalid configuration. Metadata?")
    }

    func testStylePackBadMetadata() throws {
        let options = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                           metadata: "Currently restricted to JSON dictionaries and arrays")
        XCTAssertNil(options)
    }

    func testTileRegionMetadata() throws {
        //-->
        let metadata = [
            "name": "my-region",
            "my-other-key": "my-other-tile-region-value"]
        let tileRegionLoadOptions = TileRegionLoadOptions(
            geometry: .point(Point(self.tokyoCoord)),
            descriptors: [],
            metadata: metadata,
            acceptExpired: true)
        //<--

        XCTAssertNotNil(tileRegionLoadOptions, "Invalid configuration. Metadata?")
    }

    func testLoadAndCancelStylePack() throws {

        let expectation = self.expectation(description: "style pack should be canceled")

        MapboxMapsOptions.dataPath = tileStorePathURL
        MapboxMapsOptions.tileStore = tileStore
        let offlineManager = OfflineManager()
        let stylePackLoadOptions = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally)!

        let handleCancelation = {
            expectation.fulfill()
        }

        let handleFailure = { (error: Error) in
            XCTFail("Download failed with \(error)")
        }

        //-->
        // These closures do not get called from the main thread. Depending on
        // the use case, you may need to use `DispatchQueue.main.async`, for
        // example to update your UI.
        let stylePackCancelable = offlineManager.loadStylePack(for: .outdoors,
                                                               loadOptions: stylePackLoadOptions) { _ in
            //
            // Handle progress here
            //
        } completion: { result in
            //
            // Handle StylePack result
            //
            switch result {
            case let .success(stylePack):
                // Style pack download finishes successfully
                print("Process \(stylePack)")

            case let .failure(error):
                // Handle error occurred during the style pack download
                if case StylePackError.canceled = error {
                    handleCancelation()
                } else {
                    handleFailure(error)
                }
            }
        }

        // Cancel the download if needed
        stylePackCancelable.cancel()
        //<--

        wait(for: [expectation], timeout: 5.0)
    }

    func testLoadAndCancelTileRegion() throws {
        let expectation = self.expectation(description: "Tile region download should be canceled")

        MapboxMapsOptions.dataPath = tileStorePathURL
        MapboxMapsOptions.tileStore = tileStore
        let offlineManager = OfflineManager()

        // Create the tile set descriptor
        let options = TilesetDescriptorOptions(styleURI: .outdoors, zoomRange: 0...16, tilesets: nil)
        let tilesetDescriptor = offlineManager.createTilesetDescriptor(for: options)

        let handleCancelation = {
            expectation.fulfill()
        }

        let handleFailure = { (error: Error) in
            XCTFail("Download failed with \(error)")
        }

        //-->
        let tileRegionId = "my-tile-region-id"

        // Load the tile region
        let tileRegionLoadOptions = TileRegionLoadOptions(
            geometry: .point(Point(self.tokyoCoord)),
            descriptors: [tilesetDescriptor],
            acceptExpired: true)!

        let tileRegionCancelable = tileStore.loadTileRegion(
            forId: tileRegionId,
            loadOptions: tileRegionLoadOptions) { _ in
            //
            // Handle progress here
            //
        } completion: { result in
            //
            // Handle TileRegion result
            //
            switch result {
            case let .success(tileRegion):
                // Tile region download finishes successfully
                print("Process \(tileRegion)")
            case let .failure(error):
                // Handle error occurred during the tile region download
                if case TileRegionError.canceled = error {
                    handleCancelation()
                } else {
                    handleFailure(error)
                }
            }
        }

        // Cancel the download if needed
        tileRegionCancelable.cancel()
        //<--

        wait(for: [expectation], timeout: 5.0)
    }

    func testFetchingAllStylePacks() throws {
        let expectation = self.expectation(description: "Style packs should be fetched without error")

        MapboxMapsOptions.dataPath = tileStorePathURL
        MapboxMapsOptions.tileStore = tileStore
        let offlineManager = OfflineManager()

        let handleStylePacks = { (stylePacks: [StylePack]) in
            // During testing there should be no style packs
            XCTAssert(stylePacks.isEmpty)
            expectation.fulfill()
        }

        let handleStylePackError = { (error: Error) in
            XCTFail("Download failed with \(error)")
        }

        let handleFailure = {
            XCTFail("API Failure")
        }

        //-->
        // Get a list of style packs that are currently available.
        offlineManager.allStylePacks { result in
            switch result {
            case let .success(stylePacks):
                handleStylePacks(stylePacks)

            case let .failure(error) where error is StylePackError:
                handleStylePackError(error)

            case .failure:
                handleFailure()
            }
        }
        //<--

        wait(for: [expectation], timeout: 5.0)
    }

    func testFetchingAllTileRegions() throws {
        let expectation = self.expectation(description: "Style packs should be fetched without error")

        let handleTileRegions = { (tileRegions: [TileRegion]) in
            // During testing there should be no tile regions
            for region in tileRegions {
                print("region = \(region.id)")
            }
            XCTAssert(tileRegions.isEmpty)
            expectation.fulfill()
        }

        let handleTileRegionError = { (error: Error) in
            XCTFail("Download failed with \(error)")
        }

        let handleFailure = {
            XCTFail("API Failure")
        }

        //-->
        // Get a list of tile regions that are currently available.
        // TileStore.getInstance()
        tileStore.allTileRegions { result in
            switch result {
            case let .success(tileRegions):
                handleTileRegions(tileRegions)

            case let .failure(error) where error is TileRegionError:
                handleTileRegionError(error)

            case .failure:
                handleFailure()
            }
        }
        //<--

        wait(for: [expectation], timeout: 5.0)
    }

    func testDeleteStylePack() throws {
        MapboxMapsOptions.dataPath = tileStorePathURL
        MapboxMapsOptions.tileStore = tileStore
        let offlineManager = OfflineManager()

        //-->
        offlineManager.removeStylePack(for: .outdoors)
        //<--
    }

    func testDeleteTileRegions() throws {
        //-->
        //TileStore.getInstance().removeTileRegion(forId: "my-tile-region-id")
        tileStore.removeTileRegion(forId: "my-tile-region-id")
        //<--

        // Note this will not remove the downloaded tile packs, instead, it will
        // just mark the tileset as not being a part of a tile region. The tiles
        // will still exist in the TileStore.
        //
        // You can fully remove tiles that have been downloaded by setting the
        // disk quota to zero. This will ensure tile regions are fully evicted.

        //-->
        tileStore.setOptionForKey(TileStoreOptions.diskQuota, value: 0)
        //<--

        // Wait *some time* before the test calls exit()
        let expectation = self.expectation(description: "Wait...")
        _ = XCTWaiter.wait(for: [expectation], timeout: 5.0)
    }
}
