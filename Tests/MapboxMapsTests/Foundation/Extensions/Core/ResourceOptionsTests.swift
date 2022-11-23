import XCTest
@testable import MapboxMaps

class ResourceOptionsTests: XCTestCase {

    func testEquality() {
        let a = ResourceOptions(accessToken: "a")
        let b = ResourceOptions(accessToken: "a")
        let c = ResourceOptions(accessToken: "c")

        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func testHashValue() {
        let a = ResourceOptions(accessToken: "a")
        let c = ResourceOptions(accessToken: "c")

        XCTAssertNotEqual(a.hashValue, 0)
        XCTAssertNotEqual(c.hashValue, 0)
        XCTAssertNotEqual(a.hashValue, c.hashValue)

        XCTAssertEqual(a.hashValue, a.hashValue)
    }

    func testAccessTokenIsObfuscated() {
        let a = ResourceOptions(accessToken: "pk.HelloWorld")
        XCTAssertEqual(a.description, "ResourceOptions: pk.H◻︎◻︎◻︎◻︎◻︎◻︎◻︎◻︎◻︎")
    }

    func testBaseUrlConversionToCore() {
        let expectedBaseUrl = URL(string: "https://api.mapbox.com")!
        let sdkOptions = ResourceOptions(accessToken: "pk.HelloWorld", baseURL: expectedBaseUrl)
        let coreOptions = MapboxCoreMaps.ResourceOptions(sdkOptions)

        XCTAssertEqual(coreOptions.baseURL, expectedBaseUrl.absoluteString)
    }

    func testBaseUrlConversionFromCore() {
        let expectedBaseUrl = URL(string: "https://api.mapbox.com")!
        let coreOptions = MapboxCoreMaps.ResourceOptions(
            accessToken: "pk.HelloWorld",
            baseURL: expectedBaseUrl.absoluteString,
            dataPath: nil,
            assetPath: nil,
            tileStore: nil
        )
        let sdkOptions = ResourceOptions(coreOptions)

        XCTAssertEqual(sdkOptions.baseURL, expectedBaseUrl)
    }

    func testNilBaseUrlConversionFromCore() {
        let coreOptions = MapboxCoreMaps.ResourceOptions(
            accessToken: "pk.HelloWorld",
            baseURL: nil,
            dataPath: nil,
            assetPath: nil,
            tileStore: nil
        )
        let sdkOptions = ResourceOptions(coreOptions)

        XCTAssertNil(sdkOptions.baseURL)
    }
}
