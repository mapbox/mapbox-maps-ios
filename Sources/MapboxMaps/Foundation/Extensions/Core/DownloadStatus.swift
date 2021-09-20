@_exported import MapboxCommon
@_implementationOnly import MapboxCommon_Private

extension DownloadError: LocalizedError {
    /// Standardized error message
    public var errorDescription: String? {
        return "\(code): \(message)"
    }
}

extension DownloadStatus {

    /// Initialize a `DownloadStatus`
    ///
    /// - Parameters:
    ///   - downloadId: Download id which was created by download request.
    ///   - state: State of download request.
    ///   - error: Contains error information in case of failure when state is
    ///         set to `DownloadState.failed`.
    ///   - totalBytes: Total amount of bytes to receive. In some cases this
    ///         value is unknown until we get final part of the file.
    ///   - receivedBytes: Amount of bytes already received and saved on the disk.
    ///         Includes previous download attempts for a resumed download.
    ///   - transferredBytes: Amount of bytes received during the current resume
    ///         attempt. For downloads that weren't resumed, this value will be
    ///         the same as receivedBytes.
    ///   - downloadOptions: Download options used to send the download request.
    ///   - httpResult: An optional HTTP result. This field is only set for `DownloadState.failed`
    ///         and `DownloadState.finished`.
    ///         For `.failed` expect `HttpRequestError` to be provided for cases when
    ///         `DownloadErrorCode` is `NetworkError`. For `.finished` `HttpResponseData`
    ///         is set, but with empty data field (since all the data was written
    ///         to the disk).
    public convenience init(downloadId: UInt64,
                            state: DownloadState,
                            error: DownloadError?,
                            totalBytes: UInt64?,
                            receivedBytes: UInt64,
                            transferredBytes: UInt64,
                            downloadOptions: DownloadOptions,
                            httpResult: Result<HttpResponseData, HttpRequestError>?) {

        let expected: Expected<AnyObject, AnyObject>?
        switch httpResult {
        case let .success(response):
            expected = Expected(value: response)
        case let .failure(error):
            expected = Expected(error: error)
        case .none:
            expected = nil
        }

        self.init(__downloadId: downloadId,
                  state: state,
                  error: error,
                  totalBytes: totalBytes?.NSNumber,
                  receivedBytes: receivedBytes,
                  transferredBytes: transferredBytes,
                  downloadOptions: downloadOptions,
                  httpResult: expected)
    }

    /// Convenience to initialize a `DownloadStatus` when the download state is `.pending`
    ///
    /// - Parameters:
    ///   - error: Contains error information in case of failure when state is
    ///         set to `DownloadState.failed`.
    ///   - totalBytes: Total amount of bytes to receive. In some cases this
    ///         value is unknown until we get final part of the file.
    ///   - downloadOptions: Download options used to send the download request.
    ///   - httpResult: An optional HTTP result. This field is only set for `DownloadState.failed`
    ///         and `DownloadState.finished`.
    ///         For `.failed` expect `HttpRequestError` to be provided for cases when
    ///         `DownloadErrorCode` is `NetworkError`. For `.finished` `HttpResponseData`
    ///         is set, but with empty data field (since all the data was written
    ///         to the disk).
    public convenience init(error: DownloadError?,
                            totalBytes: UInt64?,
                            downloadOptions: DownloadOptions,
                            httpResult: Result<HttpResponseData, HttpRequestError>?) {

        let expected: Expected<AnyObject, AnyObject>?
        switch httpResult {
        case let .success(response):
            expected = Expected(value: response)
        case let .failure(error):
            expected = Expected(error: error)
        case .none:
            expected = nil
        }

        self.init(__error: error,
                  totalBytes: totalBytes?.NSNumber,
                  downloadOptions: downloadOptions,
                  httpResult: expected)
    }

    /// HTTP result. This field is only set for `DownloadState.failed` and
    /// `DownloadState.finished`.
    ///
    /// For `.failed` expect `HttpRequestError` to be provided for cases when
    /// `DownloadErrorCode` is `NetworkError`.
    ///  And for `.finished` `HttpResponseData` is set, but with empty data field
    ///  (since all the data was written to the disk).
    public var httpResult: Result<HttpResponseData, HttpRequestError>? {
        guard let httpExpected = __httpResult else {
            return nil
        }

        if httpExpected.isValue(), let value = httpExpected.value as? HttpResponseData {
            return .success(value)
        } else if httpExpected.isError(), let error = httpExpected.error as? HttpRequestError {
            return .failure(error)
        } else {
            fatalError("Found unexpected types.")
        }
    }

    /// Total amount of bytes to receive. In some cases this value is unknown
    /// until we get final part of the file being downloaded.
    public var totalBytes: UInt64? {
        return __totalBytes?.uint64Value
    }
}
