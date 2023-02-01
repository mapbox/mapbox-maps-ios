import SwiftUI
import MapboxMaps

@available(iOS 13.0, *)
struct MapConfiguration {
    var cameraBounds = CameraBoundsOptions()
    var styleURIs = StyleURIs(light: .streets, dark: nil)
    var annotations = [PointAnnotation]()
    var getstureOptions = GestureOptions()
    var actions = Actions()
}

@available(iOS 13.0, *)
extension MapConfiguration {

    struct StyleURIs {
        let light: StyleURI
        let dark: StyleURI?

        func effectiveURI(with colorScheme: ColorScheme) -> StyleURI {
            if case .dark = colorScheme, let dark = dark {
                return dark
            }
            return light
        }
    }

    struct Actions {
        var onMapLoaded: MapLoadedAction?
        var onMapTapGesture: Map.TapAction?
        var tapActionsWithQuery = [Map.TapActionWithQueryPair]()
    }
}
