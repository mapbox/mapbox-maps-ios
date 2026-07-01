import UIKit
import ObjectiveC

private var collisionBoxKey: UInt8 = 0
private var overrideCollisionBoxesKey: UInt8 = 0

extension UIView {
    /// Marks this view as a collision box for the enclosing view annotation.
    ///
    /// When at least one subview is marked, only marked subviews' frames are used
    /// as collision boxes. When none are marked, the full annotation bounds are used.
    @_spi(Experimental)
    public var mbxViewAnnotationCollisionBox: Bool {
        get { objc_getAssociatedObject(self, &collisionBoxKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &collisionBoxKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Collision boxes set explicitly (e.g. by SwiftUI preference keys), taking precedence
    /// over the recursive subview walk.
    var overrideCollisionBoxes: [CGRect]? {
        get { objc_getAssociatedObject(self, &overrideCollisionBoxesKey) as? [CGRect] }
        set { objc_setAssociatedObject(self, &overrideCollisionBoxesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Collects frames of subviews marked with `collisionBox`,
    /// relative to this view's coordinate system.
    /// Returns `overrideCollisionBoxes` when set, falling back to the recursive subview walk.
    func collisionBoxes() -> [CGRect]? {
        if let override = overrideCollisionBoxes {
            return override.isEmpty ? nil : override
        }
        var boxes: [CGRect] = []
        collectCollisionBoxes(relativeTo: self, into: &boxes)
        return boxes.isEmpty ? nil : boxes
    }

    private func collectCollisionBoxes(relativeTo root: UIView, into boxes: inout [CGRect]) {
        if mbxViewAnnotationCollisionBox {
            boxes.append(convert(bounds, to: root))
            return
        }
        for subview in subviews {
            subview.collectCollisionBoxes(relativeTo: root, into: &boxes)
        }
    }
}
