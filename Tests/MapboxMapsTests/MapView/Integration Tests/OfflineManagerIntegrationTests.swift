import XCTest
@testable import MapboxMaps

internal class OfflineManagerIntegrationTestCase: MapViewIntegrationTestCase {

    // MARK: Reusable test properties

    /// Offline manager properties
//    private var mapInitOptions = MapInitOptions()
    private let offlineManager = OfflineManager(resourceOptions: MapInitOptions().resourceOptions)
    private let tileRegionId = "myTileRegion"

    /// Tokyo coordinates
    private let tokyoCoord = CLLocationCoordinate2D(latitude: 35.682027, longitude: 139.769305)
    private lazy var tokyoCoords: [CLLocationCoordinate2D] = {[
        CLLocationCoordinate2D(latitude: tokyoCoord.latitude - 0.1, longitude: tokyoCoord.longitude - 0.1),
        CLLocationCoordinate2D(latitude: tokyoCoord.latitude - 0.1, longitude: tokyoCoord.longitude + 0.1),
        CLLocationCoordinate2D(latitude: tokyoCoord.latitude + 0.1, longitude: tokyoCoord.longitude + 0.1),
        CLLocationCoordinate2D(latitude: tokyoCoord.latitude + 0.1, longitude: tokyoCoord.longitude - 0.1),
        CLLocationCoordinate2D(latitude: tokyoCoord.latitude - 0.1, longitude: tokyoCoord.longitude - 0.1),
    ]}()

    // MARK: Test Cases

    internal func testProgressAndCompletionBlocksBaseCase() {

        /// Expectations to be fulfilled
        let downloadInProgress = XCTestExpectation(description: "Downloading offline tiles in progress")
        let completionBlockReached = XCTestExpectation(description: "Checks that completion block closure has been reached")

        // Create an offline region with tiles using the "outdoors" style
        let stylePackOptions = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                                    metadata: ["tag": "my-outdoors-style-pack"])

        let outdoorsOptions = TilesetDescriptorOptions(styleURI: .outdoors,
                                                       zoomRange: 0...16,
                                                       stylePackOptions: stylePackOptions)

        let outdoorsDescriptor = offlineManager.createTilesetDescriptor(for: outdoorsOptions)

        // Load the tile region
        let tileLoadOptions = TileLoadOptions(criticalPriority: false,
                                              acceptExpired: true,
                                              networkRestriction: .none)

        let tileRegionLoadOptions = TileRegionLoadOptions(geometry: MBXGeometry(line: self.tokyoCoords),
                                                          descriptors: [outdoorsDescriptor],
                                                          metadata: ["tag": "my-outdoors-tile-region"],
                                                          tileLoadOptions: tileLoadOptions,
                                                          averageBytesPerSecond: nil)!

        // Perform the download
        TileStore.getInstance().loadTileRegion(forId: tileRegionId,
                                               loadOptions: tileRegionLoadOptions) { _ in
            downloadInProgress.fulfill()
        } completion: { _ in
            completionBlockReached.fulfill()
        }

        let expectations = [downloadInProgress, completionBlockReached]
        wait(for: expectations, timeout: 5.0)
    }

    internal func testProgressCanBeCancelled() {

        /// Expectations to be fulfilled
        let downloadInProgress = XCTestExpectation(description: "Downloading offline tiles in progress")
        let downloadWasCancelled = XCTestExpectation(description: "Checks a cancel function was reached and that the download was canceled")

        // Create an offline region with tiles using the "outdoors" style
        let stylePackOptions = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                                    metadata: ["tag": "my-outdoors-style-pack"])

        let outdoorsOptions = TilesetDescriptorOptions(styleURI: .outdoors,
                                                       zoomRange: 0...16,
                                                       stylePackOptions: stylePackOptions)

        let outdoorsDescriptor = offlineManager.createTilesetDescriptor(for: outdoorsOptions)

        // Load the tile region
        let tileLoadOptions = TileLoadOptions(criticalPriority: false,
                                              acceptExpired: true,
                                              networkRestriction: .none)

        let tileRegionLoadOptions = TileRegionLoadOptions(geometry: MBXGeometry(line: self.tokyoCoords),
                                                          descriptors: [outdoorsDescriptor],
                                                          metadata: ["tag": "my-outdoors-tile-region"],
                                                          tileLoadOptions: tileLoadOptions,
                                                          averageBytesPerSecond: nil)!

        // Perform the download
        let download = TileStore.getInstance().loadTileRegion(forId: tileRegionId,
                                                              loadOptions: tileRegionLoadOptions) { _ in
            downloadInProgress.fulfill()
        } completion: { _ in }

        /// This guarantees that after 3 seconds of a download in progress, we will force a cancel
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.cancelDownload(download: download, expectation: downloadWasCancelled)
        }

        let expectations = [downloadInProgress, downloadWasCancelled]
        wait(for: expectations, timeout: 5.0)
    }

    internal func testOfflineRegionCanBeDeleted() {

        /// Expectations to be fulfilled
        let downloadWasDeleted = XCTestExpectation(description: "Downloaded offline tiles were deleted")

        // Create an offline region with tiles using the "outdoors" style
        let stylePackOptions = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                                    metadata: ["tag": "my-outdoors-style-pack"])

        let outdoorsOptions = TilesetDescriptorOptions(styleURI: .outdoors,
                                                       zoomRange: 0...16,
                                                       stylePackOptions: stylePackOptions)

        let outdoorsDescriptor = offlineManager.createTilesetDescriptor(for: outdoorsOptions)

        // Load the tile region
        let tileLoadOptions = TileLoadOptions(criticalPriority: false,
                                              acceptExpired: true,
                                              networkRestriction: .none)

        let tileRegionLoadOptions = TileRegionLoadOptions(geometry: MBXGeometry(line: self.tokyoCoords),
                                                          descriptors: [outdoorsDescriptor],
                                                          metadata: ["tag": "my-outdoors-tile-region"],
                                                          tileLoadOptions: tileLoadOptions,
                                                          averageBytesPerSecond: nil)!

        // Perform the download
        TileStore.getInstance().loadTileRegion(forId: tileRegionId,
                                               loadOptions: tileRegionLoadOptions) { _ in } completion: { _ in }

        TileStore.getInstance().removeTileRegion(forId: tileRegionId)

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

        let expectations = [downloadWasDeleted]
        wait(for: expectations, timeout: 5.0)
    }

    internal func testResourceLoadingFromTileStore() {
        // TODO: Test needs to be implemented

    }

    // MARK: Private helper functions
    private func cancelDownload(download: Cancelable, expectation: XCTestExpectation) {
        download.cancel()
        expectation.fulfill()
    }
}
