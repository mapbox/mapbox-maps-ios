@_spi(Experimental) @_spi(Internal) @testable import MapboxMaps
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

    let coordinateForPointStub = Stub<CGPoint, CLLocationCoordinate2D>(defaultReturnValue: .testConstantValue())
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

    struct FeatureStateParams {
        var featureset: FeaturesetDescriptor
        var featureId: FeaturesetFeatureId
        var state: JSONObject?
        var key: String?
    }
    var setFeatureStateStub = Stub<FeatureStateParams, Cancelable>(defaultReturnValue: AnyCancelable.empty)
    func setFeatureState(featureset: FeaturesetDescriptor, featureId: FeaturesetFeatureId, state: Turf.JSONObject, callback: @escaping (Result<NSNull, any Error>) -> Void) -> any Cancelable {
        setFeatureStateStub.call(with: .init(featureset: featureset, featureId: featureId, state: state))
    }

    var removeFeatureStateStub = Stub<FeatureStateParams, Cancelable>(defaultReturnValue: AnyCancelable.empty)
    func removeFeatureState(featureset: FeaturesetDescriptor, featureId: MapboxMaps.FeaturesetFeatureId, stateKey: String?, callback: @escaping (Result<NSNull, any Error>) -> Void) -> any Cancelable {
        removeFeatureStateStub.call(with: .init(featureset: featureset, featureId: featureId, key: stateKey))
    }

    let dispatchStub = Stub<CorePlatformEventInfo, Void>()
    func dispatch(event: CorePlatformEventInfo) {
        dispatchStub.call(with: event)
    }

    private var interactions = [(Int, InteractionImpl)]()
    private var id = 0
    func addInteraction(_ interaction: some Interaction) -> any Cancelable {
        addInteraction(interaction.impl)
    }

    func addInteraction(_ interaction: CoreInteraction) -> any Cancelable {
        let type: InteractionImpl.InteractionType = switch interaction.type {
        case .click: .tap
        case .drag: .drag
        case .longClick: .longPress
        @unknown default:
            fatalError()
        }
        guard let featureset = interaction.featureset else { return AnyCancelable.empty }
        return addInteraction(InteractionImpl(featureset: featureset, filter: nil, type: type, onBegin: { feature, context in
            let queriedFeature = QueriedFeature(
                __feature: MapboxCommon.Feature(feature.originalFeature),
                source: "",
                sourceLayer: nil,
                state: [String: Any](),
                featuresetFeatureId: nil)

            return interaction.handler.handleBegin(for: queriedFeature, context: CoreInteractionContext(coordinateInfo: CoordinateInfo(coordinate: context.coordinate, isOnSurface: context.isOnSurface), screenCoordinate: context.point.screenCoordinate))
        }))
    }

    func addInteraction(_ interaction: InteractionImpl) -> any Cancelable {
        self.id += 1
        let id = self.id

        interactions.append((id, interaction))
        return BlockCancelable { [weak self] in
            self?.interactions.removeAll { $0.0 == id }
        }
    }

    enum DragStage {
        case begin
        case change
        case end
    }
    enum InteractionType {
        case tap
        case longPress
        case drag(DragStage)
        func canHandle(_ interaction: InteractionImpl) -> Bool {
            switch (self, interaction.type) {
            case (.tap, .tap): true
            case (.longPress, .longPress): true
            case (.drag(_), .drag): true
            default: false
            }
        }
    }

    func simulateInteraction(_ type: InteractionType, _ featureset: FeaturesetDescriptor?, feature: Feature?, context: InteractionContext) {
        let interactiveFeature: InteractiveFeature? = if let featureset, let feature {
            InteractiveFeature(id: feature.identifier?.string.map { FeaturesetFeatureId(id: $0) }, featureset: featureset, feature: feature, state: nil)
        } else {
            nil
        }

        simulateInteraction(type: type, feature: interactiveFeature, context: context)
    }

    func simulateInteraction(type: InteractionType, feature: InteractiveFeature?, context: InteractionContext) {
        for (_, interaction) in interactions.reversed() {
            guard type.canHandle(interaction),
                  feature?.featureset == interaction.target?.0 else { continue }

            var handled = false
            switch type {
            case .tap:
                handled = interaction.onBegin(feature, context)
            case .longPress:
                handled = interaction.onBegin(feature, context)
            case .drag(let dragStage):
                switch dragStage {
                case .begin:
                    handled = interaction.onBegin(feature, context)
                case .change:
                    handled = true
                    interaction.onChange?(context)
                case .end:
                    handled = true
                    interaction.onEnd?(context)
                }
            }
            if handled {
                break
            }
        }
    }
}
