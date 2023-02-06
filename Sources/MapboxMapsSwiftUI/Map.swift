@_exported import MapboxMaps
import SwiftUI

@_spi(Experimental)
@available(iOS 13.0, *)
public extension CameraState {
    /// Initializes CameraState with center and zoom.
    init(center: CLLocationCoordinate2D, zoom: CGFloat) {
        self.init(center: center, padding: .zero, zoom: zoom, bearing: 0, pitch: 0)
    }
}

/// The action that is called when the map is loaded.
@_spi(Experimental)
@available(iOS 13.0, *)
public typealias MapLoadedAction = (MapboxMap) -> Void

@_spi(Experimental)
@available(iOS 13.0, *)
public typealias Map = InternalMap

/// A view displaying Mapbox Map in SwiftUI.
@_spi(Experimental)
@available(iOS 13.0, *)
// TODO: Wrap it in Map and make internal.
public struct InternalMap: UIViewRepresentable {
    public typealias InitialOptionsProvider = () -> MapInitOptions
    public typealias TapAction = (CGPoint) -> Void
    public typealias LayerTapAction = (LayerTapPayload) -> Void

    public struct LayerTapPayload {
        public var point: CGPoint
        public var coordinate: CLLocationCoordinate2D
        public var features: [QueriedFeature]
    }

    struct Actions {
        var onMapLoaded: MapLoadedAction?
        var onMapTapGesture: TapAction?
        var layerTapActions = [([String], LayerTapAction)]()
    }

    struct StyleURIs {
        var `default`: StyleURI
        var darkMode: StyleURI?
    }

    @Environment(\.colorScheme) var colorScheme

    var camera: Binding<CameraState>?
    var cameraBounds: CameraBoundsOptions?
    var actions = Actions()
    var styleURIs = StyleURIs(default: .streets)
    var gestureOptions: GestureOptions = GestureOptions()
    var effectiveStyleURI: StyleURI {
        styleURIs.effectiveURI(with: colorScheme)
    }

    private let initialOptions: InitialOptionsProvider?

    /// Creates an instance showing scpecisif region.
    ///
    /// - Parameters:
    ///     - camera: The camera state to display. If not specified, the default camera options from style will be used. See [center](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-center), [zoom](https://docs.mapbox.com/mapbox-gl-js/style-spec/root/#zoom), [bearing](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-bearing), [pitch](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-pitch).
    ///     - initialOptions: A closure to provide initial map parameters. It gets called only once when `Map` is created.
    public init(camera: Binding<CameraState>? = nil, initialOptions: InitialOptionsProvider? = nil) {
        self.initialOptions = initialOptions
        self.camera = camera
    }

    public func makeCoordinator() -> MapCoordinator {
        MapCoordinator(camera: camera)
    }

    public func makeUIView(context: UIViewRepresentableContext<InternalMap>) -> MapView {
        MapView(frame: .zero, mapInitOptions: initialOptions?() ?? MapInitOptions())
    }

    public func updateUIView(_ mapView: MapView, context: Context) {
        context.environment.mapViewProvider?.mapView = mapView
        context.coordinator.mapView = mapView
        context.coordinator.update(from: self)
    }
}

@_spi(Experimental)
@available(iOS 13.0, *)
extension InternalMap {
    private func set<T>(_ keyPath: WritableKeyPath<InternalMap, T>, _ value: T) -> Self {
        var updated = self
        updated[keyPath: keyPath] = value
        return updated
    }

    /// Sets camera bounds.
    public func cameraBounds(_ cameraBounds: CameraBoundsOptions) -> Self {
        set(\.cameraBounds, cameraBounds)
    }

    /// Adds callback to map loaded event.
    public func onMapLoaded(perform action: @escaping MapLoadedAction) -> Self {
        set(\.actions.onMapLoaded, action)
    }

    /// Sets style to the map.
    ///
    /// - Parameters:
    ///     - default: A Style URI to be used by default.
    ///     - darkMode: A Style URI which will automaticaly be used for dark mode. If not specified,
    ///         the default option will continue to be used.
    public func styleURI(_ default: StyleURI, darkMode: StyleURI? = nil) -> Self {
        set(\.styleURIs, StyleURIs(default: `default`, darkMode: darkMode))
    }

    /// Configures gestures options.
    public func gestureOptions(_ options: GestureOptions) -> Self {
        set(\.gestureOptions, options)
    }

    /// Adds tap handler to the map.
    ///
    /// Prefer using this handler instead of `onTapGesture` since it waits for the failure of other map gestures like quick-zoom.
    ///
    /// - Parameters:
    ///  - action: The action to perform.
    public func onMapTapGesture(perform action: @escaping TapAction) -> Self {
        set(\.actions.onMapTapGesture, action)
    }

    /// Adds tap action to layers with specified `layerIds`.
    ///
    /// The action will only be called when at least one of specified layers are at the tap position.
    ///
    /// - Parameters:
    ///  - layerIds: The identifiers of layers where to perform features lookup.
    ///  - action: The action to perform.
    public func onLayerTapGesture(_ layerIds: String..., perform action: @escaping LayerTapAction) -> Self {
        var updated = self
        updated.actions.layerTapActions.append((layerIds, action))
        return updated
    }
}

@available(iOS 13.0, *)
extension InternalMap.StyleURIs {
    func effectiveURI(with colorScheme: ColorScheme) -> StyleURI {
        switch colorScheme {
        case .dark:
            return darkMode ?? `default`
        case .light:
            fallthrough
        @unknown default:
            return `default`
        }
    }
}
