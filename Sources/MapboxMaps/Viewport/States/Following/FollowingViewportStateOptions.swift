public struct FollowingViewportStateOptions: Hashable {
    public var zoom: CGFloat
    public var pitch: CGFloat
    public var bearing: FollowingViewportStateBearing
    public var animationDuration: TimeInterval

    public init(zoom: CGFloat = 15,
                pitch: CGFloat = 40,
                bearing: FollowingViewportStateBearing = .constant(0),
                animationDuration: TimeInterval = 1) {
        self.zoom = zoom
        self.pitch = pitch
        self.bearing = bearing
        self.animationDuration = animationDuration
    }
}
