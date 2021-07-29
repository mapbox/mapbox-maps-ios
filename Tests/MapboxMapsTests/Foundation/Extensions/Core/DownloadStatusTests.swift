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

    func testSuccessfulLongInitializer() {
        let status = DownloadStatus(downloadId: 1,
                                    state: .finished,
                                    error: .none,
                                    totalBytes: 2,
                                    receivedBytes: 3,
                                    transferredBytes: 4,
                                    downloadOptions: downloadOptions,
                                    httpResult: .success(httpResponseData))
        XCTAssertEqual(status.downloadId, 1, "The value for downloadId should be 1, got \(status.downloadId)")
        XCTAssertEqual(status.state, DownloadState.finished, "The download state should be finished, got \(status.state)")
        XCTAssertNil(status.error, "The error should be nil, got \(status.error.debugDescription)")
        XCTAssertEqual(status.__totalBytes, 2, "The value for __totalBytes should be 2, got \(status.__totalBytes.debugDescription)")
        XCTAssertEqual(status.receivedBytes, 3, "The value for receivedBytes should be 3, got \(status.receivedBytes)")
        XCTAssertEqual(status.transferredBytes, 4, "The value for transferredBytes should be 4, got \(status.transferredBytes)")
        XCTAssertEqual(status.downloadOptions, downloadOptions, "The value for downloadOptions should be \(downloadOptions.debugDescription), got \(status.downloadOptions.debugDescription)")

        if let result = status.__httpResult, result.isValue(), let value = result.value as? HttpResponseData {
            XCTAssertEqual(value, httpResponseData)
        } else {
            XCTFail("This should be a value. Instead got \(status.__httpResult.debugDescription).")
        }
    }

    func testFailedLongInitializer() {
        let status = DownloadStatus(downloadId: 1,
                                    state: .failed,
                                    error: downloadError,
                                    totalBytes: 2,
                                    receivedBytes: 3,
                                    transferredBytes: 4,
                                    downloadOptions: downloadOptions,
                                    httpResult: .failure(httpRequestError))
        XCTAssertEqual(status.downloadId, 1, "The value for downloadId should be 1, got \(status.downloadId)")
        XCTAssertEqual(status.state, DownloadState.failed, "The download state should be failed, got \(status.state)")
        XCTAssertEqual(status.error, downloadError, "The error should be \(downloadError.localizedDescription), got \(status.error.debugDescription)")
        XCTAssertEqual(status.__totalBytes, 2, "The value for __totalBytes should be 2, got \(status.__totalBytes.debugDescription)")
        XCTAssertEqual(status.receivedBytes, 3, "The value for receivedBytes should be 3, got \(status.receivedBytes)")
        XCTAssertEqual(status.transferredBytes, 4, "The value for transferredBytes should be 4, got \(status.transferredBytes)")
        XCTAssertEqual(status.downloadOptions, downloadOptions, "The value for downloadOptions should be \(downloadOptions.debugDescription), got \(status.downloadOptions)")

        if let result = status.__httpResult, result.isError(), let error = result.error as? HttpRequestError {
            XCTAssertEqual(error, httpRequestError, "__httpResult should be \(httpRequestError.debugDescription), got \(error)")
        } else {
            XCTFail("__httpResult should be an error, got \(String(describing: status.__httpResult))")
        }
    }

    func testNilLongInitializer() {
        let status = DownloadStatus(downloadId: 1,
                                    state: .finished,
                                    error: .none,
                                    totalBytes: UInt64(2), // This tells the compiler which initializer to use
                                    receivedBytes: 3,
                                    transferredBytes: 4,
                                    downloadOptions: downloadOptions,
                                    httpResult: nil)
        XCTAssertEqual(status.downloadId, 1, "The value for downloadId should be 1, got \(status.downloadId)")
        XCTAssertEqual(status.state, DownloadState.finished, "The download state should be finished, got \(status.state)")
        XCTAssertNil(status.error, "The error should be nil, got \(status.error.debugDescription)")
        XCTAssertEqual(status.__totalBytes, 2, "The value for __totalBytes should be 2, got \(status.__totalBytes.debugDescription)")
        XCTAssertEqual(status.receivedBytes, 3, "The value for receivedBytes should be 3, got \(status.receivedBytes)")
        XCTAssertEqual(status.transferredBytes, 4, "The value for transferredBytes should be 4, got \(status.transferredBytes)")
        XCTAssertEqual(status.downloadOptions, downloadOptions, "The value for downloadOptions should be \(downloadOptions.debugDescription), got \(status.downloadOptions.debugDescription)")
        XCTAssertNil(status.__httpResult, "_httpResult should be nil, got \(status.__httpResult.debugDescription)")
    }

    func testSuccessfulShortInitializer() {
        let status = DownloadStatus(error: nil,
                                    totalBytes: 1234,
                                    downloadOptions: downloadOptions,
                                    httpResult: .success(httpResponseData))

        XCTAssertNil(status.error, "The error should be nil, got \(status.error.debugDescription)")
        XCTAssertEqual(status.__totalBytes, 1234, "The value for __totalBytes should be 1234, got \(status.__totalBytes.debugDescription)")
        XCTAssertEqual(status.downloadOptions, downloadOptions, "The value for downloadOptions should be \(downloadOptions.debugDescription), got \(status.downloadOptions.debugDescription)")
        if let result = status.__httpResult, result.isValue(), let value = result.value as? HttpResponseData {
            XCTAssertEqual(value, httpResponseData)
        } else {
            XCTFail("This should be a value. Instead got \(status.__httpResult.debugDescription).")
        }
    }

    func testFailedShortInitializer() {
        let status = DownloadStatus(error: downloadError,
                                    totalBytes: 1234,
                                    downloadOptions: downloadOptions,
                                    httpResult: .failure(httpRequestError))

        XCTAssertEqual(status.error, downloadError, "The error should be \(downloadError.localizedDescription), got \(status.error.debugDescription)")
        XCTAssertEqual(status.__totalBytes, 1234, "The value for __totalBytes should be 1234, got \(status.__totalBytes.debugDescription)")
        XCTAssertEqual(status.downloadOptions, downloadOptions, "The value for downloadOptions should be \(downloadOptions.debugDescription), got \(status.downloadOptions.debugDescription)")
        if let result = status.__httpResult, result.isError(), let error = result.error as? HttpRequestError {
            XCTAssertEqual(error, httpRequestError, "__httpResult should be \(httpRequestError.debugDescription), got \(error)")
        } else {
            XCTFail("__httpResult should be an error, got \(String(describing: status.__httpResult))")
        }
    }

    func testNilShortInitializer() {
        let status = DownloadStatus(error: nil,
                                    totalBytes: UInt64(1234),
                                    downloadOptions: downloadOptions,
                                    httpResult: nil)

        XCTAssertNil(status.error, "The error should be nil, got \(status.error.debugDescription)")
        XCTAssertEqual(status.__totalBytes, 1234, "The value for __totalBytes should be 1234, got \(status.__totalBytes.debugDescription)")
        XCTAssertEqual(status.downloadOptions, downloadOptions, "The value for downloadOptions should be \(downloadOptions.debugDescription), got \(status.downloadOptions.debugDescription)")
        XCTAssertNil(status.__httpResult, "_httpResult should be nil, got \(status.__httpResult.debugDescription)")
    }

    func testNilHttpResult() {
        let status = DownloadStatus(downloadId: 1,
                                    state: .finished,
                                    error: .none,
                                    totalBytes: NSNumber(value: 2), // forces using the unrefined initializer
                                    receivedBytes: 3,
                                    transferredBytes: 4,
                                    downloadOptions: downloadOptions,
                                    httpResult: nil)
        XCTAssertNil(status.httpResult, "httpResult should be nil.")
    }

    func testValueHttpResult() throws {
        let status = DownloadStatus(error: nil,
                                    totalBytes: nil,
                                    downloadOptions: downloadOptions,
                                    httpResult: Expected(value: httpResponseData))

        let result = try status.httpResult?.get()
        XCTAssertEqual(result, httpResponseData, "The two HttpResponseData va;ues should be equal.")
    }

    func testErrorHttpResult() throws {
        let status = DownloadStatus(error: nil,
                                    totalBytes: nil,
                                    downloadOptions: downloadOptions,
                                    httpResult: Expected(error: httpRequestError))
        let result = status.httpResult
        guard case .failure(let error) = result else {
            XCTFail("Expected to find an error, instead found \(result.debugDescription).")
            return
        }

        XCTAssertEqual(error, httpRequestError, "The two errors should be equal.")
    }

    func testNilTotalBytes() {
        let status = DownloadStatus(error: .none,
                                    totalBytes: nil,
                                    downloadOptions: downloadOptions,
                                    httpResult: Expected(value: httpResponseData))

        XCTAssertNil(status.totalBytes, "The value for totalBytes should be nil.")
    }

    func testNotNilTotalBytes() {
        let status = DownloadStatus(error: .none,
                                    totalBytes: 1234,
                                    downloadOptions: downloadOptions,
                                    httpResult: Expected(value: httpResponseData))
        XCTAssertEqual(status.totalBytes, 1234, "The value for totalBytes should be 1234, found \(status.totalBytes.debugDescription).")
    }
}
