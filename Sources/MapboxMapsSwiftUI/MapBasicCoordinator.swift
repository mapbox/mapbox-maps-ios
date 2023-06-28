@_spi(Package) import MapboxMaps
import SwiftUI
import UIKit
import Combine

@available(iOS 13.0, *)
final class MapBasicCoordinator {
    typealias ViewportSetter = (Viewport) -> Void

    // Deps
    private var setViewport: ViewportSetter?
    private let mainQueue: MainQueueProtocol
    private var mapView: MapViewFacade

    // Update params
    private var actions: MapDependencies.Actions?
    private var cameraChangeHandlers = [(CameraChanged) -> Void]()
    private var cameraBoundsOptions = CameraBoundsOptions()

    // Runtime variables
    private var currentViewport: Viewport?
    private var updateCameraOnce = Once()
    private var subscribeOnce = Once()
    private var onCameraUpdateInProgress = SignalSubject<Bool>()

    private var cancellables = Set<AnyCancellable>()
    private var qrfCancellables = Set<AnyCancellable>()

    init(
        setViewport: ViewportSetter?,
        mapView: MapViewFacade,
        mainQueue: MainQueueProtocol = MainQueueWrapper()
    ) {
        self.setViewport = setViewport
        self.mapView = mapView
        self.mainQueue = mainQueue

        Signal(gesture: mapView.gestureManager.singleTapGestureRecognizer)
            .map { recognizer in
                recognizer.location(in: recognizer.view)
            }
            .observe { [weak self] point in
                self?.onTapGesture(point)
            }
            .store(in: &cancellables)

        mapView.mapboxMap.onCameraChanged
            .blockUpdates(while: onCameraUpdateInProgress.signal)
            .observe { [weak self] event in
                for handler in self?.cameraChangeHandlers ?? [] {
                    handler(event)
                }
            }.store(in: &cancellables)

        mapView.viewportManager.addStatusObserver(self)
    }

    deinit {
        mapView.viewportManager.removeStatusObserver(self)
    }

    func update(
        viewport: ConstantOrBinding<Viewport>,
        deps: MapDependencies,
        layoutDirection: LayoutDirection,
        colorScheme: ColorScheme,
        animationData: MapViewportAnimationData?
    ) {
        let mapboxMap = mapView.mapboxMap

        groupCameraUpdates(mapboxMap) {
            // Methods in this block can immediately produce multiple `onCameraChanged` notifications.
            // This may trigger SwiftUI's warnings if the user saves cameraState in @State in response to that camera change:
            //
            // @State var cameraState: CameraState
            // Map().onCameraChange { event in cameraState = event.cameraState }
            //
            // To avoid this, we
            // 1. group the `onCameraChanged` events (block them until the update is in progress);
            // 2. If the camera is actually changed, post notification about it in the next runloop.
            //
            // More details is in the `groupCameraUpdates`.
            updateCamera(position: viewport, layoutDirection: layoutDirection, animationData: animationData)

            assign(self.cameraBoundsOptions, {
                try mapboxMap.setCameraBounds(with: $0)
                self.cameraBoundsOptions = $0
            }, value: deps.cameraBounds)

            let mapOptions = mapView.mapboxMap.options
            assign(mapOptions.constrainMode, mapboxMap.setConstrainMode, value: deps.constrainMode)
            assign(mapOptions.viewportMode ?? .default, mapboxMap.setViewportMode, value: deps.viewportMode)
            assign(mapOptions.orientation, mapboxMap.setNorthOrientation, value: deps.orientation)
        }

        assign(&mapView, \.styleManager.uri, value: deps.styleURIs.effectiveURI(with: colorScheme))
        assign(&mapView, \.gestureManager.options, value: deps.gestureOptions)

        actions = deps.actions

        cameraChangeHandlers = deps.cameraChangeHandlers
        subscribeOnce {
            for subscription in deps.eventsSubscriptions {
                subscription.observe(mapboxMap).store(in: &cancellables)
            }
        }
    }

    private func groupCameraUpdates(_ map: MapboxMapProtocol, _ updates: () -> Void) {
        onCameraUpdateInProgress.send(true)
        let cameraBeforeUpdates = map.cameraState
        updates()
        let cameraChanged = map.cameraState != cameraBeforeUpdates
        if cameraChanged {
            // Schedule the update for the next runloop because we want to avoid the
            // "Modifying state during view update" error if the user saves cameraState
            // to a @State property.
            mainQueue.async { [weak self] in
                self?.onCameraUpdateInProgress.send(false)
            }
        } else {
            onCameraUpdateInProgress.send(false)
        }
    }

    private func updateCamera(position: ConstantOrBinding<Viewport>, layoutDirection: LayoutDirection, animationData: MapViewportAnimationData?) {
        switch position {
        case .constant(let position):
            updateCameraOnce {
                updateCurrentViewport(viewport: position, layoutDirection: layoutDirection, animationData: nil)
            }
        case .binding(let binding):
            updateCurrentViewport(viewport: binding.wrappedValue, layoutDirection: layoutDirection, animationData: animationData)
        }
    }

    private func updateCurrentViewport(viewport: Viewport, layoutDirection: LayoutDirection, animationData: MapViewportAnimationData?) {
        guard viewport != currentViewport else {
            return
        }
        currentViewport = viewport

        guard let state = mapView.makeViewportState(viewport, layoutDirection) else {
            mapView.viewportManager.idle()
            return
        }

        let transition: ViewportTransition
        if let animationData {
            transition = mapView.makeViewportTransition(animationData.animation)
        } else {
            transition = mapView.viewportManager.makeImmediateViewportTransition()
        }

        mapView.viewportManager.transition(to: state, transition: transition, completion: animationData?.completion)
    }

    private func onTapGesture(_ point: CGPoint) {
        qrfCancellables.removeAll(keepingCapacity: true)
        guard let actions = actions else {
            return
        }
        let coordinate = mapView.mapboxMap.coordinate(for: point)
        actions.onMapTapGesture?(point)

        actions.layerTapActions.map { layerIds, action in
            let options = RenderedQueryOptions(layerIds: layerIds, filter: nil)
            return mapView.mapboxMap.queryRenderedFeatures(with: point, options: options) { result in
                if let features = try? result.get(),
                   !features.isEmpty {
                    let payload = MapLayerTapPayload(
                        point: point,
                        coordinate: coordinate,
                        features: features)
                    action(payload)
                }
            }
        }.forEach { token in
            AnyCancelable(token).store(in: &qrfCancellables)
        }
    }
}

@available(iOS 13.0, *)
extension MapBasicCoordinator: ViewportStatusObserver {
    func viewportStatusDidChange(from fromStatus: ViewportStatus, to toStatus: ViewportStatus, reason: ViewportStatusChangeReason) {
        switch (fromStatus, toStatus, reason) {
        case (_, .idle, .userInteraction):
            currentViewport = .idle
            setViewport?(.idle)
        case (_, _, _):
            break
        }
    }
}
