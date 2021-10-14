import Foundation
import CoreGraphics
import UIKit
@testable import MapboxMaps

final class MockCameraAnimationsManager: CameraAnimationsManagerProtocol {

    struct EaseToCameraParameters {
        var camera: CameraOptions
        var duration: TimeInterval
        var curve: UIView.AnimationCurve
        var completion: AnimationCompletion?
    }
    let easeToStub = Stub<EaseToCameraParameters, CameraAnimator?>(defaultReturnValue: nil)
    func ease(to camera: CameraOptions,
              duration: TimeInterval,
              curve: UIView.AnimationCurve,
              completion: AnimationCompletion?) -> Cancelable? {
        return easeToStub.call(
            with: EaseToCameraParameters(
                camera: camera,
                duration: duration,
                curve: curve,
                completion: completion))
    }

    let cancelAnimationsStub = Stub<Void, Void>()
    func cancelAnimations() {
        cancelAnimationsStub.call()
    }

    var animationsEnabled: Bool = true

    struct DecelerateParameters {
        var location: CGPoint
        var velocity: CGPoint
        var decelerationFactor: CGFloat
        var locationChangeHandler: (CGPoint) -> Void
        var completion: () -> Void
    }
    let decelerateStub = Stub<DecelerateParameters, Void>()
    func decelerate(location: CGPoint,
                    velocity: CGPoint,
                    decelerationFactor: CGFloat,
                    locationChangeHandler: @escaping (CGPoint) -> Void,
                    completion: @escaping () -> Void) {

        return decelerateStub.call(
            with: DecelerateParameters(
                location: location,
                velocity: velocity,
                decelerationFactor: decelerationFactor,
                locationChangeHandler: locationChangeHandler,
                completion: completion))
    }
}
