@_spi(Package) import MapboxMaps
import SwiftUI
import UIKit

@available(iOS 13.0, *)
final class MapBasicCoordinator {
    typealias CameraSetter = (CameraState) -> Void
    typealias MapEventHandler = (Event) -> Void

    var actions: MapDependencies.Actions?

    private var bag = Bag()
    private var queriesBag = Bag()
    private var setCamera: CameraSetter?
    private var mapView: MapViewFacade?
    private var mapEventHandlers: [String: [MapEventHandler]] = [:]
    private var isSubscribed = false

    private let mainQueue: MainQueueProtocol

    deinit {
        mapView?.mapboxMap.unsubscribe(self, events: [])
    }

    init(setCamera: CameraSetter?, mainQueue: MainQueueProtocol = MainQueueWrapper()) {
        self.setCamera = setCamera
        self.mainQueue = mainQueue
    }

    func setMapView(_ mapView: MapViewFacade) {
        guard self.mapView == nil else { return }
        self.mapView = mapView

        addGestureHandler(mapView.gestures.singleTapGestureRecognizer) { [weak self] gesture in
            self?.onTapGesure(gesture)
        }.addTo(bag)

        if setCamera != nil {
            mapView.mapboxMap.onEvery(event: .cameraChanged) { [weak self] _ in
                self?.syncCamera()
            }.addTo(bag)
        }
    }

    func update(camera: CameraState?, deps: MapDependencies, colorScheme: ColorScheme) {
        guard var mapView = mapView else { return }
        let mapboxMap = mapView.mapboxMap

        // This is camera state which is expected after current update loop.
        // If the camera changed by method other than setCamera, we will propogate that change
        // to the source of truth (user's State).
        var expectedCamera: CameraState?

        mapboxMap.performWithoutNotifying {
            if let camera = camera {
                mapView.mapboxMap.setCamera(to: CameraOptions(cameraState: camera))
                expectedCamera = mapboxMap.cameraState
            }

            wrapAssignError {
                // The camera bounds update is known to change camera if
                // the current camera state is out of desired bounds.
                try mapboxMap.setCameraBounds(with: deps.cameraBounds)
            }

            let mapOptions = mapView.mapboxMap.options
            assign(mapOptions.constrainMode, mapboxMap.setConstrainMode, value: deps.constrainMode)
            assign(mapOptions.viewportMode ?? .default, mapboxMap.setViewportMode, value: deps.viewportMode)
            assign(mapOptions.orientation, mapboxMap.setNorthOrientation, value: deps.orientation)
        }

        assign(&mapView, \.style.uri, value: deps.styleURIs.effectiveURI(with: colorScheme))
        assign(&mapView, \.gestures.options, value: deps.getstureOptions)

        actions = deps.actions

        if let expectedCamera = expectedCamera, expectedCamera != mapboxMap.cameraState {
            // The camera state has changed after setting the expected state.
            mainQueue.async { [weak self] in
                self?.syncCamera()
            }
        }

        if !isSubscribed {
            isSubscribed = true
            mapEventHandlers = deps.mapEventObservers.reduce(into: [:]) { partialResult, observer in
                partialResult[observer.eventName, default: []].append(observer.action)
            }
            mapView.mapboxMap.subscribe(self, events: Array(mapEventHandlers.keys))
        }
    }

    private func syncCamera() {
        guard let mapView = mapView else { return }
        setCamera?(mapView.mapboxMap.cameraState)
    }

    private func onTapGesure(_ gesture: UIGestureRecognizer) {
        queriesBag.cancel()
        guard let mapView = mapView, let actions = actions else {
            return
        }
        let point = mapView.locationForGesture(gesture)
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
        }.addTo(queriesBag)
    }
}

// MARK: Observer

@available(iOS 13.0, *)
extension MapBasicCoordinator: Observer {

    func notify(for event: Event) {
        mapEventHandlers[event.type]?.forEach { handler in
            handler(event)
        }
    }
}

// MARK: Assign

private func assign<T: Equatable>(_ oldValue: T, _ setter: (T) throws -> Void, value: T) {
    wrapAssignError {
        if oldValue != value {
            try setter(value)
        }
    }
}

private func assign<U, T: Equatable>(_ object: inout U, _ keyPath: WritableKeyPath<U, T>, value: T) {
    assign(object[keyPath: keyPath], { object[keyPath: keyPath] = $0 }, value: value)
}
