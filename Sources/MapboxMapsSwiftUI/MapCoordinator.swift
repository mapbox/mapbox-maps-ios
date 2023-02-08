@_spi(Package) import MapboxMaps
import SwiftUI

@_spi(Experimental)
@available(iOS 13.0, *)
public final class MapCoordinator {
    typealias CameraSetter = (CameraState) -> Void

    var actions: MapDependencies.Actions?

    private var bag = Bag()
    private var queriesBag = Bag()
    private var setCamera: CameraSetter?

    init(setCamera: CameraSetter?) {
        self.setCamera = setCamera
    }

    var mapView: MapView! {
        didSet {
            guard mapView != oldValue else {
                return
            }
            bag.cancel()

            addGestureHandler(mapView.gestures.singleTapGestureRecognizer) { [weak self] gesture in
                self?.onTapGesure(gesture)
            }.addTo(bag)

            if let setCamera = setCamera {
                mapView.mapboxMap.onEvery(event: .cameraChanged) { [weak self] _ in
                    guard let self = self else { return }
                    setCamera(self.mapView.cameraState)
                }.addTo(bag)
            }

            mapView.mapboxMap.onEvery(event: .mapLoaded) { [weak self] _ in
                guard let self = self else { return }
                self.actions?.onMapLoaded?(self.mapView.mapboxMap)
            }.addTo(bag)
        }
    }

    func update(camera: CameraState?, deps: MapDependencies, colorScheme: ColorScheme) {
        let mapboxMap = mapView.mapboxMap!

        // This is camera state which is inspected after current update loop.
        // It camera changed by method other than setCamera, we will propogate that change
        // to the source of truth (user's State).
        var expectedCamera: CameraState?

        mapboxMap.performWithoutNotifying {
            if let camera = camera {
                mapView.mapboxMap.setCamera(to: CameraOptions(cameraState: camera))
                expectedCamera = mapboxMap.cameraState
            }

            wrapError {
                try mapboxMap.setCameraBounds(with: deps.cameraBounds)
            }

            let mapOptions = mapView.mapboxMap.options
            set(mapOptions.constrainMode, mapboxMap.setConstrainMode, value: deps.constrainMode)
            set(mapOptions.viewportMode ?? .default, mapboxMap.setViewportMode, value: deps.viewportMode)
            set(mapOptions.orientation, mapboxMap.setNorthOrientation, value: deps.orientation)
        }

        set(mapView, \.mapboxMap.style.uri, value: deps.styleURIs.effectiveURI(with: colorScheme))
        set(mapView, \.gestures.options, value: deps.getstureOptions)

        actions = deps.actions

        if let expectedCamera = expectedCamera, expectedCamera != mapboxMap.cameraState {
            // The camera state has changed after setting the expected state.
            DispatchQueue.main.async { [weak self] in
                self?.syncCamera()
            }
        }
    }

    private func syncCamera() {
        setCamera?(mapView.mapboxMap.cameraState)
    }

    private func onTapGesure(_ gesture: UIGestureRecognizer) {
        queriesBag.cancel()
        guard let actions = actions else {
            return
        }
        let point = gesture.location(in: mapView)
        let coordinate = mapView.mapboxMap.coordinate(for: point)
        actions.onMapTapGesture?(point)

        actions.layerTapActions.map { layerIds, action in
            let options = RenderedQueryOptions(layerIds: layerIds, filter: nil)
            return mapView.mapboxMap.queryRenderedFeatures(with: point, options: options) { result in
                if let features = try? result.get(),
                   !features.isEmpty {
                    let payload = Map.LayerTapPayload(
                        point: point,
                        coordinate: coordinate,
                        features: features)
                    action(payload)
                }
            }
        }.addTo(queriesBag)
    }
}

private func wrapError(_ body: () throws -> Void) {
    do {
        try body()
    } catch {
        print("error: \(error)") // TODO: Logger
    }
}

private func set<T: Equatable>(_ getter: () -> T, _ setter: (T) throws -> Void, value: T) {
    wrapError {
        if getter() != value {
            try setter(value)
        }
    }
}

private func set<T: Equatable>(_ oldValue: T, _ setter: (T) throws -> Void, value: T) {
    set({ oldValue }, setter, value: value)
}

private func set<U: AnyObject, T: Equatable>(_ object: U, _ keyPath: ReferenceWritableKeyPath<U, T>, value: T) {
    set({ object[keyPath: keyPath] }, { object[keyPath: keyPath] = $0 }, value: value)
}
