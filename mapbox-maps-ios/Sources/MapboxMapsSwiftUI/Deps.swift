import SwiftUI
@_spi(Package) import MapboxMaps
import MapboxCoreMaps

@available(iOS 13.0, *)
struct MapDependencies {
    var cameraBounds = CameraBoundsOptions()
    var styleURIs = StyleURIs(default: .standard, darkMode: nil)
    var gestureOptions = GestureOptions()
    var actions = Actions()
    var constrainMode = ConstrainMode.heightOnly
    var viewportMode = ViewportMode.default
    var orientation = NorthOrientation.upwards
    var eventsSubscriptions = [AnyEventSubscription]()
    var cameraChangeHandlers = [(CameraChanged) -> Void]()
}

@available(iOS 13.0, *)
extension MapDependencies {

    struct StyleURIs {
        let `default`: StyleURI
        let darkMode: StyleURI?
    }

    struct Actions {
        var onMapTapGesture: MapTapAction?
        var layerTapActions = [([String], MapLayerTapAction)]()
    }
}

@available(iOS 13.0, *)
extension MapDependencies.StyleURIs {

    func effectiveURI(with colorScheme: ColorScheme) -> StyleURI {
        if case .dark = colorScheme, let dark = darkMode {
            return dark
        }
        return `default`
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
