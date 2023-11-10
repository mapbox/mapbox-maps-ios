import SwiftUI
import MapboxCoreMaps

@available(iOS 13.0, *)
struct MapDependencies {
    var cameraBounds = CameraBoundsOptions()
    var mapStyle: MapStyle = .standard
    var gestureOptions = GestureOptions()
    var constrainMode = ConstrainMode.heightOnly
    var viewportMode = ViewportMode.default
    var orientation = NorthOrientation.upwards
    var eventsSubscriptions = [AnyEventSubscription]()
    var cameraChangeHandlers = [(CameraChanged) -> Void]()
    var ornamentOptions = OrnamentOptions()
    var debugOptions = MapViewDebugOptions()
    var presentsWithTransaction = false
    var additionalSafeArea = SwiftUI.EdgeInsets()
    var viewportOptions = ViewportOptions(
        transitionsToIdleUponUserInteraction: true,
        usesSafeAreaInsetsAsPadding: true)

    var onMapTap: ((MapContentGestureContext) -> Void)?
    var onMapLongPress: ((MapContentGestureContext) -> Void)?
    var onLayerTap = [String: MapLayerGestureHandler]()
    var onLayerLongPress = [String: MapLayerGestureHandler]()
}

struct AnyEventSubscription {
    let observe: (MapboxMapProtocol) -> AnyCancelable

    init<Payload>(
        keyPath: KeyPath<MapboxMapProtocol, Signal<Payload>>,
        perform action: @escaping (Payload) -> Void
    ) {
        observe = { map in
            map[keyPath: keyPath].observe { payload in
                action(payload)
            }
        }
    }
}
