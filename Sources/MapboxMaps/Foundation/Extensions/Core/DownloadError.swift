@_exported import MapboxCommon
@_implementationOnly import MapboxCommon_Private

extension DownloadError {
    /// Standardized error message
    public var errorDescription: String? {
        return "\(code): \(message)"
    }
}
