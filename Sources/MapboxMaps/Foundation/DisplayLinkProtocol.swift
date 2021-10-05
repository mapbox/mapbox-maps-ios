import QuartzCore

internal protocol DisplayLinkProtocol: AnyObject {
    var timestamp: CFTimeInterval { get }
    var duration: CFTimeInterval { get }
    var preferredFramesPerSecond: Int { get set }
    #if swift(>=5.5)
    @available(iOS 15.0, *)
    var preferredFrameRateRange: CAFrameRateRange { get set }
    #endif
    func add(to runloop: RunLoop, forMode mode: RunLoop.Mode)
    func invalidate()
}

extension CADisplayLink: DisplayLinkProtocol {}
