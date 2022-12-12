import QuartzCore

internal protocol ForwardingDisplayLinkTargetDelegate: AnyObject {
    func update(with displayLink: CADisplayLink)
}

internal final class ForwardingDisplayLinkTarget {
    weak var delegate: ForwardingDisplayLinkTargetDelegate?

    internal init(delegate: ForwardingDisplayLinkTargetDelegate) {
        self.delegate = delegate
    }

    @objc internal func update(with displayLink: CADisplayLink) {
        delegate?.update(with: displayLink)
    }
}
