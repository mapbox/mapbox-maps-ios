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
        var completion: ((Bool) -> Void)?
    }
    let setCameraStub = Stub<SetCameraParameters, Void>()
    func setCamera(to camera: CameraOptions,
                   animated: Bool,
                   duration: TimeInterval,
                   completion: ((Bool) -> Void)?) {
        setCameraStub.call(
            with: SetCameraParameters(camera: camera,
                                      animated: animated,
                                      duration: duration,
                                      completion: completion))
    }

    //swiftlint:disable function_parameter_count
    func moveCamera(by offset: CGPoint?,
                    rotation: CGFloat?,
                    pitch: CGFloat?,
                    zoom: CGFloat?,
                    animated: Bool,
                    pitchedDrift: Bool) {
    }

    func cancelTransitions() {
    }
}
