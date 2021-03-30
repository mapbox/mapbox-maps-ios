import XCTest
import MapboxMaps

class CustomHttpService: HttpServiceInterface {

    // MARK: - HttpServiceInterface protocol conformance
    var forcedError: HttpRequestError?

    /// An expectation that will be fulfilled when the request function is called
    var requestCompletion: (() -> Void)?

    // MARK: - HttpServiceInterface conformance

    func setMaxRequestsPerHostForMax(_ max: UInt8) {
        print("TODO: setMaxRequestsPerHostForMax conformance")
    }

    func request(for request: HttpRequest, callback: @escaping HttpResponseCallback) -> UInt64 {

        // If the test sets an error, call the callback with immediately
        if let error = forcedError {
            let expected = MBXExpected<AnyObject, AnyObject>(error: error)
            let response = HttpResponse(request: request, result: expected)
            callback(response)
            requestCompletion?()
            return 0
        }

        // Make an API request
        var urlRequest = URLRequest(url: URL(string: request.url)!)

        let methodMap: [HttpMethod: String] = [
            .get: "GET",
            .head: "HEAD",
            .post: "POST"
        ]

        urlRequest.httpMethod = methodMap[request.method]!
        urlRequest.httpBody = request.body
        urlRequest.allHTTPHeaderFields = request.headers

        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in

            // `HttpResponse` takes an `MBXExpected` type. This is very similar to Swift's
            // `Result` type.
            // APIs using `MBXExpected` are prone to future changes.
            let expected: MBXExpected<AnyObject, AnyObject>

            if let error = error {
                // Map NSURLError to HttpRequestErrorType
                let requestError = HttpRequestError(type: .otherError, message: error.localizedDescription)
                expected = MBXExpected(error: requestError)
            } else if let response = response as? HTTPURLResponse,
                    let data = data {

                // Keys are expected to be lowercase
                var headers: [String: String] = [:]
                for (key, value) in response.allHeaderFields {
                    guard let key = key as? String,
                          let value = value as? String else {
                        continue
                    }

                    headers[key.lowercased()] = value
                }

                let responseData = HttpResponseData(headers: headers, code: Int64(response.statusCode), data: data)
                expected = MBXExpected(value: responseData)
            } else {
                // error
                let requestError = HttpRequestError(type: .otherError, message: "Invalid response")
                expected = MBXExpected(error: requestError)
            }

            let response = HttpResponse(request: request, result: expected)
            callback(response)
            self.requestCompletion?()
        }

        task.resume()

        // Handle used to cancel requests
        return UInt64(task.taskIdentifier)
    }

    func cancelRequest(forId id: UInt64, callback: @escaping ResultCallback) {
        print("TODO: cancelRequest(forId:callback:) conformance")
    }

    func supportsKeepCompression() -> Bool {
        return false
    }

    func download(for options: DownloadOptions, callback: @escaping DownloadStatusCallback) -> UInt64 {
        print("TODO: download(for:callback:) conformance")
        return 0
    }

    var peer: MBXPeerWrapper?
}

class HTTPIntegrationTests: MapViewIntegrationTestCase {

    static let customHTTPService = CustomHttpService()

    override class func setUp() {
        super.setUp()

        try! HttpServiceFactory.setUserDefinedForCustom(customHTTPService)
    }

    func testReplacingHTTPService() throws {
        guard let style = style else {
            XCTFail("Style should be valid")
            return
        }

        let serviceExpectation = XCTestExpectation(description: "Requests should be made by custom HTTP stack")
        serviceExpectation.assertForOverFulfill = false

        Self.customHTTPService.requestCompletion = {
            XCTAssertNotNil(Self.customHTTPService.forcedError)
            serviceExpectation.fulfill()
        }

        style.styleURI = .streets

        wait(for: [serviceExpectation], timeout: 5.0)
    }

    func testReplacingHTTPServiceAndForcedError() throws {
        guard let style = style else {
            XCTFail("Style should be valid")
            return
        }

        let serviceExpectation = XCTestExpectation(description: "Mock service request should be called")
        let errorExpectation = XCTestExpectation(description: "Map should fail to load, with our custom error")

        let errorMessage = "mock HTTP service request error"
        let error = HttpRequestError(type: .otherError, message: errorMessage)
        Self.customHTTPService.forcedError = error
        Self.customHTTPService.requestCompletion = {
            serviceExpectation.fulfill()
        }

        style.styleURI = .streets

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
