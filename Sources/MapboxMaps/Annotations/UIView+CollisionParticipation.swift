import UIKit
import ObjectiveC

private var collisionBoxKey: UInt8 = 0
private var overrideCollisionBoxesKey: UInt8 = 0

/// Process-wide counter of collision participation changes: a flag flipped or override boxes
/// appearing/disappearing. Annotations without participants re-check their hierarchy only when it moves.
enum CollisionParticipation {
    private(set) static var generation: UInt = 0
    static func bump() { generation &+= 1 }
}

extension UIView {
    /// Marks this view as a collision box for the enclosing view annotation.
    ///
    /// When at least one subview is marked, only marked subviews' frames are used
    /// as collision boxes. When none are marked, the full annotation bounds are used.
    ///
    /// A view removed from the hierarchy or with `isHidden = true` stops colliding.
    /// A view with `alpha = 0` keeps its layout and still collides.
    ///
    /// Adding an already marked view to an annotation that had no marked views is a layout change:
    /// call ``ViewAnnotation/setNeedsUpdateSize()`` as for any other layout change.
    @_spi(Experimental)
    public var mbxViewAnnotationCollisionBox: Bool {
        get { objc_getAssociatedObject(self, &collisionBoxKey) as? Bool ?? false }
        set {
            guard newValue != mbxViewAnnotationCollisionBox else { return }
            objc_setAssociatedObject(self, &collisionBoxKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            CollisionParticipation.bump()
        }
    }

    /// Collision boxes set explicitly (e.g. by SwiftUI preference keys), taking precedence
    /// over the recursive subview walk.
    var overrideCollisionBoxes: [CGRect]? {
        get { objc_getAssociatedObject(self, &overrideCollisionBoxesKey) as? [CGRect] }
        set {
            let oldValue = overrideCollisionBoxes
            guard newValue != oldValue else { return }
            objc_setAssociatedObject(self, &overrideCollisionBoxesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            // Only nil <-> non-nil is a participation change; value changes are read directly on sync.
            if (oldValue == nil) != (newValue == nil) { CollisionParticipation.bump() }
        }
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

    /// Whether the hierarchy has any collision box participants, without doing `collisionBoxes()`' rect math.
    func hasCollisionBoxParticipants() -> Bool {
        // Override is read on the root only, mirroring `collisionBoxes()`.
        if overrideCollisionBoxes != nil { return true }
        return hasMarkedSubview()
    }

    private func hasMarkedSubview() -> Bool {
        mbxViewAnnotationCollisionBox || subviews.contains { $0.hasMarkedSubview() }
    }

    private func collectCollisionBoxes(relativeTo root: UIView, into boxes: inout [CGRect]) {
        // Root's isHidden is annotation-managed visibility, not a user opt-out.
        if self !== root && isHidden { return }
        if mbxViewAnnotationCollisionBox {
            // A zero frame means the view is not laid out yet.
            if bounds.width > 0 && bounds.height > 0 {
                boxes.append(convert(bounds, to: root))
            }
            return
        }
        for subview in subviews {
            subview.collectCollisionBoxes(relativeTo: root, into: &boxes)
        }
    }
}
