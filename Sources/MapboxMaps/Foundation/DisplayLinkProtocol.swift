import QuartzCore

internal protocol DisplayLinkProtocol: AnyObject {
    var timestamp: CFTimeInterval { get }
    var duration: CFTimeInterval { get }
    var preferredFramesPerSecond: Int { get set }
    func add(to runloop: RunLoop, forMode mode: RunLoop.Mode)
    func invalidate()
}

extension CADisplayLink: DisplayLinkProtocol {}
