import QuartzCore

internal protocol DisplayLinkProtocol: AnyObject {
    var preferredFramesPerSecond: Int { get set }
    func add(to runloop: RunLoop, forMode mode: RunLoop.Mode)
    func invalidate()
}

extension CADisplayLink: DisplayLinkProtocol {}
