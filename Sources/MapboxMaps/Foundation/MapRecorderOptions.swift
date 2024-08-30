/// Options for recording the map when using ``MapRecorder``
public struct MapRecorderOptions: Sendable {
    /// The maximum duration (in milliseconds) from the current time until API calls are kept.
    /// If not specified, all API calls will be kept during the recording,
    /// which can lead to significant memory consumption for long sessions.
    let timeWindow: Int?

    /// If set to true, the recorded API calls will be printed in the logs.
    let loggingEnabled: Bool

    /// If set to true, the recorded output will be compressed with gzip.
    let compressed: Bool

    /// Initializes a set of options to control the recording of a map recording
    public init(timeWindow: Int?, loggingEnabled: Bool, compressed: Bool) {
        self.timeWindow = timeWindow
        self.loggingEnabled = loggingEnabled
        self.compressed = compressed
    }
}
