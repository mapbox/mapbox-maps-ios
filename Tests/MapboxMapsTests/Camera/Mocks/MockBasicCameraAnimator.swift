import UIKit
@testable import MapboxMaps

final class MockBasicCameraAnimator: BasicCameraAnimatorProtocol {
    @TestSignal var onCameraAnimatorStatusChanged: MapboxMaps.Signal<MapboxMaps.CameraAnimatorStatus>

    @Stubbed var owner: AnimationOwner = .unspecified
    @Stubbed var animationType: AnimationType = .unspecified
    @Stubbed var transition: CameraTransition?
    @Stubbed var state: UIViewAnimatingState = .inactive
    @Stubbed var isRunning: Bool = false
    @Stubbed var isReversed: Bool = false
    @Stubbed var pausesOnCompletion: Bool = false
    @Stubbed var fractionComplete: Double = 0

    let startAnimationStub = Stub<Void, Void>()
    func startAnimation() {
        startAnimationStub.call()
    }

    let startAnimationAfterDelayStub = Stub<TimeInterval, Void>()
    func startAnimation(afterDelay delay: TimeInterval) {
        startAnimationAfterDelayStub.call(with: delay)
    }

    let pauseAnimationStub = Stub<Void, Void>()
    func pauseAnimation() {
        pauseAnimationStub.call()
    }

    let stopAnimationStub = Stub<Void, Void>()
    func stopAnimation() {
        stopAnimationStub.call()
    }

    let addCompletionStub = Stub<AnimationCompletion, Void>()
    func addCompletion(_ completion: @escaping AnimationCompletion) {
        addCompletionStub.call(with: completion)
    }

    struct ContinueAnimationParams {
        var timingParameters: UITimingCurveProvider?
        var durationFactor: Double
    }
    let continueAnimationStub = Stub<ContinueAnimationParams, Void>()
    func continueAnimation(withTimingParameters timingParameters: UITimingCurveProvider?,
                           durationFactor: Double) {
        continueAnimationStub.call(with: .init(
            timingParameters: timingParameters,
            durationFactor: durationFactor))
    }

    let updateStub = Stub<Void, Void>()
    func update() {
        updateStub.call()
    }
}
