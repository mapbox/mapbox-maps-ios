@_spi(Experimental) public struct FollowPuckViewportStateOptions: Hashable {
    public var padding: UIEdgeInsets?
    public var zoom: CGFloat?
    public var bearing: FollowPuckViewportStateBearing?
    public var pitch: CGFloat?
    public var animationDuration: TimeInterval

    public init(padding: UIEdgeInsets? = .zero,
                zoom: CGFloat? = 16.35,
                bearing: FollowPuckViewportStateBearing? = .heading,
                pitch: CGFloat? = 45,
                animationDuration: TimeInterval = 1) {
        self.padding = padding
        self.zoom = zoom
        self.bearing = bearing
        self.pitch = pitch
        self.animationDuration = animationDuration
    }

    public func hash(into hasher: inout Hasher) {
        if let padding = padding {
            hasher.combine(padding.top)
            hasher.combine(padding.left)
            hasher.combine(padding.bottom)
            hasher.combine(padding.right)
        }
        hasher.combine(zoom)
        hasher.combine(bearing)
        hasher.combine(pitch)
        hasher.combine(animationDuration)
    }
}
