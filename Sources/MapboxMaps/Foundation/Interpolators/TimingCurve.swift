import CoreGraphics

internal struct TimingCurve: Equatable {
    internal var p1: CGPoint
    internal var p2: CGPoint

    internal static let easeInOut = TimingCurve(
        p1: CGPoint(x: 0.42, y: 0),
        p2: CGPoint(x: 0.58, y: 1)
    )
}
