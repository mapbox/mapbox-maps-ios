import QuartzCore

internal final class ForwardingDisplayLinkTarget {
    private let handler: (CADisplayLink) -> Void

    internal init(handler: @escaping (CADisplayLink) -> Void) {
        self.handler = handler
    }

    @objc internal func update(with displayLink: CADisplayLink) {
        handler(displayLink)
    }
}

internal protocol DelegatingDisplayLinkTargetDelegate: AnyObject {
    func delegatingTargetDisplayLinkDidUpdate(_ displayLink: DisplayLinkProtocol)
}

internal final class DelegatingDisplayLinkTarget {
    internal weak var delegate: DelegatingDisplayLinkTargetDelegate?

    internal init(delegate: DelegatingDisplayLinkTargetDelegate? = nil) {
        self.delegate = delegate
    }

    @objc internal func update(with displayLink: CADisplayLink) {
        delegate?.delegatingTargetDisplayLinkDidUpdate(displayLink)
    }
}
