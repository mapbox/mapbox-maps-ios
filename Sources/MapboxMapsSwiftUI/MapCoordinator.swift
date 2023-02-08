@_spi(Package) import MapboxMaps
import SwiftUI
import UIKit

@available(iOS 13.0, *)
public final class MapCoordinator {
    typealias CameraSetter = (CameraState) -> Void

    var actions: MapDependencies.Actions?

    private var bag = Bag()
    private var queriesBag = Bag()
    private var setCamera: CameraSetter?
    private var mapView: MapViewType?

    init(setCamera: CameraSetter?) {
        self.setCamera = setCamera
    }

    func setMapView(_ mapView: MapViewType) {
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

        mapView.mapboxMap.onEvery(event: .mapLoaded) { [weak self] _ in
            guard let self = self,
                  let mapboxMap = self.mapView?.realMapboxMap else { return }
            self.actions?.onMapLoaded?(mapboxMap)
        }.addTo(bag)
    }

    func update(camera: CameraState?, deps: MapDependencies, colorScheme: ColorScheme) {
        guard var mapView = mapView else { return }
        let mapboxMap = mapView.mapboxMap

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
            assign(mapOptions.constrainMode, mapboxMap.setConstrainMode, value: deps.constrainMode)
            assign(mapOptions.viewportMode ?? .default, mapboxMap.setViewportMode, value: deps.viewportMode)
            assign(mapOptions.orientation, mapboxMap.setNorthOrientation, value: deps.orientation)
        }

        assign(&mapView, \.style.uri, value: deps.styleURIs.effectiveURI(with: colorScheme))
        assign(&mapView, \.gestures.options, value: deps.getstureOptions)

        actions = deps.actions

        if let expectedCamera = expectedCamera, expectedCamera != mapboxMap.cameraState {
            // The camera state has changed after setting the expected state.
            DispatchQueue.main.async { [weak self] in
                self?.syncCamera()
            }
        }
    }

    private func syncCamera() {
        guard let mapView = mapView else { return }
        setCamera?(mapView.cameraState())
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

private func assign<T: Equatable>(_ oldValue: T, _ setter: (T) throws -> Void, value: T) {
    wrapError {
        if oldValue != value {
            try setter(value)
        }
    }
}

private func assign<U, T: Equatable>(_ object: inout U, _ keyPath: WritableKeyPath<U, T>, value: T) {
    assign(object[keyPath: keyPath], { object[keyPath: keyPath] = $0 }, value: value)
}
