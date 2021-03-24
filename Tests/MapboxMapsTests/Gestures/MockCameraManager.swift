import Foundation
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
import MapboxMapsFoundation
@testable import MapboxMapsGestures
#endif

final class MockCameraManager: CameraManagerProtocol {

    var mapView: BaseMapView?

    var mapCameraOptions = MapCameraOptions()

    struct SetCameraParameters {
        var camera: CameraOptions
        var animated: Bool
        var duration: TimeInterval
        var completion: ((UIViewAnimatingPosition) -> Void)?
    }

    let setCameraStub = Stub<SetCameraParameters, Void>()

    func setCamera(to camera: CameraOptions,
                   animated: Bool,
                   duration: TimeInterval,
                   completion: ((UIViewAnimatingPosition) -> Void)?) {
        setCameraStub.call(
            with: SetCameraParameters(camera: camera,
                                      animated: animated,
                                      duration: duration,
                                      completion: completion))
    }

    func cancelTransitions() {
    }
}
