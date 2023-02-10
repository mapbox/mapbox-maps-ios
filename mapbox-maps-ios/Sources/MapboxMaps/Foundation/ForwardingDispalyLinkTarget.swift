import QuartzCore

internal class ForwardingDisplayLinkTarget: NSObject {
    private let handler: (CADisplayLink) -> Void

    internal init(handler: @escaping (CADisplayLink) -> Void) {
        self.handler = handler
        super.init()
    }

    @objc internal func update(with displayLink: CADisplayLink) {
        handler(displayLink)
    }
}
