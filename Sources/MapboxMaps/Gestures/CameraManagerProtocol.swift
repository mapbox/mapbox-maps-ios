import Foundation

internal protocol CameraManagerProtocol: AnyObject {

    var mapView: BaseMapView? { get }

    var options: MapCameraOptions { get }

    func setCamera(to camera: CameraOptions)

    func ease(to camera: CameraOptions,
              duration: TimeInterval,
              curve: UIView.AnimationCurve,
              completion: AnimationCompletion?) -> CameraAnimator?

    func cancelAnimations()
}

extension CameraAnimationsManager: CameraManagerProtocol { }
