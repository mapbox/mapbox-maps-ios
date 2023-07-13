import XCTest
@testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private

final class DownloadStatusTests: XCTestCase {
    var httpRequest: HttpRequest!
    var downloadOptions: DownloadOptions!
    var downloadError: TransferError!
    var httpRequestError: HttpRequestError!
    var httpResponseData: HttpResponseData!
    var sdkInformation: SdkInformation!

    override func setUp() {
        super.setUp()
        sdkInformation = SdkInformation(name: "maps-ios-tests", version: "1.0", packageName: "MapboxMaps")
        httpRequest = HttpRequest(url: name, headers: [:], sdkInformation: sdkInformation, body: nil)
        downloadOptions = DownloadOptions(request: httpRequest, localPath: "some/test/path")
        httpRequestError = HttpRequestError(type: .otherError, message: "Some failure")
        httpResponseData = HttpResponseData(headers: [:], code: 200, data: Data())
        downloadError = TransferError(code: .networkError, message: "Some network error")
    }

    func testSuccessfulLongInitializer() {
        let status = DownloadStatus(downloadId: 1,
                                    state: .finished,
                                    error: .none,
                                    totalBytes: 2.NSNumber,
                                    receivedBytes: 3,
                                    transferredBytes: 4,
                                    downloadOptions: downloadOptions,
                                    httpResult: .init(value: httpResponseData))
        XCTAssertEqual(status.downloadId, 1, "The value for downloadId should be 1, got \(status.downloadId)")
        XCTAssertEqual(status.state, TransferState.finished, "The download state should be finished, got \(status.state)")
        XCTAssertNil(status.error, "The error should be nil, got \(status.error.debugDescription)")
        XCTAssertEqual(status.__totalBytes, 2, "The value for __totalBytes should be 2, got \(status.__totalBytes.debugDescription)")
        XCTAssertEqual(status.receivedBytes, 3, "The value for receivedBytes should be 3, got \(status.receivedBytes)")
        XCTAssertEqual(status.transferredBytes, 4, "The value for transferredBytes should be 4, got \(status.transferredBytes)")
        XCTAssertEqual(status.downloadOptions, downloadOptions, "The value for downloadOptions should be \(downloadOptions.debugDescription), got \(status.downloadOptions.debugDescription)")

        if let result = status.__httpResult, result.isValue(), let value = result.value {
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
                                    httpResult: .init(error: httpRequestError))
        XCTAssertEqual(status.downloadId, 1, "The value for downloadId should be 1, got \(status.downloadId)")
        XCTAssertEqual(status.state, TransferState.failed, "The download state should be failed, got \(status.state)")
        XCTAssertEqual(status.error, downloadError, "The error should be \(downloadError.message), got \(status.error.debugDescription)")
        XCTAssertEqual(status.__totalBytes, 2, "The value for __totalBytes should be 2, got \(status.__totalBytes.debugDescription)")
        XCTAssertEqual(status.receivedBytes, 3, "The value for receivedBytes should be 3, got \(status.receivedBytes)")
        XCTAssertEqual(status.transferredBytes, 4, "The value for transferredBytes should be 4, got \(status.transferredBytes)")
        XCTAssertEqual(status.downloadOptions, downloadOptions, "The value for downloadOptions should be \(downloadOptions.debugDescription), got \(status.downloadOptions)")

        if let result = status.__httpResult, result.isError(), let error = result.error {
            XCTAssertEqual(error, httpRequestError, "__httpResult should be \(httpRequestError.debugDescription), got \(error)")
        } else {
            XCTFail("__httpResult should be an error, got \(String(describing: status.__httpResult))")
        }
    }

    func testNilLongInitializer() {
        let status = DownloadStatus(downloadId: 1,
                                    state: .finished,
                                    error: .none,
                                    totalBytes: 2,
                                    receivedBytes: 3,
                                    transferredBytes: 4,
                                    downloadOptions: downloadOptions,
                                    httpResult: nil)
        XCTAssertEqual(status.downloadId, 1, "The value for downloadId should be 1, got \(status.downloadId)")
        XCTAssertEqual(status.state, TransferState.finished, "The download state should be finished, got \(status.state)")
        XCTAssertNil(status.error, "The error should be nil, got \(status.error.debugDescription)")
        XCTAssertEqual(status.__totalBytes, 2, "The value for __totalBytes should be 2, got \(status.__totalBytes.debugDescription)")
        XCTAssertEqual(status.receivedBytes, 3, "The value for receivedBytes should be 3, got \(status.receivedBytes)")
        XCTAssertEqual(status.transferredBytes, 4, "The value for transferredBytes should be 4, got \(status.transferredBytes)")
        XCTAssertEqual(status.downloadOptions, downloadOptions, "The value for downloadOptions should be \(downloadOptions.debugDescription), got \(status.downloadOptions.debugDescription)")
        XCTAssertNil(status.__httpResult, "_httpResult should be nil, got \(status.__httpResult.debugDescription)")
    }

