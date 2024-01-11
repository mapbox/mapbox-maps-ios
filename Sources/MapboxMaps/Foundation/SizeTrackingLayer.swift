import QuartzCore

protocol SizeTrackingLayerDelegate: AnyObject, CALayerDelegate {
    /// Layer is going to run resize animation
    /// - Parameters:
    ///   - willAnimateResizingFrom: original size
    ///   - to: new size
    func sizeTrackingLayer(layer: SizeTrackingLayer, willAnimateResizingFrom: CGSize, to: CGSize)

    /// Layer has completed resize animation or no-animation operation
    ///
    /// Animation completeness is detected by `CATransaction/setCompletionBlock` in the `bounds/didSet` trigger
    /// - Parameters:
    ///   - completeResizingFrom: original size
    ///   - to: new size
    func sizeTrackingLayer(layer: SizeTrackingLayer, completeResizingFrom: CGSize, to: CGSize)
}

class SizeTrackingLayer: CALayer {
    private var sizeTrackingDelegate: SizeTrackingLayerDelegate? { delegate as? SizeTrackingLayerDelegate }

    private var sizeAnimationIsActive = false

    override func add(_ anim: CAAnimation, forKey key: String?) {
        if anim.isAnimatingBounds {
            sizeAnimationIsActive = true
        }
        super.add(anim, forKey: key)
    }

    override var bounds: CGRect {
        didSet {
            guard oldValue.size != bounds.size else { return }
            guard sizeAnimationIsActive else {
                sizeTrackingDelegate?.sizeTrackingLayer(layer: self, completeResizingFrom: oldValue.size, to: bounds.size)
                return
            }

            CATransaction.setCompletionBlock { [bounds, weak self] in
                guard let self else { return }

                self.sizeTrackingDelegate?.sizeTrackingLayer(layer: self, completeResizingFrom: oldValue.size, to: bounds.size)

                self.sizeAnimationIsActive = false
            }

            sizeTrackingDelegate?.sizeTrackingLayer(layer: self, willAnimateResizingFrom: oldValue.size, to: bounds.size)
        }
    }
}

extension CAAnimation {
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
