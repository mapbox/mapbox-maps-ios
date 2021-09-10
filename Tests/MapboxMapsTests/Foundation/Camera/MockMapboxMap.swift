@testable import MapboxMaps

final class MockMapboxMap: MapboxMapProtocol {

    var cameraState = CameraState(
        MapboxCoreMaps.CameraState(
            center: CLLocationCoordinate2D(
                latitude: 0, longitude: 0),
            padding: EdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0),
            zoom: 0,
            bearing: 0,
            pitch: 0))

    var anchor = CGPoint.zero

    let setCameraStub = Stub<CameraOptions, Void>()
    func setCamera(to cameraOptions: CameraOptions) {
        setCameraStub.call(with: cameraOptions)
    }

    func dragStart(for point: CGPoint) {}

    struct DragCameraOptionsParams {
        var from: CGPoint
        var to: CGPoint
    }
    let dragCameraOptionsStub = Stub<DragCameraOptionsParams, CameraOptions>(defaultReturnValue: CameraOptions())
    func dragCameraOptions(from: CGPoint, to: CGPoint) -> CameraOptions {
        dragCameraOptionsStub.call(with: DragCameraOptionsParams(from: from, to: to))
    }

    func dragEnd() {
    }
}
