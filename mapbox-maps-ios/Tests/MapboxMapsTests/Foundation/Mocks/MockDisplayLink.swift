import UIKit
@testable import MapboxMaps

final class MockDisplayLink: CADisplayLink {

    var _timestamp: CFTimeInterval = 0
    override var timestamp: CFTimeInterval { _timestamp }

    var _duration: CFTimeInterval = 0
    override var duration: CFTimeInterval { _duration }

    @Stubbed var isPausedStub: Bool = false
    override var isPaused: Bool {
        get {
            return $isPausedStub.getStub.call()
        }
        set {
            $isPausedStub.setStub.call(with: newValue)
            $isPausedStub.getStub.defaultReturnValue = newValue
        }
    }

    var _preferredFramesPerSecond: Int = 0
    override var preferredFramesPerSecond: Int {
        get { _preferredFramesPerSecond }
        set { _preferredFramesPerSecond = newValue }
    }

    // Checking Swift version as a proxy for iOS SDK version to enable
    // building with iOS SDKs < 15
    @available(iOS 15.0, *)
    override var preferredFrameRateRange: CAFrameRateRange {
        get {
            return (_untypedPreferredFrameRateRange as? CAFrameRateRange) ?? .default
        } set {
            _untypedPreferredFrameRateRange = newValue
        }
    }

    private var _untypedPreferredFrameRateRange: Any?

    struct AddParams {
        var runloop: RunLoop
        var mode: RunLoop.Mode
    }
    let addStub = Stub<AddParams, Void>()
    override func add(to runloop: RunLoop, forMode mode: RunLoop.Mode) {
        addStub.call(with: AddParams(runloop: runloop, mode: mode))
    }

    let invalidateStub = Stub<Void, Void>()
    override func invalidate() {
        invalidateStub.call()
    }
}
