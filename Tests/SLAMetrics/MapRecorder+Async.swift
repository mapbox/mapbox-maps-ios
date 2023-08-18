@_spi(Experimental) import MapboxMaps

extension MapRecorder {

    @MainActor
    func replay(recordedSequence: Data, options: MapPlayerOptions = MapPlayerOptions(playbackCount: 1, playbackSpeedMultiplier: 1.0, avoidPlaybackPauses: false)) async {
        return await withCheckedContinuation { continuation in
            replay(recordedSequence: recordedSequence, options: options) {
                continuation.resume(returning: ())
            }
        }
    }
}
