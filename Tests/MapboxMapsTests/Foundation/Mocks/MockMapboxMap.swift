@testable @_spi(Experimental) import MapboxMaps
import CoreLocation
import UIKit

final class MockMapboxMap: MapboxMapProtocol {
    var options: MapOptions = MapOptions()

    let events = MapEvents(makeGenericSubject: { _ in
        return SignalSubject<GenericEvent>()
    })

    var onMapLoaded: Signal<MapLoaded> { events.signal(for: \.onMapLoaded) }
    var onMapLoadingError: Signal<MapLoadingError> { events.signal(for: \.onMapLoadingError) }
    var onStyleLoaded: Signal<StyleLoaded> { events.signal(for: \.onStyleLoaded) }
    var onStyleDataLoaded: Signal<StyleDataLoaded> { events.signal(for: \.onStyleDataLoaded) }
    var onCameraChanged: Signal<CameraChanged> { events.signal(for: \.onCameraChanged) }
    var onMapIdle: Signal<MapIdle> { events.signal(for: \.onMapIdle) }
    var onSourceAdded: Signal<SourceAdded> { events.signal(for: \.onSourceAdded) }
    var onSourceRemoved: Signal<SourceRemoved> { events.signal(for: \.onSourceRemoved) }
    var onSourceDataLoaded: Signal<SourceDataLoaded> { events.signal(for: \.onSourceDataLoaded) }
    var onStyleImageMissing: Signal<StyleImageMissing> { events.signal(for: \.onStyleImageMissing) }
    var onStyleImageRemoveUnused: Signal<StyleImageRemoveUnused> { events.signal(for: \.onStyleImageRemoveUnused) }
    var onRenderFrameStarted: Signal<RenderFrameStarted> { events.signal(for: \.onRenderFrameStarted) }
    var onRenderFrameFinished: Signal<RenderFrameFinished> { events.signal(for: \.onRenderFrameFinished) }
    var onResourceRequest: Signal<ResourceRequest> { events.signal(for: \.onResourceRequest) }

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

    var cameraState = CameraState.zero

    var anchor = CGPoint.zero

    let setCameraStub = Stub<MapboxMaps.CameraOptions, Void>()
    func setCamera(to cameraOptions: MapboxMaps.CameraOptions) {
        setCameraStub.call(with: cameraOptions)
    }

    let coordinateForPointStub = Stub<CGPoint, CLLocationCoordinate2D>(defaultReturnValue: .random())
    func coordinate(for point: CGPoint) -> CLLocationCoordinate2D {
        coordinateForPointStub.call(with: point)
    }

