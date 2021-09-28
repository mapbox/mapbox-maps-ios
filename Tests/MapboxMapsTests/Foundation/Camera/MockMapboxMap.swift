@testable import MapboxMaps

final class MockMapboxMap: MapboxMapProtocol {

    var size: CGSize = .zero

    var cameraBounds = CameraBounds(
        bounds: CoordinateBounds(
            southwest: CLLocationCoordinate2D(
                latitude: -90,
                longitude: -180),
            northeast: CLLocationCoordinate2D(
                latitude: 90,
                longitude: 180)),
        maxZoom: 20,
        minZoom: 0,
        maxPitch: 50,
        minPitch: 0)

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

    let dragStartStub = Stub<CGPoint, Void>()
    func dragStart(for point: CGPoint) {
        dragStartStub.call(with: point)
    }

    struct DragCameraOptionsParams: Equatable {
        var from: CGPoint
        var to: CGPoint
    }
    let dragCameraOptionsStub = Stub<DragCameraOptionsParams, CameraOptions>(defaultReturnValue: CameraOptions())
    func dragCameraOptions(from: CGPoint, to: CGPoint) -> CameraOptions {
        dragCameraOptionsStub.call(with: DragCameraOptionsParams(from: from, to: to))
    }

    let dragEndStub = Stub<Void, Void>()
    func dragEnd() {
        dragEndStub.call()
    }

    struct OnEveryParams {
        var eventType: MapEvents.EventKind
        var handler: (Event) -> Void
    }
    let onEveryStub = Stub<OnEveryParams, Cancelable>(defaultReturnValue: MockCancelable())
    @discardableResult
    func onEvery(_ eventType: MapEvents.EventKind, handler: @escaping (Event) -> Void) -> Cancelable {
        onEveryStub.call(with: OnEveryParams(eventType: eventType, handler: handler))
    }
}
