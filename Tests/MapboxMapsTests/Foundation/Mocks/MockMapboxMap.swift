@testable import MapboxMaps
@_implementationOnly import MapboxCoreMaps_Private

final class MockMapboxMap: MapboxMapProtocol {

    var size: CGSize = .zero

    var cameraBounds = MapboxMaps.CameraBounds(
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

    let setCameraStub = Stub<MapboxMaps.CameraOptions, Void>()
    func setCamera(to cameraOptions: MapboxMaps.CameraOptions) {
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
    let dragCameraOptionsStub = Stub<DragCameraOptionsParams, MapboxMaps.CameraOptions>(defaultReturnValue: CameraOptions())
    func dragCameraOptions(from: CGPoint, to: CGPoint) -> MapboxMaps.CameraOptions {
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

    let beginAnimationStub = Stub<Void, Void>()
    func beginAnimation() {
        beginAnimationStub.call()
    }

    let endAnimationStub = Stub<Void, Void>()
    func endAnimation() {
        endAnimationStub.call()
    }

    let beginGestureStub = Stub<Void, Void>()
    func beginGesture() {
        beginGestureStub.call()
    }

    let endGestureStub = Stub<Void, Void>()
    func endGesture() {
        endGestureStub.call()
    }

    // MARK: - View annotation management

    let setViewAnnotationPositionsUpdateListenerStub = Stub<ViewAnnotationPositionsUpdateListener?, Void>()
    func setViewAnnotationPositionsUpdateListener(_ listener: ViewAnnotationPositionsUpdateListener?) {
        setViewAnnotationPositionsUpdateListenerStub.call(with: listener)
    }

    struct ViewAnnotationModificationOptions: Equatable {
        var id: String
        var options: MapboxMaps.ViewAnnotationOptions
    }

    let addViewAnnotationStub = Stub<ViewAnnotationModificationOptions, Void>()
    func addViewAnnotation(withId id: String, options: MapboxMaps.ViewAnnotationOptions) throws {
        addViewAnnotationStub.call(with: ViewAnnotationModificationOptions(id: id, options: options))
    }

    let updateViewAnnotationStub = Stub<ViewAnnotationModificationOptions, Void>()
    func updateViewAnnotation(withId id: String, options: MapboxMaps.ViewAnnotationOptions) throws {
        updateViewAnnotationStub.call(with: ViewAnnotationModificationOptions(id: id, options: options))
    }

    let removeViewAnnotationStub = Stub<String, Void>()
    func removeViewAnnotation(withId id: String) throws {
        removeViewAnnotationStub.call(with: id)
    }

    let optionsForViewAnnotationWithIdStub = Stub<String, MapboxMaps.ViewAnnotationOptions>(defaultReturnValue: ViewAnnotationOptions())
    func options(forViewAnnotationWithId id: String) throws -> MapboxMaps.ViewAnnotationOptions {
        return optionsForViewAnnotationWithIdStub.call(with: id)
    }
}
