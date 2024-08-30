/// Options for playback when using ``MapRecorder``
public struct MapPlayerOptions: Sendable {
    /// The number of times the sequence is played. If negative, the playback loops indefinitely.
    let playbackCount: Int

    /// Multiplies the speed of playback for faster or slower replays. (1 means no change.)
    let playbackSpeedMultiplier: Double

    /// When set to true, the player will try to interpolate actions between short wait actions,
    /// to continuously render during the playback.
    /// This can help to maintain a consistent load during performance testing.
    let avoidPlaybackPauses: Bool

    /// Initializes a set of options to control the playback of a map recording
    public init(playbackCount: Int, playbackSpeedMultiplier: Double, avoidPlaybackPauses: Bool) {
        self.playbackCount = playbackCount
        self.playbackSpeedMultiplier = playbackSpeedMultiplier
        self.avoidPlaybackPauses = avoidPlaybackPauses
    }
}