    struct DragCameraOptionsParams: Equatable {
        var from: CGPoint
        var to: CGPoint
    }
    let dragCameraOptionsStub = Stub<DragCameraOptionsParams, MapboxMaps.CameraOptions>(defaultReturnValue: CameraOptions())
    func dragCameraOptions(from: CGPoint, to: CGPoint) -> MapboxMaps.CameraOptions {
        dragCameraOptionsStub.call(with: DragCameraOptionsParams(from: from, to: to))
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

    let setViewAnnotationPositionsUpdateCallbackStub = Stub<ViewAnnotationPositionsUpdateCallback?, Void>()

    func setViewAnnotationPositionsUpdateCallback(_ callback: ViewAnnotationPositionsUpdateCallback?) {
        setViewAnnotationPositionsUpdateCallbackStub.call(with: callback)
    }

    func simulateAnnotationPositionsUpdate(_ positions: [ViewAnnotationPositionDescriptor]) {
        setViewAnnotationPositionsUpdateCallbackStub.invocations.last?.parameters?(positions)
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

    struct CameraForCoordinateBoundsParams {
        var coordinateBounds: CoordinateBounds
        var padding: UIEdgeInsets?
        var bearing: Double?
        var pitch: Double?
        var maxZoom: Double?
        var offset: CGPoint?
    }
    let cameraForCoordinateBoundsStub = Stub<CameraForCoordinateBoundsParams, MapboxMaps.CameraOptions>(defaultReturnValue: .random())
    // swiftlint:disable:next function_parameter_count
    func camera(for coordinateBounds: CoordinateBounds, padding: UIEdgeInsets?, bearing: Double?, pitch: Double?, maxZoom: Double?, offset: CGPoint?) -> MapboxMaps.CameraOptions {
        cameraForCoordinateBoundsStub.call(with: .init(coordinateBounds: coordinateBounds, padding: padding, bearing: bearing, pitch: pitch, maxZoom: maxZoom, offset: offset))
    }

    struct CameraForCoordinatesParams {
        var coordinates: [CLLocationCoordinate2D]
        var camera: MapboxMaps.CameraOptions
        var coordinatesPadding: UIEdgeInsets?
        var maxZoom: Double?
        var offset: CGPoint?
    }
    let cameraForCoordinatesStub = Stub<CameraForCoordinatesParams, MapboxMaps.CameraOptions>(defaultReturnValue: .random())
    func camera(for coordinates: [CLLocationCoordinate2D],
                camera: MapboxMaps.CameraOptions,
                coordinatesPadding: UIEdgeInsets?,
                maxZoom: Double?,
                offset: CGPoint?) throws -> MapboxMaps.CameraOptions {
        var cameraOptions = cameraForCoordinatesStub.call(with: .init(coordinates: coordinates, camera: camera, coordinatesPadding: coordinatesPadding, maxZoom: maxZoom, offset: offset))
        // simulate core method behavior
        cameraOptions.padding = camera.padding
        cameraOptions.bearing = camera.bearing
        cameraOptions.pitch = camera.pitch
        return cameraOptions
    }

    let pointStub = Stub<CLLocationCoordinate2D, CGPoint>(defaultReturnValue: .random())
    func point(for coordinate: CLLocationCoordinate2D) -> CGPoint {
        pointStub.call(with: coordinate)
    }

    let setCameraBoundsStub = Stub<MapboxMaps.CameraBoundsOptions, Void>()
    func setCameraBounds(with options: MapboxMaps.CameraBoundsOptions) throws {
        setCameraBoundsStub.call(with: options)
    }

    let northOrientationStub = Stub<NorthOrientation, Void>()
    func setNorthOrientation(_ northOrientation: NorthOrientation) {
        northOrientationStub.call(with: northOrientation)
    }

    let setConstraintModeStub = Stub<ConstrainMode, Void>()
    func setConstrainMode(_ constrainMode: ConstrainMode) {
        setConstraintModeStub.call(with: constrainMode)
    }

    let setViewportModeStub = Stub<ViewportMode, Void>()
    func setViewportMode(_ viewportMode: ViewportMode) {
        setViewportModeStub.call(with: viewportMode)
    }

    struct QRFParameters {
        var point: CGPoint
        var options: RenderedQueryOptions?
        var completion: (Result<[QueriedRenderedFeature], Error>) -> Void
    }
    let qrfStub = Stub<QRFParameters, Cancelable>(defaultReturnValue: MockCancelable())
    func queryRenderedFeatures(with point: CGPoint, options: RenderedQueryOptions?, completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void) -> Cancelable {
        qrfStub.call(with: QRFParameters(point: point, options: options, completion: completion))
    }

    struct PerformanceStatisticsParameters {
        let options: PerformanceStatisticsOptions
        let callback: (PerformanceStatistics) -> Void
    }
    let collectPerformanceStatisticsStub = Stub<PerformanceStatisticsParameters, AnyCancelable>(defaultReturnValue: MockCancelable().erased)
    func collectPerformanceStatistics(_ options: PerformanceStatisticsOptions, callback: @escaping (PerformanceStatistics) -> Void) -> AnyCancelable {
        collectPerformanceStatisticsStub.call(with: PerformanceStatisticsParameters(options: options, callback: callback))
    }
}
