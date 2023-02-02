@_spi(Package) import MapboxMaps
import SwiftUI

@_spi(Experimental)
@available(iOS 13.0, *)
public final class MapCoordinator {
    var camera: Binding<CameraState>?

    var actions: InternalMap.Actions?

    private var ignoreNotifications = false
    private var bag = Bag()
    private var queriesBag = Bag()
    private var styleRuntime: StyleRuntime?

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
            mapView.mapboxMap.onEvery(event: .styleLoaded) { [weak self] _ in
                self?.styleRuntime?.update()
            }
            styleRuntime = StyleRuntime(styleApplier: mapView.mapboxMap.style, comopnent: AnyBuiltinComponent(EmptyComponent()))
        }
    }

    func update(from view: InternalMap) {
        do {
            try mapView.mapboxMap.performWithoutNotifying {
                if let camera = view.camera {
                    mapView.mapboxMap.setCamera(to: CameraOptions(cameraState: camera.wrappedValue))
                }

                if let cameraBounds = view.cameraBounds {
                    // TODO: This call can change the camera, but it won't be reflected on camera Binding.
                    try mapView.mapboxMap.setCameraBounds(with: cameraBounds)
                }
            }
            if mapView.mapboxMap.style.uri != view.effectiveStyleURI {
                mapView.mapboxMap.style.uri = view.effectiveStyleURI
            }
            mapView.gestures.options = view.gestureOptions
        } catch {
            print("error: \(error)") // TODO: Logger
        }
        actions = view.actions
        styleRuntime?.comopnent = view.styleComponent
        if(mapView.mapboxMap.style.isLoaded) {
            styleRuntime?.update()
        }
    }

    private func onTapGesure(_ gesture: UIGestureRecognizer) {
        queriesBag.cancel()
        guard let actions = actions else {
            return
        }
        let point = gesture.location(in: mapView)
        let coordinate = mapView.mapboxMap.coordinate(for: point)
        actions.onMapTapGesture?(point, coordinate)

        actions.tapActionsWithQuery.map { options, action in
            self.mapView.mapboxMap.queryRenderedFeatures(with: point, options: options) { result in
                action(point, coordinate, result)
            }
        }.addTo(queriesBag)
    }
}

extension Style: StyleApplier {
    func addLayer(_ layer: MapboxMaps.Layer) throws {
        try addLayer(layer, layerPosition: nil)
    }
}

private class StyleRuntime {
    private let styleApplier: StyleApplier
    private let node: Node
    var dirty = false
    var comopnent: AnyBuiltinComponent {
        didSet {
           dirty = true
        }
    }

    init(styleApplier: StyleApplier, comopnent: AnyBuiltinComponent) {
        self.styleApplier = styleApplier
        self.comopnent = comopnent

        let styleState = StyleState()
        node = Node(style: styleState)
    }

    func update() {
        guard dirty else {
            return
        }
        dirty = false

        let from = node.style.take()
        comopnent._visit(node)
        let to = node.style.s
        from.applyDiff(to: to, styleApplier: styleApplier)
    }
}
