import SwiftUI
import MapboxMaps

@available(iOS 13.0, *)
struct MapDependencies {
    var cameraBounds = CameraBoundsOptions()
    var styleURIs = StyleURIs(default: .streets, darkMode: nil)
    var gestureOptions = GestureOptions()
    var actions = Actions()
    var constrainMode = ConstrainMode.heightOnly
    var viewportMode = ViewportMode.default
    var orientation = NorthOrientation.upwards
    var mapEventObservers: [MapEventObserver] = []
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
