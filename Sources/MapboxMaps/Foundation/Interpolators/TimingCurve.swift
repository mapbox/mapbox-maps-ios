import CoreGraphics

internal struct TimingCurve: Equatable {
    internal var p1: CGPoint
    internal var p2: CGPoint

    internal static let easeInOut = TimingCurve(
        p1: CGPoint(x: 0.42, y: 0),
        p2: CGPoint(x: 0.58, y: 1)
    )
    internal static let linear = TimingCurve(
        p1: .zero,
        p2: CGPoint(x: 1, y: 1)
    )
}
