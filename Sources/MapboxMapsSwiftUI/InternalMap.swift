import SwiftUI
import MapboxMaps

@available(iOS 13.0, *)
struct InternalMap: UIViewRepresentable {
    private var camera: Binding<CameraState>?
    private let mapConfiguration: MapConfiguration
    private var mapInitOptions: (CameraState?) -> MapInitOptions

    @Environment(\.colorScheme) var colorScheme
    var effectiveStyleURI: StyleURI {
        mapConfiguration.styleURIs.effectiveURI(with: colorScheme)
    }

    init(
        camera: Binding<CameraState>?,
        mapConfiguration: MapConfiguration,
        mapInitOptions: @escaping (CameraState?) -> MapInitOptions
    ) {
        self.camera = camera
        self.mapConfiguration = mapConfiguration
        self.mapInitOptions = mapInitOptions
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(camera: camera)
    }

    func makeUIView(context: Context) -> MapView {
        MapView(frame: .zero, mapInitOptions: mapInitOptions(camera?.wrappedValue))
    }

    func updateUIView(_ mapView: MapView, context: Context) {
        context.environment.mapViewProvider?.mapView = mapView
        context.coordinator.mapView = mapView
        context.coordinator.update(from: self)
    }
}

@available(iOS 13.0, *)
extension InternalMap {

    final class Coordinator {
        private  var camera: Binding<CameraState>?
        private var pointAnnotationManager: PointAnnotationManager?
        var actions: MapConfiguration.Actions?

        private var ignoreNotifications = false
        private var bag = Bag()
        private var queriesBag = Bag()

        @Environment(\.colorScheme) var colorScheme

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
                        if !self.ignoreNotifications {
                            camera.wrappedValue = self.mapView.cameraState
                        }
                    }.addTo(bag)
                }

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

        func update(from view: InternalMap) {
            do {
                try withoutNofifications {
                    if let camera = view.camera {
                        mapView.mapboxMap.setCamera(to: CameraOptions(cameraState: camera.wrappedValue))
                    }

                    // TODO: This call can change the camera, but it won't be reflected on camera Binding.
                    try mapView.mapboxMap.setCameraBounds(with: view.mapConfiguration.cameraBounds)
                }

                if mapView.mapboxMap.style.uri != view.effectiveStyleURI {
                    mapView.mapboxMap.style.uri = view.effectiveStyleURI
                }
                mapView.gestures.options = view.mapConfiguration.getstureOptions
            } catch {
                print("error: \(error)") // TODO: Logger
            }

            // TODO: Do annotations better, current implementation forces style to update on every display link.
            pointAnnotationManager?.annotations = view.mapConfiguration.annotations
            actions = view.mapConfiguration.actions
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
}
