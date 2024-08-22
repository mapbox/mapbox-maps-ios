import Foundation

/// MapboxRecorder provides functions to record and replay API calls of a ``MapboxMap`` instance.
/// These recordings can be used to debug issues which require multiple steps to reproduce.
/// Additionally, playbacks can be used for performance testing custom scenarios.
///
/// - Note: The file format produced by MapRecorder is experimental and there is no guarantee for version cross-compatibility.
/// The set of recorded APIs and their parameters might change in future releases.
@_spi(Experimental) public final class MapRecorder {
    let recorder: MapboxCoreMaps.MapRecorder

    internal init(mapView: CoreMap) throws {
        recorder = try handleExpected {
            MapboxCoreMaps.MapRecorder.createInstance(for: mapView)
        }
    }

    // MARK: Recording

    /// Begins the recording session.
    ///
    /// - Parameters:
    ///   - options: `MapRecorderOptions` to control recording. Optional.
    public func start(options: MapRecorderOptions = MapRecorderOptions(timeWindow: nil, loggingEnabled: false, compressed: false)) {
        let mapRecorderOptions = CoreMapRecorderOptions(timeWindow: options.timeWindow as NSNumber?, loggingEnabled: options.loggingEnabled, compressed: options.compressed)
        recorder.startRecording(for: mapRecorderOptions)
    }

    /// Stops the current recording session.
    /// Recorded section can be replayed with ``replay(recordedSequence:options:completion:)`` function.
    /// Returns the `Data` containing the recorded sequence in raw format.
    public func stop() -> Data {
        recorder.stopRecording().data
    }

    // MARK: Replay

    /// Replay a supplied sequence from a map recording
    ///
    /// - Parameters:
    ///   - recordedSequence: A data reference which should contain a re-playable sequence as a gzip compressed or plain JSON string.
    ///   This is the recorded content captured in the return of ``stop()``
    ///   - options: Options to customize the behavior of the playback, see ``MapPlayerOptions``. Optional.
    ///   - completion: Completion handler be called when replay finishes
    public func replay(
        recordedSequence: Data,
        options: MapPlayerOptions = MapPlayerOptions(playbackCount: 1, playbackSpeedMultiplier: 1.0, avoidPlaybackPauses: false),
        completion: @escaping () -> Void
    ) {
        let mapPlayerOptions = CoreMapPlayerOptions(
            playbackCount: Int32(options.playbackCount),
            playbackSpeedMultiplier: options.playbackSpeedMultiplier,
            avoidPlaybackPauses: options.avoidPlaybackPauses)

        recorder.replay(forContent: DataRef(data: recordedSequence),
                        options: mapPlayerOptions,
                        callback: completion)
    }

    /// Temporarily pauses or resumes playback if already paused.
    public func togglePauseReplay() {
        recorder.togglePauseReplay()
    }

    /// Returns the string description of the current state of playback.
    public func playbackState() -> String {
        recorder.getPlaybackState()
    }
}
