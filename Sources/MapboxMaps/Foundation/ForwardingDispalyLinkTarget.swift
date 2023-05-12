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
