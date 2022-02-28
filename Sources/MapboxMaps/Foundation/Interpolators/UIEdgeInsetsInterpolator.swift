import UIKit

internal protocol UIEdgeInsetsInterpolatorProtocol: AnyObject {
    func interpolate(from: UIEdgeInsets,
                     to: UIEdgeInsets,
                     fraction: Double) -> UIEdgeInsets
}

internal final class UIEdgeInsetsInterpolator: UIEdgeInsetsInterpolatorProtocol {
    private let doubleInterpolator: DoubleInterpolatorProtocol

    internal init(doubleInterpolator: DoubleInterpolatorProtocol) {
        self.doubleInterpolator = doubleInterpolator
    }

    func interpolate(from: UIEdgeInsets,
                     to: UIEdgeInsets,
                     fraction: Double) -> UIEdgeInsets {
        let top = doubleInterpolator.interpolate(
            from: Double(from.top),
            to: Double(to.top),
            fraction: fraction)
        let left = doubleInterpolator.interpolate(
            from: Double(from.left),
            to: Double(to.left),
            fraction: fraction)
        let bottom = doubleInterpolator.interpolate(
            from: Double(from.bottom),
            to: Double(to.bottom),
            fraction: fraction)
        let right = doubleInterpolator.interpolate(
            from: Double(from.right),
            to: Double(to.right),
            fraction: fraction)
        return UIEdgeInsets(
            top: CGFloat(top),
            left: CGFloat(left),
            bottom: CGFloat(bottom),
            right: CGFloat(right))
    }
}
