import SwiftUI
import MapboxMaps

@available(iOS 13.0, *)
struct MapDependencies {
    var cameraBounds = CameraBoundsOptions()
    var styleURIs = StyleURIs(default: .streets, darkMode: nil)
    var getstureOptions = GestureOptions()
    var actions = Actions()
    var constrainMode = ConstrainMode.heightOnly
    var viewportMode = ViewportMode.default
    var orientation = NorthOrientation.upwards
}

@available(iOS 13.0, *)
extension MapDependencies {

    struct StyleURIs {
        let `default`: StyleURI
        let darkMode: StyleURI?
    }

    struct Actions {
        var onMapLoaded: MapLoadedAction?
        var onMapTapGesture: Map.TapAction?
        var layerTapActions = [([String], Map.LayerTapAction)]()
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
