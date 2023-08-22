import SwiftUI
import MapboxCoreMaps

@available(iOS 13.0, *)
struct MapDependencies {
    var cameraBounds = CameraBoundsOptions()
    var mapStyle: MapStyle = .standard
    var gestureOptions = GestureOptions()
    var actions = Actions()
    var constrainMode = ConstrainMode.heightOnly
    var viewportMode = ViewportMode.default
    var orientation = NorthOrientation.upwards
    var eventsSubscriptions = [AnyEventSubscription]()
    var cameraChangeHandlers = [(CameraChanged) -> Void]()
    var ornamentOptions = OrnamentOptions()
}

@available(iOS 13.0, *)
extension MapDependencies {
    struct Actions {
        var onMapTapGesture: MapTapAction?
        var layerTapActions = [([String], MapLayerTapAction)]()
    }
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
