import XCTest
import MapboxMaps

extension XCTestCase {
    func guardForMetalDevice() throws {
        guard MTLCreateSystemDefaultDevice() != nil else {
            throw XCTSkip("No valid Metal device (OS version or VM?)")
        }
    }

    func mapboxAccessToken() throws -> AccessToken {
        return .default(.mapboxMapsTests)
    }

    func clearDefaultAmbientCache() throws {
        let token = try mapboxAccessToken()
        let resourceOptions = ResourceOptions(accessToken: token)
        let cacheManager = CacheManager(options: resourceOptions)

        let expectation = self.expectation(description: "Clear ambient cache")
        cacheManager.clearAmbientCache { result in
            switch result {
            case let .failure(error):
                XCTFail("Should have a valid expected result: \(error)")
            case .success:
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
