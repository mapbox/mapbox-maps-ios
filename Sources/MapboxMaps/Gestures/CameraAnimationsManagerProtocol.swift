import Foundation

internal protocol CameraAnimationsManagerProtocol: AnyObject {

    func ease(to camera: CameraOptions,
              duration: TimeInterval,
              curve: UIView.AnimationCurve,
              completion: AnimationCompletion?) -> Cancelable?

    func cancelAnimations()
}

extension CameraAnimationsManager: CameraAnimationsManagerProtocol { }
