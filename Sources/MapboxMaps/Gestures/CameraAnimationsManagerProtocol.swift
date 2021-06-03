import Foundation

internal protocol CameraAnimationsManagerProtocol: AnyObject {

    var mapView: MapView? { get }

    var options: CameraBoundsOptions { get }

    func ease(to camera: CameraOptions,
              duration: TimeInterval,
              curve: UIView.AnimationCurve,
              completion: AnimationCompletion?) -> Cancelable?

    func cancelAnimations()
}

extension CameraAnimationsManager: CameraAnimationsManagerProtocol { }
