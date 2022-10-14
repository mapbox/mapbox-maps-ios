import Foundation
@testable import MapboxMaps

final class MockDisplayLink: DisplayLinkProtocol {

    var timestamp: CFTimeInterval = 0

    var duration: CFTimeInterval = 0

    var preferredFramesPerSecond: Int = 0

    @Stubbed var isPaused: Bool = false

    // Checking Swift version as a proxy for iOS SDK version to enable
    // building with iOS SDKs < 15
    @available(iOS 15.0, *)
    var preferredFrameRateRange: CAFrameRateRange {
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
    func add(to runloop: RunLoop, forMode mode: RunLoop.Mode) {
        addStub.call(with: AddParams(runloop: runloop, mode: mode))
    }

    let invalidateStub = Stub<Void, Void>()
    func invalidate() {
        invalidateStub.call()
    }
}
