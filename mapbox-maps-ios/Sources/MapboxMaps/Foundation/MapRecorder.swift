import Foundation
@_implementationOnly import MapboxCoreMaps_Private

// swiftlint:disable missing_docs
@_spi(Internal) public final class MapRecorder {
    let recorder: MapboxCoreMaps_Private.MapRecorder

    internal init(mapView: MapboxCoreMaps.Map) {
        recorder = MapboxCoreMaps_Private.MapRecorder(map: mapView)
    }

    // MARK: Recording

    public func start() {
        recorder.startRecording(for: MapRecorderOptions(timeWindow: nil))
    }

    public func stop() -> String {
        recorder.stopRecording()
    }

    // MARK: Replay

    /// Replay recorded map manipulations
    /// - Parameters:
    ///   - content: Recording content captured in return of ``stop()``
    ///   - playbackCount: The number of times the sequence is played. If negative, the playback loops indefinitely
    ///   - playbackSpeedMultiplier: Multiplies the speed of playback for faster or slower replays. (1 means no change.)
    ///   - avoidPlaybackPauses: When set to true, the player will try to interpolate actions between short wait actions,
    ///                          to continously render during the playback.
    ///                          This can help to maintain a consistent load during performance testing
    ///   - completion: Completion handler be called when replay finishes
    public func replay(
        content: String,
        playbackCount: Int = 1,
        playbackSpeedMultiplier: Double = 1.0,
        avoidPlaybackPauses: Bool = false,
        completion: @escaping () -> Void
    ) {

        let options = MapPlayerOptions(
            playbackCount: Int32(playbackCount),
            playbackSpeedMultiplier: playbackSpeedMultiplier,
            avoidPlaybackPauses: avoidPlaybackPauses
        )
        recorder.replay(forContent: content,
                        options: options,
                        callback: completion)
    }

    public func togglePauseReplay() {
        recorder.togglePauseReplay()
    }

    public func playbackState() -> String {
        recorder.getPlaybackState()
    }
}
// swiftlint:enable missing_docs
