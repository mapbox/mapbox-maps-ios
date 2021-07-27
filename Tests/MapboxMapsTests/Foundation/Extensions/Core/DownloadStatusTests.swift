import XCTest
@testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private

final class DownloadStatusTests: XCTestCase {
    var httpRequest: HttpRequest!
    var downloadOptions: DownloadOptions!
    var downloadError: DownloadError!
    var httpRequestError: HttpRequestError!
    var httpResponseData: HttpResponseData!

    override func setUp() {
        super.setUp()
        httpRequest = HttpRequest(url: name, headers: [:], uaComponents: UAComponents(), body: nil)
        downloadOptions = DownloadOptions(request: httpRequest, localPath: "some/test/path")
        httpRequestError = HttpRequestError(type: .otherError, message: "Some failure")
        httpResponseData = HttpResponseData(headers: [:], code: 200, data: Data())
        downloadError = DownloadError(code: .networkError, message: "Some network error")
    }

    func testSuccessRoundtrip1() throws {
        let downloadStatus = DownloadStatus(error: nil,
                                            totalBytes: 1234,
                                            downloadOptions: downloadOptions,
                                            httpResult: .success(httpResponseData))

        XCTAssertEqual(downloadStatus.totalBytes, 1234)
        let result = try XCTUnwrap(downloadStatus.httpResult)
        let responseData = try result.get()
        XCTAssertEqual(httpResponseData, responseData)
        XCTAssertEqual(downloadStatus.downloadOptions.request.url, name)
    }

    func testSuccessRoundtrip2() throws {
        let downloadStatus = DownloadStatus(downloadId: 1,
                                            state: .finished,
                                            error: nil,
                                            totalBytes: 2345,
                                            receivedBytes: 0,
                                            transferredBytes: 0,
                                            downloadOptions: downloadOptions,
                                            httpResult: .success(httpResponseData))

        XCTAssertEqual(downloadStatus.totalBytes, 2345)
        let result = try XCTUnwrap(downloadStatus.httpResult)
        let responseData = try result.get()
        XCTAssertEqual(httpResponseData, responseData)
        XCTAssertEqual(downloadStatus.downloadOptions.request.url, name)
    }

    func testFailureRoundtrip1() throws {
        let downloadError = DownloadError(code: .networkError, message: "Some network error")

        let downloadStatus = DownloadStatus(error: downloadError,
                                            totalBytes: 1234,
                                            downloadOptions: downloadOptions,
                                            httpResult: .failure(httpRequestError))

        let result = try XCTUnwrap(downloadStatus.httpResult)

        guard case .failure(let error) = result else {
            XCTFail("Not a failure")
            return
        }

        XCTAssertEqual(error, httpRequestError)
        XCTAssertEqual(downloadStatus.downloadOptions.request.url, name)
    }

    func testFailureRoundtrip2() throws {
        let downloadStatus = DownloadStatus(downloadId: 1,
                                            state: .finished,
                                            error: downloadError,
                                            totalBytes: 2345,
                                            receivedBytes: 0,
                                            transferredBytes: 0,
                                            downloadOptions: downloadOptions,
                                            httpResult: .failure(httpRequestError))

        let result = try XCTUnwrap(downloadStatus.httpResult)

        guard case .failure(let error) = result else {
            XCTFail("Not a failure")
            return
        }

        XCTAssertEqual(error, httpRequestError)
        XCTAssertEqual(downloadStatus.downloadOptions.request.url, name)
    }

    func testHttpResultSuccess() throws {
        let status = DownloadStatus(error: .none,
                                    totalBytes: nil,
                                    downloadOptions: downloadOptions,
                                    httpResult: .success(httpResponseData))
        let result = status.__httpResult as! Expected<HttpResponseData, HttpRequestError>

        if result.isValue() {
            let response = result.value
            XCTAssertEqual(response, httpResponseData, "The value for __httpResult should equal the data passed into the DownloadStatus initializer.")
        } else {
            XCTFail("__httpResult should not be an error.")
        }
    }

