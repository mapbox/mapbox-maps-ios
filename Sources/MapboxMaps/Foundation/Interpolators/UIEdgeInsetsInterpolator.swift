import UIKit

internal protocol UIEdgeInsetsInterpolatorProtocol: AnyObject {
    func interpolate(from: UIEdgeInsets,
                     to: UIEdgeInsets,
                     fraction: Double) -> UIEdgeInsets
}

internal final class UIEdgeInsetsInterpolator: UIEdgeInsetsInterpolatorProtocol {
    private let interpolator: InterpolatorProtocol

    internal init(interpolator: InterpolatorProtocol) {
        self.interpolator = interpolator
    }

    func interpolate(from: UIEdgeInsets,
                     to: UIEdgeInsets,
                     fraction: Double) -> UIEdgeInsets {
        let top = interpolator.interpolate(
            from: Double(from.top),
            to: Double(to.top),
            fraction: fraction)
        let left = interpolator.interpolate(
            from: Double(from.left),
            to: Double(to.left),
            fraction: fraction)
        let bottom = interpolator.interpolate(
            from: Double(from.bottom),
            to: Double(to.bottom),
            fraction: fraction)
        let right = interpolator.interpolate(
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
