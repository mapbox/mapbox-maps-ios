import XCTest

extension XCTestCase {

    func guardForMetalDevice() throws {
        guard MTLCreateSystemDefaultDevice() != nil else {
            throw XCTSkip("No valid Metal device (OS version or VM?)")
        }
    }

    func mapboxAccessToken() throws -> String {
        func token() throws -> String {
            // User defaults can override plist
            if let token = UserDefaults.standard.string(forKey: "MBXAccessToken") {
                print("Found access token from UserDefaults (command line parameter?)")
                return token
            } else if let token = Bundle.mapboxMapsTests.infoDictionary?["MBXAccessToken"] as? String {
                print("Found access token in Info.plist")
                return token
            } else if let url = Bundle.mapboxMapsTests.url(forResource: "MapboxAccessToken", withExtension: nil),
                      let token = try? String(contentsOf: url) {
                print("Found access token in MapboxAccessToken")
                return token
            } else {
                throw XCTSkip("Mapbox access token not found")
            }
        }

        func validated(token: String) throws -> String {
            if token.starts(with: "pk.") {
                // ok
            } else if token.isEmpty {
                print("⚠️ token is empty.")
            } else {
                throw XCTSkip("Mapbox access token is invalid")
            }
            return token
        }

        return try validated(token: token()).trimmingCharacters(in: .whitespacesAndNewlines)
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
