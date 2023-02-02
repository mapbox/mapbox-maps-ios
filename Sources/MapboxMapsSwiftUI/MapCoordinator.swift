@_spi(Package) import MapboxMaps
import SwiftUI

@_spi(Experimental)
@available(iOS 13.0, *)
public final class MapCoordinator {
    private var camera: Binding<CameraState>?

    var actions: MapDependencies.Actions?

    private var ignoreNotifications = false
    private var bag = Bag()
    private var queriesBag = Bag()

    init(camera: Binding<CameraState>?) {
        self.camera = camera
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

            if let camera = camera {
                mapView.mapboxMap.onEvery(event: .cameraChanged) { [weak self] _ in
                    guard let self = self else { return }
                    camera.wrappedValue = self.mapView.cameraState
                }.addTo(bag)
            }

            mapView.mapboxMap.onEvery(event: .mapLoaded) { [weak self] _ in
                guard let self = self else { return }
                self.actions?.onMapLoaded?(self.mapView.mapboxMap)
            }.addTo(bag)
        }
    }

    func update(from view: InternalMap) {
        do {
            try mapView.mapboxMap.performWithoutNotifying {
                if let camera = view.camera {
                    mapView.mapboxMap.setCamera(to: CameraOptions(cameraState: camera.wrappedValue))
                }

                // TODO: This call can change the camera, but it won't be reflected on camera Binding.
                try mapView.mapboxMap.setCameraBounds(with: view.mapDependencies.cameraBounds)

                mapView.mapboxMap.setConstrainMode(view.mapDependencies.constrainMode)
                mapView.mapboxMap.setViewportMode(view.mapDependencies.viewportMode)
                mapView.mapboxMap.setNorthOrientation(northOrientation: view.mapDependencies.orientation)
            }
            if mapView.mapboxMap.style.uri != view.effectiveStyleURI {
                mapView.mapboxMap.style.uri = view.effectiveStyleURI
            }
            mapView.gestures.options = view.mapDependencies.getstureOptions
        } catch {
            print("error: \(error)") // TODO: Logger
        }
        actions = view.mapDependencies.actions
    }

    private func onTapGesure(_ gesture: UIGestureRecognizer) {
        queriesBag.cancel()
        guard let actions = actions else {
            return
        }
        let location = gesture.location(in: mapView)
        actions.onMapTapGesture?(location)

        actions.tapActionsWithQuery.map { options, action in
            self.mapView.mapboxMap.queryRenderedFeatures(with: location, options: options) { result in
                action(location, result)
            }
        }.addTo(queriesBag)
    }
}
