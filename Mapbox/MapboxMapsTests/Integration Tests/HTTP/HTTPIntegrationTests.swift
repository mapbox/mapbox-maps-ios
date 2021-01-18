import XCTest
import MapboxMaps

class HTTPIntegrationTestHTTPService: HttpServiceInterface {

    /// Set this to an error that `request(for:callback:)` should pass to its callback
    var error: HttpRequestError?

    /// An expectation that will be fulfilled when the request function is called
    var requestExpectation: XCTestExpectation?

    // MARK: - HttpServiceInterface protocol conformance

    func setMaxRequestsPerHostForMax(_ max: UInt8) {
        print("setMaxRequestsPerHostForMax conformance")
    }

    func request(for request: HttpRequest, callback: @escaping HttpResponseCallback) -> UInt64 {
        let expected: MBXExpected<HttpResponseData, HttpRequestError>
        if let error = error {
            expected = MBXExpected(error: error)
        } else {
            XCTFail("Not yet implemented")
            expected = MBXExpected(value: HttpResponseData())
        }

        let response = HttpResponse(request: request, result: expected as! MBXExpected<AnyObject, AnyObject>)

        callback(response)

        if let expectation = requestExpectation {
            expectation.fulfill()
        }
        return 0
    }

    func cancelRequest(forId id: UInt64, callback: @escaping ResultCallback) {
        print("cancelRequest(forId:callback:) conformance")
    }

    func supportsKeepCompression() -> Bool {
        print("supportsKeepCompression conformance")
        return true
    }

    func download(for options: DownloadOptions, callback: @escaping DownloadStatusCallback) -> UInt64 {
        print("download(for:callback:) conformance")
        return 0
    }

    var peer: MBXPeerWrapper?
}

class HTTPIntegrationTests: MapViewIntegrationTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()

        let resourceOptions = try! mapView!.__map.getResourceOptions()
        let cm = try! CacheManager(options: resourceOptions)
        try! cm.clearAmbientCache { _ in
        }
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        // Reset to default
        try! HttpServiceFactory.setUserDefinedForCustom(MBXHTTPService.default())
    }

    func disabledTestReplacingHTTPService() throws {

        let mockHttpService = HTTPIntegrationTestHTTPService()
        try! HttpServiceFactory.setUserDefinedForCustom(mockHttpService)

        let serviceExpectation = XCTestExpectation(description: "Mock service request should be called")
        let errorExpectation = XCTestExpectation(description: "Map should fail to load, with our custom error")

        let errorMessage = "mock HTTP service request error"
        let error = HttpRequestError(type: .otherError, message: errorMessage)
        mockHttpService.error = error
        mockHttpService.requestExpectation = serviceExpectation

        style!.styleURL = .streets

        didFailLoadingMap = { (_, error2) in
            XCTAssertNotNil(error2)
            let description = error2.userInfo["description"] as? String
            XCTAssertNotNil(description)
            XCTAssert(description!.contains(errorMessage))

            errorExpectation.fulfill()
        }

        wait(for: [errorExpectation, serviceExpectation], timeout: 5.0)
    }
}
