public struct FollowPuckViewportStateOptions: Hashable {
    public var zoom: CGFloat
    public var pitch: CGFloat
    public var bearing: FollowPuckViewportStateBearing
    public var padding: UIEdgeInsets
    public var animationDuration: TimeInterval

    public init(zoom: CGFloat = 15,
                pitch: CGFloat = 40,
                bearing: FollowPuckViewportStateBearing = .constant(0),
                padding: UIEdgeInsets = .zero,
                animationDuration: TimeInterval = 1) {
        self.zoom = zoom
        self.pitch = pitch
        self.bearing = bearing
        self.padding = padding
        self.animationDuration = animationDuration
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(zoom)
        hasher.combine(pitch)
        hasher.combine(bearing)
        hasher.combine(padding.top)
        hasher.combine(padding.left)
        hasher.combine(padding.bottom)
        hasher.combine(padding.right)
        hasher.combine(animationDuration)
    }
}
