import MapboxMaps
import SwiftUI

@_spi(Experimental)
@available(iOS 13.0, *)
public final class SwiftUIMapViewCoordinator {
    @Binding private var camera: CameraState

    private var pointAnnotationManager: PointAnnotationManager?

    var actions: MapboxView.Actions?

    private var ignoreNotifications = false
    private var bag = Bag()
    private var queriesBag = Bag()

    init(camera: Binding<CameraState>) {
        _camera = camera
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

            mapView.mapboxMap.onEvery(event: .cameraChanged) { [weak self] _ in
                guard let self = self else { return }
                if !self.ignoreNotifications {
                    self.camera = self.mapView.cameraState
                }
            }.addTo(bag)

            mapView.mapboxMap.onEvery(event: .mapLoaded) { [weak self] _ in
                guard let self = self else { return }
                self.actions?.onMapLoaded?(self.mapView.mapboxMap)
            }.addTo(bag)

            pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
        }
    }

    private func withoutNofifications(_ block: () throws -> Void) rethrows {
        ignoreNotifications = true
        try block()
        ignoreNotifications = false
    }

    func update(from view: MapboxView) {
        do {
            try withoutNofifications {
                mapView.mapboxMap.setCamera(to: CameraOptions(cameraState: view.camera))
                if let cameraBounds = view.cameraBounds {
                    // TODO: This call can change the camera, but it won't be reflected on camera Binding.
                    try mapView.mapboxMap.setCameraBounds(with: cameraBounds)
                }
            }

            if mapView.mapboxMap.style.uri != view.styleURI {
                mapView.mapboxMap.style.uri = view.styleURI
            }
            mapView.gestures.options = view.getstureOptions
        } catch {
            print("error: \(error)") // TODO: Logger
        }

        // TODO: Do annotations better, current implementation forces style to update on every display link.
        pointAnnotationManager?.annotations = view.annotations
        actions = view.actions
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