    func testHttpResultFailure() throws {
        let status = DownloadStatus(error: downloadError,
                                    totalBytes: nil,
                                    downloadOptions: downloadOptions,
                                    httpResult: .failure(httpRequestError))
        let result = try XCTUnwrap(status.__httpResult as? Expected<HttpResponseData, HttpRequestError>)
        if result.isError() {
            XCTAssertEqual(result.error, httpRequestError, "The result error should equal the initial value")
        } else {
            XCTFail("The result was not a failure.")
        }
    }

    func testConvenienceInitializerSuccess() throws {
        let status = DownloadStatus(downloadId: 1,
                                            state: .finished, error: .none, totalBytes: 1234,
                                            receivedBytes: 1234, transferredBytes: 1234,
                                            downloadOptions: downloadOptions,
                                            httpResult: .success(httpResponseData))

        let httpResult = status.__httpResult as! Expected<HttpResponseData, HttpRequestError>

        if httpResult.isValue() {
            XCTAssertEqual(httpResult.value, httpResponseData, "The httpResult should be equal to the input data value.")
        } else {
            XCTFail("httpResult should be a value.")
        }
    }

    func testConvenienceInitFailure() throws{
        let status = DownloadStatus(downloadId: 1,
                                            state: .finished, error: downloadError, totalBytes: 1234,
                                            receivedBytes: 1234, transferredBytes: 1234,
                                            downloadOptions: downloadOptions,
                                            httpResult: .failure(httpRequestError))

        let httpResult = status.__httpResult as! Expected<HttpResponseData, HttpRequestError>
        let error = try XCTUnwrap(status.error, "Expected a download error")
        if httpResult.isError() {
            XCTAssertEqual(httpResult.value, httpRequestError, "The")
            XCTAssertEqual(error, downloadError, "The error for the DownloadStatus should equal the initial download error.")
        } else {
            XCTFail("The __httpResult should be an error.")
        }
    }

    func testNilHttpResult() {
        let status = DownloadStatus(downloadId: 1,
                                    state: .finished, error: .none, totalBytes: 1234,
                                            receivedBytes: 1234, transferredBytes: 1234,
                                            downloadOptions: downloadOptions,
                                            httpResult: .success(httpResponseData))
        status.__httpResult = nil
        XCTAssertNil(status.__httpResult)
        XCTAssertNil(status.httpResult)
    }

    func testValueHttpResult() throws {
        let httpResult = Expected<HttpResponseData, AnyObject>(value: httpResponseData)
        XCTAssertEqual(httpResult.value, httpResponseData)
        XCTAssertNil(httpResult.error, "The error should be nil.")

        let httpResultWrapped: Result<HttpResponseData, Error> = .success(httpResult.value)
        let result = try XCTUnwrap(httpResultWrapped.get())
        XCTAssertEqual(result, httpResponseData, "The two HttpResponseData va;ues should be equal.")
    }

    func testErrorHttpResult() throws {
        let httpResult = Expected<AnyObject, HttpRequestError>(error: httpRequestError)
        XCTAssertEqual(httpResult.error, httpRequestError)
        XCTAssertNil(httpResult.value, "The value should be nil.")

        let httpErrorWrapped: Result<HttpResponseData, HttpRequestError> = .failure(httpRequestError)
        guard case .failure(let error) = httpErrorWrapped else {
            XCTFail("Not a failure")
            return
        }

        XCTAssertEqual(error, httpRequestError, "The two errors should be equal.")
    }

    func testNilTotalBytes() {
        let status = DownloadStatus(error: .none,
                                    totalBytes: nil,
                                    downloadOptions: downloadOptions,
                                    httpResult: .success(httpResponseData))
        XCTAssertEqual(status.totalBytes, status.__totalBytes?.uint64Value, "The value for totalBytes should equal the UInt64 value for __totalBytes.")
        XCTAssertNil(status.totalBytes, "The value for totalBytes should be nil.")
    }

    func testNotNilTotalBytes() {
        let status = DownloadStatus(error: .none,
                                    totalBytes: 1234,
                                    downloadOptions: downloadOptions,
                                    httpResult: .success(httpResponseData))

        XCTAssertEqual(status.totalBytes, status.__totalBytes?.uint64Value, "The value for totalBytes should equal the UInt64 value for __totalBytes.")
        XCTAssertNotNil(status.totalBytes, "The value for totalBytes should not be nil.")
    }
}
