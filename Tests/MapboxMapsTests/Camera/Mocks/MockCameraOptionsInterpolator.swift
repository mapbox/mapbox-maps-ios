@testable import MapboxMaps

final class MockCameraOptionsInterpolator: CameraOptionsInterpolatorProtocol {
    struct InterpolateParams {
        var from: CameraOptions
        var to: CameraOptions
        var fraction: Double
    }
    let interpolateStub = Stub<InterpolateParams, CameraOptions>(defaultReturnValue: .testConstantValue())
    func interpolate(from: CameraOptions, to: CameraOptions, fraction: Double) -> CameraOptions {
        interpolateStub.call(with: .init(from: from, to: to, fraction: fraction))
    }
}
