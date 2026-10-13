import QuartzCore

protocol SizeTrackingLayerDelegate: AnyObject, CALayerDelegate {
    /// Layer is going to run resize animation
    /// - Parameters:
    ///   - willAnimateResizingFrom: original size
    ///   - to: new size
    func sizeTrackingLayer(layer: SizeTrackingLayer, willAnimateResizingFrom: CGSize, to: CGSize)

    /// Layer has completed resize animation or no-animation operation
    ///
    /// Animation completeness is detected by a nested `CATransaction` completion block around each bounds animation in `add(_:forKey:)`
    /// - Parameters:
    ///   - completeResizingFrom: original size
    ///   - to: new size
    func sizeTrackingLayer(layer: SizeTrackingLayer, completeResizingFrom: CGSize, to: CGSize)
}

class SizeTrackingLayer: CALayer {
    private var sizeTrackingDelegate: SizeTrackingLayerDelegate? { delegate as? SizeTrackingLayerDelegate }

    /// Bounds animations added to the layer whose completion hasn't fired yet.
    private var pendingBoundsAnimations = 0
    private var sizeAnimationIsActive: Bool { pendingBoundsAnimations > 0 }
    private var animatedResizeStartSize: CGSize?

    override func add(_ anim: CAAnimation, forKey key: String?) {
        // An infinite animation never completes, so resizes don't wait for it.
        guard anim.isAnimatingBounds, anim.isFinite else {
            super.add(anim, forKey: key)
            return
        }

        pendingBoundsAnimations += 1
        // A nested transaction scopes the completion to this animation, so unrelated animations in the outer one can't hold it.
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.boundsAnimationDidComplete()
        }
        super.add(anim, forKey: key)
        CATransaction.commit()
    }

    override var bounds: CGRect {
        didSet {
            Log.debug("""
                \(SizeTrackingLayer.self) did resize
                    Layer: \(self)
                    Old size: \(oldValue.size)
                    New size: \(bounds.size)
                    Animation is \(sizeAnimationIsActive ? "" : "NOT ")active
                """, category: .sizeTrackingLayer)
            guard oldValue.size != bounds.size else { return }
            guard sizeAnimationIsActive else {
                sizeTrackingDelegate?.sizeTrackingLayer(layer: self, completeResizingFrom: oldValue.size, to: bounds.size)
                return
            }

            if animatedResizeStartSize == nil {
                animatedResizeStartSize = oldValue.size
            }
            sizeTrackingDelegate?.sizeTrackingLayer(layer: self, willAnimateResizingFrom: oldValue.size, to: bounds.size)
        }
    }

    private func boundsAnimationDidComplete() {
        pendingBoundsAnimations -= 1
        // With several resizes in one animation period, only the last completion applies the final size.
        guard pendingBoundsAnimations == 0, let startSize = animatedResizeStartSize else { return }
        animatedResizeStartSize = nil

        Log.debug("""
            \(SizeTrackingLayer.self) animation completed
                layer: \(self)
                Old size: \(startSize)
                New size: \(bounds.size)
            """, category: .sizeTrackingLayer)

        sizeTrackingDelegate?.sizeTrackingLayer(layer: self, completeResizingFrom: startSize, to: bounds.size)
    }
}

extension CAAnimation {
    /// Whether the animation ends, so its completion fires.
    var isFinite: Bool {
        duration.isFinite && repeatCount.isFinite && repeatDuration.isFinite
    }

    /// Detect animation keypath that might affect bounds size
    ///
    /// Keypath argument supports KVC meaning that `bounds.size.height` is the valid value.
    ///
    /// [Key Path Support for Structures](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/Key-ValueCodingExtensions/Key-ValueCodingExtensions.html#//apple_ref/doc/uid/TP40004514-CH12-SW13)
    var isAnimatingBounds: Bool {
        switch self {
        case let animation as CAPropertyAnimation:
            return animation.keyPath?.starts(with: "bounds") == true
        case let animation as CAAnimationGroup:
            return animation.animations?.first(where: \.isAnimatingBounds) != nil
        default:
            return false
        }
    }
}
