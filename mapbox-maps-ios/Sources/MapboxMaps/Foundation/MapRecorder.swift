import Foundation
@_implementationOnly import MapboxCoreMaps_Private

// swiftlint:disable missing_docs
@_spi(Internal) public final class MapRecorder {
    let recorder: MapboxCoreMaps_Private.MapRecorder

    internal init(mapView: Map) {
        recorder = MapboxCoreMaps_Private.MapRecorder(map: mapView)
    }

    // MARK: Recording

    public func start() {
        recorder.startRecording()
    }

    public func stop() -> String {
        recorder.stopRecording()
    }

    // MARK: Replay

    public func replay(
        content: String,
        playbackCount: Int = 1,
        playbackSpeedMultiplier: Double = 1.0,
        completion: @escaping () -> Void
    ) {
        recorder.replay(forContent: content,
                        playbackCount: Int32(playbackCount),
                        playbackSpeedMultiplier: playbackSpeedMultiplier,
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
