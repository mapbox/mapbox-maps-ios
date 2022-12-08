@testable import MapboxMaps
@_implementationOnly import MapboxCoreMaps_Private
import CoreLocation

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
        center: CLLocationCoordinate2D(
            latitude: 0,
            longitude: 0),
        padding: UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0),
        zoom: 0,
        bearing: 0,
        pitch: 0)

    var anchor = CGPoint.zero

    let setCameraStub = Stub<MapboxMaps.CameraOptions, Void>()
    func setCamera(to cameraOptions: MapboxMaps.CameraOptions) {
        setCameraStub.call(with: cameraOptions)
    }

    let coordinateForPointStub = Stub<CGPoint, CLLocationCoordinate2D>(defaultReturnValue: .random())
    func coordinate(for point: CGPoint) -> CLLocationCoordinate2D {
        coordinateForPointStub.call(with: point)
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
        var eventName: String
        var handler: (Any) -> Void
    }
    let onEveryStub = Stub<OnEveryParams, Cancelable>(defaultReturnValue: MockCancelable())
    @discardableResult
    func onEvery<Payload>(event: MapEvents.Event<Payload>, handler: @escaping (MapEvent<Payload>) -> Void) -> Cancelable {
        // swiftlint:disable:next force_cast
        onEveryStub.call(with: OnEveryParams(eventName: event.name, handler: { handler($0 as! MapEvent<Payload>)}))
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

    let pointIsAboveHorizonStub = Stub<CGPoint, Bool>(defaultReturnValue: .random())
    func pointIsAboveHorizon(_ point: CGPoint) -> Bool {
        pointIsAboveHorizonStub.call(with: point)
    }

    struct CameraForGeometryParams {
        var geometry: Geometry
        var padding: UIEdgeInsets
        var bearing: CGFloat?
        var pitch: CGFloat?
    }
    let cameraForGeometryStub = Stub<CameraForGeometryParams, MapboxMaps.CameraOptions>(defaultReturnValue: .random())
    func camera(for geometry: Geometry,
                padding: UIEdgeInsets,
                bearing: CGFloat?,
                pitch: CGFloat?) -> MapboxMaps.CameraOptions {
        cameraForGeometryStub.call(with: .init(
            geometry: geometry,
            padding: padding,
            bearing: bearing,
            pitch: pitch))
    }

    struct CameraForCoordinateBoundsParams {
        var coordinateBounds: CoordinateBounds
        var padding: UIEdgeInsets
        var bearing: Double?
        var pitch: Double?
    }
    let cameraForCoordinateBoundsStub = Stub<CameraForCoordinateBoundsParams, MapboxMaps.CameraOptions>(defaultReturnValue: .random())
    func camera(for coordinateBounds: CoordinateBounds, padding: UIEdgeInsets, bearing: Double?, pitch: Double?) -> MapboxMaps.CameraOptions {
        cameraForCoordinateBoundsStub.call(with: .init(coordinateBounds: coordinateBounds, padding: padding, bearing: bearing, pitch: pitch))
    }

    let pointStub = Stub<CLLocationCoordinate2D, CGPoint>(defaultReturnValue: .random())
    func point(for coordinate: CLLocationCoordinate2D) -> CGPoint {
        pointStub.call(with: coordinate)
    }

    // not using Stub here since the block is not escaping
    var performWithoutNotifyingInvocationCount = 0
    var performWithoutNotifyingWillInvokeBlock = {}
    var performWithoutNotifyingDidInvokeBlock = {}
    func performWithoutNotifying(_ block: () -> Void) {
        performWithoutNotifyingInvocationCount += 1
        performWithoutNotifyingWillInvokeBlock()
        block()
        performWithoutNotifyingDidInvokeBlock()
    }
}
