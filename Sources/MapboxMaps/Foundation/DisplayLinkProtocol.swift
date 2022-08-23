import QuartzCore

internal protocol DisplayLinkProtocol: AnyObject {
    var timestamp: CFTimeInterval { get }
    var targetTimestamp: CFTimeInterval { get }
    var duration: CFTimeInterval { get }
    var preferredFramesPerSecond: Int { get set }
    // Checking Swift version as a proxy for iOS SDK version to enable
    // building with iOS SDKs < 15
    #if swift(>=5.5)
    @available(iOS 15.0, *)
    var preferredFrameRateRange: CAFrameRateRange { get set }
    #endif
    var isPaused: Bool { get set }
    func add(to runloop: RunLoop, forMode mode: RunLoop.Mode)
    func remove(from runloop: RunLoop, forMode mode: RunLoop.Mode)
    func invalidate()

    init(target: Any, selector sel: Selector)
}

extension CADisplayLink: DisplayLinkProtocol {}
