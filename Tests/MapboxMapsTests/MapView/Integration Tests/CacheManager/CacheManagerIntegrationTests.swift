import XCTest
@testable import MapboxMaps

class DeallocationObserver {
    var observe: () -> Void
    deinit {
        observe()
    }
    init(_ observe: @escaping () -> Void) {
        self.observe = observe
    }
}

class CacheManagerIntegrationTests: IntegrationTestCase {

    let defaultCacheSize: UInt64 = 1024*1024
    var resourceOptions: ResourceOptions!
    var cm: CacheManager!

    var cacheURL: URL {
        var cacheDirectoryURL = try! FileManager.default.url(for: .applicationSupportDirectory,
                                                             in: .userDomainMask,
                                                             appropriateFor: nil,
                                                             create: true)
        let bundleId = Bundle(for: Self.self).bundleIdentifier!
        cacheDirectoryURL = cacheDirectoryURL.appendingPathComponent(bundleId)
        let normalizedPath = name.fileSystemSafeString()

        cacheDirectoryURL = cacheDirectoryURL.appendingPathComponent(normalizedPath)

        try! FileManager.default.createDirectory(at: cacheDirectoryURL,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)

        print("Created test directory at: \(cacheDirectoryURL)")
        return cacheDirectoryURL.appendingPathComponent("cache.db")
    }

    @discardableResult private func setupCacheManager() -> CacheManager {
        let assetURL = Bundle.main.resourceURL

        resourceOptions = ResourceOptions(__accessToken: accessToken,
                                          baseURL: nil,
                                          cachePath: cacheURL.path,
                                          assetPath: assetURL?.path,
                                          tileStorePath: nil,
                                          loadTilePacksFromNetwork: nil,
                                          cacheSize: defaultCacheSize as NSNumber)

        cm = CacheManager(options: resourceOptions!)
        return cm
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        cm = nil
        resourceOptions = nil
    }

    // MARK: - Tests

    func testInvalidateAmbientCache() throws {
        setupCacheManager()

        let expectation = self.expectation(description: "Invalidate ambient cache")

        // Forces a revalidation of the tiles in the ambient cache and downloads
        // a fresh version of the tiles from the tile server.

        cm.invalidateAmbientCache { expected in
            guard let expected = expected else {
                XCTFail("Should have a valid expected result")
                return
            }

            XCTAssertTrue(expected.isValue())
            XCTAssertNil(expected.value, "Currently the 'success' value is nil")

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testClearAmbientCache() throws {
        setupCacheManager()

        let expectation = self.expectation(description: "Clear ambient cache")

        cm.clearAmbientCache { expected in
            guard let expected = expected else {
                XCTFail("Should have a valid expected result")
                return
            }

            XCTAssertTrue(expected.isValue())
            XCTAssertNil(expected.value, "Currently the 'success' value is nil")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testDefaultAmbientCacheSize() throws {
        setupCacheManager()
        XCTAssertEqual(UInt64(resourceOptions.cacheSize ?? 0), defaultCacheSize, "Maximum cache size should be default")
    }

    func testSetMaximumAmbientCacheSize() throws {
        setupCacheManager()
        let expectation = self.expectation(description: "Set maximum size")

        cm.setMaximumAmbientCacheSizeForSize(1024*1024*2) { [weak cm, weak self] expected in
            guard let self = self else {
                fatalError("Invalid test setup")
            }

            guard let expected = expected else {
                XCTFail("Should have a valid expected result")
                return
            }

            XCTAssertTrue(expected.isValue())
            XCTAssertNil(expected.value, "Currently the 'success' value is nil")

            // Reset back to default
            cm?.setMaximumAmbientCacheSizeForSize(self.defaultCacheSize) { expected in
                guard let expected = expected else {
                    XCTFail("Should have a valid expected result")
                    return
                }

                XCTAssertTrue(expected.isValue())
                XCTAssertNil(expected.value, "Currently the 'success' value is nil")

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10)
    }

    func testCacheManagerIsReleasedAndHandlerCalled() throws {
        weak var cacheManager: CacheManager?

        let expectation = self.expectation(description: "callback is called")

        autoreleasepool {
            cacheManager = setupCacheManager()

            cm.clearAmbientCache { _ in
                expectation.fulfill()
            }

            cm = nil
            resourceOptions = nil
            XCTAssertNil(cacheManager)
        }
        wait(for: [expectation], timeout: 5.0)
    }

// TODO: Re-enable once test is stabilized
//    func testCacheManagerIsReleasedAndHandlerRetainingManagerIsCalled() throws {
//        weak var cacheManager: CacheManager?
//
//        let expectation = self.expectation(description: "callback is called")
//        let closureDeallocation = self.expectation(description: "Closure has been destroyed")
//
//        autoreleasepool {
//            cacheManager = setupCacheManager()
//
//            let observer = DeallocationObserver(closureDeallocation.fulfill)
//
//            // Strong copy
//            let cmcopy = cm
//
//            try! cm.clearAmbientCache { _ in
//                // Retain the cachemanager. Notice this variable is scoped inside the autoreleasepool.
//                print(String(describing: cmcopy))
//                print(String(describing: observer))
//
//                expectation.fulfill()
//            }
//
//            cm = nil
//            resourceOptions = nil
//            XCTAssertNotNil(cacheManager) // Not nil (compared with above), since the closure retains it.
//        }
//
//        XCTAssertNotNil(cacheManager)
//        wait(for: [expectation], timeout: 1.0)
//
//        // Closure was called, but not yet deallocated, since it's retained by C++ and will be
//        // released async from ClosureTask::~ClosureTask, called from mbgl::util::RunLoop::process()
//        wait(for: [closureDeallocation], timeout: 5.0)
//        XCTAssertNil(cacheManager)
//    }

    // TODO add tests for:
    // - preloadDataForUrl
    // - setDatabasePath
    // - prefetchAmbientCache
    // - cancelPrefetchRequest
}
