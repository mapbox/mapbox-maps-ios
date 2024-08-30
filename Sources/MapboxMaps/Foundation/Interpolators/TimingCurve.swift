import CoreGraphics

/// Timing curve to use in animator.
public struct TimingCurve: Equatable, Sendable {
    let p1: CGPoint
    let p2: CGPoint

    /// An ease-in ease-out curve causes the animation to begin slowly, accelerate through the middle of its duration.
    /// And then slow again before completing.
    public static let easeInOut = TimingCurve(
        p1: CGPoint(x: 0.42, y: 0),
        p2: CGPoint(x: 0.58, y: 1)
    )

    /// An ease-in curve causes the animation to begin slowly, and then speed up as it progresses.
    public static let easeIn = TimingCurve(
        p1: CGPoint(x: 0.58, y: 0),
        p2: CGPoint(x: 1, y: 1)
    )

    /// An ease-out curve causes the animation to begin quickly, and then slow down as it completes.
    public static let easeOut = TimingCurve(
        p1: CGPoint(x: 0, y: 0),
        p2: CGPoint(x: 0.42, y: 1)
    )

    /// A linear animation curve causes an animation to occur evenly over its duration.
    public static let linear = TimingCurve(
        p1: CGPoint(x: 0, y: 0),
        p2: CGPoint(x: 1, y: 1)
    )
}
