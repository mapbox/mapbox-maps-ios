import QuartzCore

internal protocol DisplayLinkProtocol: AnyObject {
    var timestamp: CFTimeInterval { get }
    var duration: CFTimeInterval { get }
    var preferredFramesPerSecond: Int { get set }
    // Checking Swift version as a proxy for iOS SDK version to enable
    // building with iOS SDKs < 15
    #if swift(>=5.5)
    @available(iOS 15.0, tvOS 15.0, *)
    var preferredFrameRateRange: CAFrameRateRange { get set }
    #endif
    func add(to runloop: RunLoop, forMode mode: RunLoop.Mode)
    func invalidate()
}

extension CADisplayLink: DisplayLinkProtocol {}