    func testSuccessfulShortInitializer() {
        let status = DownloadStatus(downloadId: 0,
                                    state: .pending,
                                    error: nil,
                                    totalBytes: 1234,
                                    receivedBytes: 0,
                                    transferredBytes: 0,
                                    downloadOptions: downloadOptions,
                                    httpResult: .init(value: httpResponseData))

        XCTAssertNil(status.error, "The error should be nil, got \(status.error.debugDescription)")
        XCTAssertEqual(status.__totalBytes, 1234, "The value for __totalBytes should be 1234, got \(status.__totalBytes.debugDescription)")
        XCTAssertEqual(status.downloadOptions, downloadOptions, "The value for downloadOptions should be \(downloadOptions.debugDescription), got \(status.downloadOptions.debugDescription)")
        if let result = status.__httpResult, result.isValue(), let value = result.value {
            XCTAssertEqual(value, httpResponseData)
        } else {
            XCTFail("This should be a value. Instead got \(status.__httpResult.debugDescription).")
        }
    }

    func testFailedShortInitializer() {
        let status = DownloadStatus(downloadId: 0,
                                    state: .pending,
                                    error: downloadError,
                                    totalBytes: 1234,
                                    receivedBytes: 0,
                                    transferredBytes: 0,
                                    downloadOptions: downloadOptions,
                                    httpResult: .init(error: httpRequestError))

        XCTAssertEqual(status.error, downloadError, "The error should be \(downloadError.message), got \(status.error.debugDescription)")
        XCTAssertEqual(status.__totalBytes, 1234, "The value for __totalBytes should be 1234, got \(status.__totalBytes.debugDescription)")
        XCTAssertEqual(status.downloadOptions, downloadOptions, "The value for downloadOptions should be \(downloadOptions.debugDescription), got \(status.downloadOptions.debugDescription)")
        if let result = status.__httpResult, result.isError(), let error = result.error {
            XCTAssertEqual(error, httpRequestError, "__httpResult should be \(httpRequestError.debugDescription), got \(error)")
        } else {
            XCTFail("__httpResult should be an error, got \(String(describing: status.__httpResult))")
        }
    }

    func testNilShortInitializer() {
        let status = DownloadStatus(downloadId: 0,
                                    state: .pending,
                                    error: nil,
                                    totalBytes: 1234,
                                    receivedBytes: 0,
                                    transferredBytes: 0,
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
                                    totalBytes: 2,
                                    receivedBytes: 3,
                                    transferredBytes: 4,
                                    downloadOptions: downloadOptions,
                                    httpResult: nil)
        XCTAssertNil(status.__httpResult?.result, "httpResult should be nil.")
    }

    func testValueHttpResult() throws {
        let status = DownloadStatus(downloadId: 0,
                                    state: .pending,
                                    error: nil,
                                    totalBytes: nil,
                                    receivedBytes: 0,
                                    transferredBytes: 0,
                                    downloadOptions: downloadOptions,
                                    httpResult: Expected(value: httpResponseData))

        let result = try status.__httpResult?.result.get()
        XCTAssertEqual(result, httpResponseData, "The two HttpResponseData va;ues should be equal.")
    }

    func testErrorHttpResult() throws {
        let status = DownloadStatus(downloadId: 0,
                                    state: .pending,
                                    error: nil,
                                    totalBytes: nil,
                                    receivedBytes: 0,
                                    transferredBytes: 0,
                                    downloadOptions: downloadOptions,
                                    httpResult: Expected(error: httpRequestError))
        let result = status.__httpResult?.result
        guard case .failure(let error) = result else {
            XCTFail("Expected to find an error, instead found \(result.debugDescription).")
            return
        }

        XCTAssertEqual(error, httpRequestError, "The two errors should be equal.")
    }

    func testNilTotalBytes() {
        let status = DownloadStatus(downloadId: 0,
                                    state: .pending,
                                    error: .none,
                                    totalBytes: nil,
                                    receivedBytes: 0,
                                    transferredBytes: 0,
                                    downloadOptions: downloadOptions,
                                    httpResult: .init(value: httpResponseData))

        XCTAssertNil(status.__totalBytes?.uint64Value, "The value for totalBytes should be nil.")
    }

    func testNotNilTotalBytes() {
        let status = DownloadStatus(downloadId: 0,
                                    state: .pending,
                                    error: .none,
                                    totalBytes: 1234,
                                    receivedBytes: 0,
                                    transferredBytes: 0,
                                    downloadOptions: downloadOptions,
                                    httpResult: .init(value: httpResponseData))
        XCTAssertEqual(status.__totalBytes?.uint64Value, 1234, "The value for totalBytes should be 1234, found \(String(describing: status.__totalBytes?.uint64Value)).")
    }
}

fileprivate extension Expected<HttpResponseData, HttpRequestError> {
    var result: Result<ValueType, ErrorType> {
        if isValue(), let value = value {
            return .success(value)
        } else if isError(), let error = error {
            return .failure(error)
        } else {
            fatalError("Found unexpected types.")
        }
    }
}
