import XCTest
@testable import MapboxMaps

final class DownloadStatusTests: XCTestCase {

    func testSuccessRoundtrip1() throws {
        let httpRequest = HttpRequest(url: name, headers: [:], uaComponents: UAComponents(), body: nil)
        let downloadOptions = DownloadOptions(request: httpRequest, localPath: "some/test/path")
        let httpResponseData = HttpResponseData(headers: [:], code: 200, data: Data())
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
        let httpRequest = HttpRequest(url: name, headers: [:], uaComponents: UAComponents(), body: nil)
        let downloadOptions = DownloadOptions(request: httpRequest, localPath: "some/test/path")
        let httpResponseData = HttpResponseData(headers: [:], code: 200, data: Data())
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
        let httpRequest = HttpRequest(url: name, headers: [:], uaComponents: UAComponents(), body: nil)
        let downloadOptions = DownloadOptions(request: httpRequest, localPath: "some/test/path")

        let downloadError = DownloadError(code: .networkError, message: "Some network error")
        let httpRequestError = HttpRequestError(type: .otherError, message: "Some failure")
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
        let httpRequest = HttpRequest(url: name, headers: [:], uaComponents: UAComponents(), body: nil)
        let downloadOptions = DownloadOptions(request: httpRequest, localPath: "some/test/path")

        let downloadError = DownloadError(code: .networkError, message: "Some network error")
        let httpRequestError = HttpRequestError(type: .otherError, message: "Some failure")
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
}
